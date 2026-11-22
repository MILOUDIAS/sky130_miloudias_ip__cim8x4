"""Emit the standalone SKY130 analog array subcircuit. SPDX-License-Identifier: Apache-2.0"""
import argparse
from pathlib import Path


def names(prefix, count):
    return [f"{prefix}{i}" for i in range(count)]


def instance(label, ports, kind):
    return f"X{label} " + " ".join(ports) + " " + kind


def array(columns=4):
    """Ports are index-ascending; q[row*columns+column] is buffered readback.

    The last four ports carry the test-only external reference: vpa (3.3 V), vext (shared
    analog line), vsel (1.8 V enable of the pad-side switch) and vg (per-column gate)."""
    rows = 8
    ports = (["vp", "vn", "sam", "shr", "ev"] + names("x", rows) + names("wr", rows)
             + names("d", columns) + names("coarse", 7) + names("fine", 4)
             + names("y", columns) + names("q", rows * columns) + ["vpa", "vext", "vsel", "vg"])
    lines = ["* Generated regular array. Include cells.spice before use.",
             ".subckt acim_array " + " ".join(ports)]
    for enable in ["sam", "shr"] + names("wr", rows):
        lines.append(f"Xi_{enable} {enable} {enable}b vp vn inv")
    lines.append("Xls_vsel vsel vsel_h vsel_hb vpa vp vn ls_hv")
    lines.append("Xls_vg vg vg_h vg_hb vpa vp vn ls_hv")
    lines.append("Xvext_in vext vxi vsel_h vsel_hb vpa vp vn vext_in")

    for col in range(columns):
        src = []
        for row in range(rows):
            q = f"q{row * columns + col}"
            prod = f"prod_{row}_{col}"
            lines.append(f"Xw_{row}_{col} d{col} wr{row} wr{row}b {q} vp vn weight")
            lines.append(f"Xand_{row}_{col} x{row} {q} {prod} vp vn and2")
            src.append(prod)
        # Equal switch count, capacitor tiling, reset path and comparator fanout on both sides.
        for side, full, quarter in [
            ("sum", src[:7], [src[7]] * 4),
            ("ref", names("coarse", 7), names("fine", 4)),
        ]:
            bus = f"{side}{col}"
            lines.append(f"Xclear_{bus} vn {bus} sam samb vp vn tg")
            branches = [(s, 4) for s in full] + [(s, 1) for s in quarter]
            branches += [("vp", 4)] * 4 + [("vn", 4)] * 4
            for index, (source, size) in enumerate(branches):
                lines.append(f"Xc_{bus}_{index} {source} {bus} sam samb shr shrb vp vn sample_cap size={size}")
        # VEXT reaches the reference bus through one switch; an always-off twin loads the sum bus equally.
        lines.append(f"Xvx_ref{col} vxi vg_h ref{col} vn nvx")
        lines.append(f"Xvx_sum{col} vn vn sum{col} vn nvx")
        lines.append(f"Xcmp{col} sum{col} ref{col} ev y{col} vp vn compare")
    return "\n".join(lines + [".ends acim_array", ""])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    args.output.write_text(array())
