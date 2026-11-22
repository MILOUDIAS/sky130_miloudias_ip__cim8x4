"""Transistor-level xschem schematic of the clocked comparator (subckt `compare`). SPDX-License-Identifier: Apache-2.0"""
import sys
from pathlib import Path
from sch import Sch, inverter, ports


def main(out):
    s = Sch("Clocked comparator (compare): sum vs. replica reference, decision = 1 when sig > ref")
    ports(s, ["sig", "ref", "ev"], ["decision"], ["vp", "vn"])

    # Cross-coupled latch, left half normal, right half mirrored.
    pl = s.mos("Mpl", "pfet_01v8", 300, 0, 1, 0.3)
    pr = s.mos("Mpr", "pfet_01v8", 560, 0, 1, 0.3, flip=1)
    nl = s.mos("Mnl", "nfet_01v8", 300, 120, 1, 0.15)
    nr = s.mos("Mnr", "nfet_01v8", 560, 120, 1, 0.15, flip=1)
    il = s.mos("Mis", "nfet_01v8_lvt", 300, 240, 4, 0.35)
    ir = s.mos("Mir", "nfet_01v8_lvt", 560, 240, 4, 0.35, flip=1)
    tl = s.mos("Mtail", "nfet_01v8", 410, 350, 1, 0.4)

    # vp rail over the latch PMOS sources.
    s.wire(pl["S"], (320, -60)); s.wire(pr["S"], (540, -60)); s.wire((320, -60), (540, -60))
    s.lab((430, -60), "vp", "up")
    # Output nodes and the lower stack.
    s.wire(pl["D"], nl["D"], net="ol"); s.wire(pr["D"], nr["D"], net="oright")
    s.wire(nl["S"], il["D"], net="ml"); s.wire(nr["S"], ir["D"], net="mr")
    s.wire(il["S"], (320, 300), (540, 300), ir["S"], net="tail"); s.wire(tl["D"], (430, 300))
    s.wire(tl["S"], (430, 410)); s.lab((430, 410), "vn", "down")
    # Cross coupling: left gates to oright, right gates to ol.
    s.wire(pl["G"], (260, 0), (260, 120), nl["G"]); s.wire((260, 60), (540, 60))
    s.wire(pr["G"], (600, 0), (600, 120), nr["G"]); s.wire((600, 80), (320, 80))
    # Inputs and clock.
    s.stub(il["G"], "sig", "left", 40); s.stub(ir["G"], "ref", "right", 40); s.stub(tl["G"], "ev", "left", 40)
    s.lab((320, 50), "ol", "left"); s.lab((540, 40), "oright", "right")
    s.lab((320, 180), "ml", "left"); s.lab((540, 180), "mr", "right")
    # Bodies.
    for d, net, side in ((pl, "vp", "right"), (nl, "vn", "right"), (il, "vn", "right"),
                         (pr, "vp", "left"), (nr, "vn", "left"), (ir, "vn", "left"), (tl, "vn", "right")):
        s.body(d, net, side)

    # Precharge (reset) PMOS, active while ev is low.
    for i, (name, node) in enumerate((("Mrl", "ol"), ("Mrml", "ml"))):
        p = s.mos(name, "pfet_01v8", 20, 240 * i, 1, 0.15)
        s.stub(p["S"], "vp", "up"); s.stub(p["D"], node, "down"); s.stub(p["G"], "ev", "left"); s.body(p, "vp", "right")
    for i, (name, node) in enumerate((("Mrr", "oright"), ("Mrmr", "mr"))):
        p = s.mos(name, "pfet_01v8", 840, 240 * i, 1, 0.15, flip=1)
        s.stub(p["S"], "vp", "up"); s.stub(p["D"], node, "down"); s.stub(p["G"], "ev", "right"); s.body(p, "vp", "left")
    s.text("precharge (ev low)", -40, -120, 0.3); s.text("precharge (ev low)", 760, -120, 0.3)

    # Regeneration-slowing MIM loads on both outputs.
    for name, node, x in (("Colcap", "ol", 120), ("Corcap", "oright", 740)):
        c = s.cap(name, x, 420, 2, 2)
        s.stub(c["top"], node, "up"); s.stub(c["bot"], "vn", "down")
    s.text("MIM load on ol", 60, 500, 0.3); s.text("MIM load on oright", 680, 500, 0.3)

    # Output buffer and the matching dummy inverter on the other output.
    inverter(s, "buf", 1120, 0, "ol", "decision")
    inverter(s, "dmy", 1120, 360, "oright", "dummy")
    s.text("output buffer", 1060, -120, 0.3); s.text("dummy load (balances ol and oright)", 1060, 240, 0.3)
    s.save(out)


if __name__ == "__main__":
    main(Path(sys.argv[1]))
