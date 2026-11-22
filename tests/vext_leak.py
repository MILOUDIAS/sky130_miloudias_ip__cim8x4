"""VEXT input path: off-state leakage from the shared line and on-state resistance. SPDX-License-Identifier: Apache-2.0"""
import argparse
import re
import subprocess
from pathlib import Path

CELLS = Path(__file__).resolve().parents[1] / "analog/cells.spice"


def network(pad_v, sel, gate, ref_v):
    """Level shifter, pad switch, resistor, clamps and four per-column switches into held reference buses."""
    lines = [f"Vpad vext 0 {pad_v}", f"Vsel vsel 0 {sel}", f"Vg vg 0 {gate}",
             "Xls vsel vsel_h vsel_hb vpa vp 0 ls_hv", "Xlsg vg vg_h vg_hb vpa vp 0 ls_hv",
             "Xin vext vxi vsel_h vsel_hb vpa vp 0 vext_in"]
    for c in range(4):
        lines += [f"Vref{c} ref{c} 0 {ref_v}", f"Xvx{c} vxi vg_h ref{c} 0 nvx"]
    return lines


def simulate(pdk, simulator, work, corner, vdd, temp):
    work = work.resolve()
    work.mkdir(parents=True, exist_ok=True)
    results = {}
    # Off: 3.3 V on the shared line, switches open, buses at mid-rail.
    # On: buses at 0.9 V, line 10 mV above, so R = 10 mV / I.
    for name, pad, sel, gate in (("off", 3.3, 0, 0), ("on", 0.91, vdd, vdd)):
        deck = ["VEXT input path", f'.lib "{pdk}" {corner}', f'.include "{CELLS}"', f".temp {temp}",
                f"Vdd vp 0 {vdd}", "Vdda vpa 0 3.3", *network(pad, sel, gate, 0.9),
                ".control", "op", "print i(Vpad) v(vxi) i(Vref0)", ".endc", ".end", ""]
        path = work / f"{name}.sp"
        path.write_text("\n".join(deck))
        out = subprocess.run([simulator, "-b", str(path)], capture_output=True, text=True, cwd=work, check=True).stdout
        (work / f"{name}.log").write_text(out)
        values = dict(re.findall(r"^(i\(vpad\)|v\(vxi\)|i\(vref0\))\s*=\s*([-+.\deE]+)", out, re.M | re.I))
        results[name] = {k.lower(): float(v) for k, v in values.items()}
    leak_na = abs(results["off"]["i(vpad)"]) * 1e9
    core_v = results["off"]["v(vxi)"]
    r_on = 0.01 / abs(results["on"]["i(vpad)"]) * 4  # four buses in parallel: per-column equivalent
    return dict(corner=corner, vdd=vdd, temp=temp, off_leak_nA=round(leak_na, 4), off_core_V=round(core_v, 4),
                on_path_kohm=round(r_on / 1000, 3))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--pdk", type=Path, required=True)
    p.add_argument("--ngspice", default="ngspice")
    p.add_argument("--work", type=Path, default=Path("build/vext_leak"))
    a = p.parse_args()
    rows = [simulate(a.pdk.resolve(), a.ngspice, a.work / f"{c}_{v}_{t}", c, v, t)
            for c, v, t in (("tt", 1.8, 25), ("ff", 1.9, 110), ("ss", 1.65, -40), ("sf", 1.9, 110), ("fs", 1.9, 110))]
    import csv
    a.work.mkdir(parents=True, exist_ok=True)
    with (a.work / "vext_leak.csv").open("w", newline="") as out:
        writer = csv.DictWriter(out, fieldnames=rows[0]); writer.writeheader(); writer.writerows(rows)
    for r in rows:
        print(r)
    worst = max(r["off_leak_nA"] for r in rows)
    print(f"worst off-state leakage {worst:.4f} nA; worst on-path resistance {max(r['on_path_kohm'] for r in rows):.2f} kOhm")
    return int(worst > 1.0)


if __name__ == "__main__":
    raise SystemExit(main())
