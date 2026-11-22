"""Tiny writer for xschem schematics (file_version 1.2). SPDX-License-Identifier: Apache-2.0

Coordinates follow xschem: y grows downward. Transistor symbols are the open_pdks
sky130_fd_pr ones, whose pins (unrotated) are G (-20,0), D (20,-30) for NMOS or
(20,30) for PMOS, S opposite to D, and B (20,0). flip mirrors x.
"""

PDK = "sky130_fd_pr"


class Sch:
    def __init__(self, title=""):
        self.items, self.n = [], 0
        if title:
            self.text(title, -260, -190, size=0.5)

    # ---------- primitives ----------
    def wire(self, *pts, net=None):
        for (x1, y1), (x2, y2) in zip(pts, pts[1:]):
            lab = f"lab={net}" if net else ""
            self.items.append(f"N {x1} {y1} {x2} {y2} {{{lab}}}")

    def text(self, s, x, y, size=0.4, layer=None):
        props = f"layer={layer}" if layer is not None else ""
        self.items.append(f"T {{{s}}} {x} {y} 0 0 {size} {size} {{{props}}}")

    def inst(self, sym, x, y, props, rot=0, flip=0):
        self.items.append(f"C {{{sym}}} {x} {y} {rot} {flip} {{{props}}}")

    # ---------- labels and ports ----------
    def lab(self, p, net, side="left"):
        """Net label whose text sits on `side` of point p."""
        x, y = p
        rot, flip = {"left": (0, 0), "right": (0, 1), "up": (1, 0), "down": (3, 0)}[side]
        self.n += 1
        self.inst("devices/lab_pin.sym", x, y, f"name=l{self.n} sig_type=std_logic lab={net}", rot, flip)

    def body(self, dev, net, side):
        """Bulk tie, long enough that the label clears the symbol's W/L annotations."""
        return self.stub(dev["B"], net, side, 60)

    def stub(self, p, net, side, length=20):
        dx, dy = {"left": (-length, 0), "right": (length, 0), "up": (0, -length), "down": (0, length)}[side]
        q = (p[0] + dx, p[1] + dy)
        self.wire(p, q)
        self.lab(q, net, side)
        return q

    def port(self, p, net, kind="ipin"):
        """Subcircuit port; its lab names the net, so no extra label is needed."""
        self.n += 1
        self.inst(f"devices/{kind}.sym", p[0], p[1], f"name=p{self.n} lab={net}", 0, 0)

    # ---------- devices ----------
    def mos(self, name, model, x, y, W, L, flip=0, nf=1):
        pmos = model.startswith("pfet")
        sgn = -1 if flip else 1
        d = (x + 20 * sgn, y + (30 if pmos else -30))
        s = (x + 20 * sgn, y + (-30 if pmos else 30))
        props = (f"name={name} L={L} W={W} nf={nf} mult=1 model={model} spiceprefix=X "
                 f"ad=\"'int((nf+1)/2) * W/nf * 0.29'\" pd=\"'2*int((nf+1)/2) * (W/nf + 0.29)'\" "
                 f"as=\"'int((nf+2)/2) * W/nf * 0.29'\" ps=\"'2*int((nf+2)/2) * (W/nf + 0.29)'\" "
                 f"nrd=0 nrs=0 sa=0 sb=0 sd=0")
        self.inst(f"{PDK}/{model}.sym", x, y, props, 0, flip)
        return dict(D=d, S=s, G=(x - 20 * sgn, y), B=(x + 20 * sgn, y))

    def cap(self, name, x, y, W, L, MF="1"):
        self.inst(f"{PDK}/cap_mim_m3_1.sym", x, y, f"name={name} model=cap_mim_m3_1 W={W} L={L} MF={MF} spiceprefix=X")
        return dict(top=(x, y - 30), bot=(x, y + 30))

    def res(self, name, x, y, L):
        self.inst(f"{PDK}/res_high_po_0p35.sym", x, y, f"name={name} W=0.35 L={L} model=res_high_po_0p35 spiceprefix=X mult=1")
        return dict(P=(x, y - 30), M=(x, y + 30), B=(x - 20, y))

    def diode(self, name, x, y, model, area, pj, flip_vertical=False):
        rot = 2 if flip_vertical else 0
        self.inst(f"{PDK}/diode.sym", x, y, f"name={name} model={model} area=\"{area} pj={pj}\"", rot, 0)
        top, bot = (x, y - 30), (x, y + 30)
        return dict(d1=bot if flip_vertical else top, d0=top if flip_vertical else bot)

    def save(self, path):
        head = ["v {xschem version=3.4.4 file_version=1.2}", "G {}", "K {}", "V {}", "S {}", "E {}"]
        with open(path, "w") as f:
            f.write("\n".join(head + self.items) + "\n")


def labeled(s, dev, top, gate, bottom, body, gate_side="left", body_side="right"):
    """Label every terminal of a vertical transistor: top pin up, bottom pin down."""
    t, b = (dev["D"], dev["S"]) if dev["D"][1] < dev["S"][1] else (dev["S"], dev["D"])
    s.stub(t, top, "up"); s.stub(b, bottom, "down"); s.stub(dev["G"], gate, gate_side); s.body(dev, body, body_side)


def inverter(s, tag, x, y, inp, out, wn=1, wp=2, supply=("vp", "vn")):
    """Flat cells.spice `inv`: PMOS over NMOS, gates and drains joined."""
    vp, vn = supply
    p = s.mos(f"M{tag}p", "pfet_01v8", x, y, wp, 0.15)
    n = s.mos(f"M{tag}n", "nfet_01v8", x, y + 120, wn, 0.15)
    s.wire(p["D"], n["D"])
    s.wire(p["G"], (x - 40, y), (x - 40, y + 120), n["G"])
    s.wire((x - 40, y + 60), (x - 70, y + 60)); s.lab((x - 70, y + 60), inp, "left")
    s.wire((x + 20, y + 60), (x + 70, y + 60)); s.lab((x + 70, y + 60), out, "right")
    s.wire(p["S"], (x + 20, y - 50)); s.lab((x + 20, y - 50), vp, "up")
    s.wire(n["S"], (x + 20, y + 170)); s.lab((x + 20, y + 170), vn, "down")
    s.body(p, vp, "right"); s.body(n, vn, "right")


def tgate(s, tag, x, y, a, b, en, enb, model_n="nfet_01v8", model_p="pfet_01v8", wn=0.55, wp=1, l=0.5,
          vp="vp", vn="vn"):
    """Transmission gate drawn as the usual parallel pair: NMOS (gate en, mirrored) left, PMOS (gate enb) right,
    gates facing inward, bulks outward. Node a is the top rail, node b the bottom rail."""
    n = s.mos(f"M{tag}n", model_n, x, y, wn, l, flip=1)
    p = s.mos(f"M{tag}p", model_p, x + 240, y, wp, l)
    s.wire(n["D"], (x - 20, y - 60), (x + 260, y - 60), p["S"])
    s.wire(n["S"], (x - 20, y + 60), (x + 260, y + 60), p["D"])
    if a:
        s.stub((x + 120, y - 60), a, "up")
    if b:
        s.stub((x + 120, y + 60), b, "down")
    s.stub(n["G"], en, "right"); s.stub(p["G"], enb, "left")
    s.body(n, vn, "left"); s.body(p, vp, "right")
    return dict(a=(x + 120, y - 60), b=(x + 120, y + 60))


def ports(s, names_in, names_out, names_io, x=-200, y0=-80, dy=40):
    y = y0
    for kind, names in (("ipin", names_in), ("opin", names_out), ("iopin", names_io)):
        for n in names:
            s.port((x, y), n, kind)
            y += dy
