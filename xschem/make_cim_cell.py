"""Transistor-level xschem schematic of one compute cell (subckt `cim_cell`). SPDX-License-Identifier: Apache-2.0

cim_cell = weight (cells.spice `weight`) + AND (`and2`) + switched unit capacitor (`sample_cap size=4`),
exactly the three instances generate.py places per array cell.
"""
import sys
from pathlib import Path
from sch import Sch, inverter, tgate, ports


def nand(s, x, y, a, b, out_end):
    """NAND2 of cells.spice `and2`: parallel PMOS, series NMOS. Output rail at y+60, extended to out_end."""
    pa = s.mos("Mnd_pa", "pfet_01v8", x, y, 2, 0.15)
    pb = s.mos("Mnd_pb", "pfet_01v8", x + 240, y, 2, 0.15)
    na = s.mos("Mnd_na", "nfet_01v8", x + 120, y + 150, 1, 0.15)
    nb = s.mos("Mnd_nb", "nfet_01v8", x + 120, y + 260, 1, 0.15)
    s.wire(pa["S"], (x + 20, y - 60), (x + 260, y - 60), pb["S"]); s.stub((x + 140, y - 60), "vp", "up")
    s.wire(pa["D"], (x + 20, y + 60), (x + 140, y + 60)); s.wire((x + 140, y + 60), (x + 260, y + 60), pb["D"])
    s.wire((x + 260, y + 60), out_end)
    s.wire((x + 140, y + 60), na["D"])
    s.wire(na["S"], nb["D"])
    s.wire(nb["S"], (x + 140, y + 310)); s.lab((x + 140, y + 310), "vn", "down")
    s.stub(pa["G"], a, "left"); s.stub(pb["G"], b, "left")
    s.stub(na["G"], a, "left", 40); s.stub(nb["G"], b, "left", 40)
    for d, net in ((pa, "vp"), (pb, "vp"), (na, "vn"), (nb, "vn")):
        s.body(d, net, "right")


def main(out):
    s = Sch("Compute cell (cim_cell): 1-bit weight, AND with activation x, switched 4-unit MIM capacitor")
    ports(s, ["d", "wr", "wrb", "x", "sam", "samb", "shr", "shrb"], ["q"], ["bus", "vp", "vn"], x=-320, y0=-40)

    # Row 1: weight bit.
    y1 = 100
    tgate(s, "wr", 100, y1, "d", "hold", "wr", "wrb")
    tgate(s, "fb", 600, y1, "qs", "hold", "wrb", "wr")
    inverter(s, "l1", 1120, y1 - 60, "hold", "qb")
    inverter(s, "l2", 1400, y1 - 60, "qb", "qs")
    inverter(s, "r1", 1680, y1 - 60, "qs", "nbuf")
    inverter(s, "r2", 1960, y1 - 60, "nbuf", "q")
    s.text("write TG (open while wr = 1)", 30, y1 - 190, 0.3)
    s.text("keeper TG (closes the loop while wr = 0)", 520, y1 - 190, 0.3)
    s.text("storage latch (hold / qb / qs)", 1060, y1 - 190, 0.3)
    s.text("read-back buffer: q = stored bit", 1620, y1 - 190, 0.3)

    # Row 2: AND and the switched capacitor.
    y2 = 620
    nand(s, 100, y2, "x", "q", (480, y2 + 60))
    inverter(s, "and", 550, y2, "nand", "prod")
    tgate(s, "sam", 1000, y2 + 60, "prod", "plate", "sam", "samb")
    tgate(s, "shr", 1500, y2 + 60, "plate", "bus", "shr", "shrb", model_n="nfet_01v8_lvt", model_p="pfet_01v8_lvt")
    c = s.cap("Cunit", 2000, y2 + 60, 5, 5, MF=4)
    s.stub(c["top"], "plate", "up"); s.stub(c["bot"], "vn", "down")
    s.text("AND: NAND2 + inverter, prod = x AND q", 30, y2 - 150, 0.3)
    s.text("sample TG (prod onto plate)", 930, y2 - 150, 0.3)
    s.text("share TG, low-Vt (plate onto column bus)", 1420, y2 - 150, 0.3)
    s.text("unit capacitor: 4 x MIM 5 um x 5 um", 1900, y2 - 150, 0.3)
    s.save(out)


if __name__ == "__main__":
    main(Path(sys.argv[1]))
