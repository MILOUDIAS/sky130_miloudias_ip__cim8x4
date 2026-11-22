"""Transistor-level xschem schematic of the VEXT test-input path (subckt `vext_path`). SPDX-License-Identifier: Apache-2.0

vext_path = two ls_hv level shifters + vext_in (5 V pad switch, series poly resistor, clamps) + one per-column nvx
switch onto the reference bus and its always-off dummy on the sum bus, as generate.py places them for one column.
"""
import sys
from pathlib import Path
from sch import Sch, inverter, tgate, ports


def level_shifter(s, tag, x, y, a, y_out, yb_out):
    """cells.spice `ls_hv`: core inverter, then a cross-coupled 5 V PMOS pair over 5 V NMOS pull-downs."""
    ab = f"{a}_b"
    inverter(s, f"{tag}i", x, y + 10, a, ab)
    x1 = x + 320
    p1 = s.mos(f"M{tag}p1", "pfet_g5v0d10v5", x1, y, 0.42, 1)
    p2 = s.mos(f"M{tag}p2", "pfet_g5v0d10v5", x1 + 300, y, 0.42, 1, flip=1)
    n1 = s.mos(f"M{tag}n1", "nfet_g5v0d10v5", x1, y + 140, 2, 0.5)
    n2 = s.mos(f"M{tag}n2", "nfet_g5v0d10v5", x1 + 300, y + 140, 2, 0.5, flip=1)
    L, R = x1 + 20, x1 + 280
    s.wire(p1["S"], (L, y - 60), (R, y - 60), p2["S"]); s.stub(((L + R) // 2, y - 60), "vpa", "up")
    s.wire(n1["S"], (L, y + 200), (R, y + 200), n2["S"]); s.stub(((L + R) // 2, y + 200), "vn", "down")
    s.wire(p1["D"], n1["D"]); s.wire(p2["D"], n2["D"])
    # Cross coupling: each PMOS gate is driven by the opposite output.
    s.wire(p1["G"], (x1 - 100, y), (x1 - 100, y + 70), (R, y + 70))
    s.wire(p2["G"], (x1 + 420, y), (x1 + 420, y + 90), (L, y + 90))
    s.lab((L, y + 45), yb_out, "left"); s.lab((R, y + 45), y_out, "right")
    s.stub(n1["G"], a, "left", 40); s.stub(n2["G"], ab, "right", 40)
    s.body(p1, "vpa", "right"); s.body(p2, "vpa", "left"); s.body(n1, "vn", "right"); s.body(n2, "vn", "left")


def main(out):
    s = Sch("VEXT test-input path (vext_path): pad switch, clamps and per-column reference switch")
    ports(s, ["vext", "vsel", "vg"], [], ["ref", "sum", "vpa", "vp", "vn"], x=-320, y0=-40)

    level_shifter(s, "ls1", 100, 100, "vsel", "vsel_h", "vsel_hb")
    level_shifter(s, "ls2", 100, 560, "vg", "vg_h", "vg_hb")
    s.text("level shifter: vsel (1.8 V) to vsel_h / vsel_hb (VDDA 3.3 V)", 30, -90, 0.3)
    s.text("level shifter: vg to vg_h (vg_hb unused)", 30, 370, 0.3)

    # vext_in: 5 V transmission gate from the pad, series resistor, clamp diodes to the 1.8 V rails.
    x, y = 1200, 100
    tgate(s, "pad", x, y, "vext", None, "vsel_h", "vsel_hb", model_n="nfet_g5v0d10v5", model_p="pfet_g5v0d10v5",
          wn=10, wp=10, l=0.5, vp="vpa")
    r = s.res("Rser", x + 120, y + 160, 1)
    s.wire((x + 120, y + 60), r["P"])
    s.stub(r["B"], "vn", "left", 40)
    core_y = y + 270
    s.wire(r["M"], (x + 120, core_y), (x + 260, core_y), (x + 380, core_y), (x + 640, core_y))
    dp = s.diode("Dclamp_p", x + 260, core_y - 30, "diode_pd2nw_05v5", "4e12", "8e6")   # anode core, cathode vp
    dn = s.diode("Dclamp_n", x + 380, core_y + 30, "diode_pw2nd_05v5", "4e12", "8e6")   # anode vn, cathode core
    s.stub(dp["d1"], "vp", "up"); s.stub(dn["d0"], "vn", "down")
    s.lab((x + 120, core_y - 40), "vxi", "left")
    s.text("pad switch: 5 V TG, on while vsel = 1", x - 70, y - 190, 0.3)
    s.text("series R (res_high_po_0p35)", x + 160, y + 120, 0.3)
    s.text("clamps to vp / vn", x + 230, core_y + 120, 0.3)

    # Per-column switch onto the replica reference bus, and its dummy on the sum bus.
    vr = s.mos("Mvx_ref", "nfet_g5v0d10v5", x + 620, core_y + 30, 4, 0.5)
    s.stub(vr["G"], "vg_h", "left", 40); s.stub(vr["S"], "ref", "down"); s.body(vr, "vn", "right")
    vs = s.mos("Mvx_sum", "nfet_g5v0d10v5", x + 920, core_y + 30, 4, 0.5)
    s.stub(vs["D"], "vn", "up"); s.stub(vs["G"], "vn", "left", 40); s.stub(vs["S"], "sum", "down"); s.body(vs, "vn", "right")
    s.text("reference switch (one per column)", x + 540, core_y + 140, 0.3)
    s.text("dummy on sum (always off)", x + 840, core_y + 140, 0.3)
    s.save(out)


if __name__ == "__main__":
    main(Path(sys.argv[1]))
