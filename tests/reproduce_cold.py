"""Compare the regular and low-threshold share switches in the directed cold sweep."""
# SPDX-License-Identifier: Apache-2.0
import argparse
import csv
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def run_variant(name, regular, args):
    work = args.work.resolve() / name
    source = work / "source"
    for subdir in ("tests", "analog"):
        (source / subdir).mkdir(parents=True, exist_ok=True)
    for path in ("tests/spice.py", "analog/generate.py", "analog/cells.spice"):
        shutil.copyfile(ROOT / path, source / path)
    if regular:
        path = source / "analog/cells.spice"
        cells = path.read_text()
        switch = "Xshare plate bus shr shrb vp vn tg_share"
        if cells.count(switch) != 1:
            raise RuntimeError("Cannot identify the production sharing-switch connection")
        path.write_text(cells.replace(switch, "Xshare plate bus shr shrb vp vn tg"))
    cmd = [sys.executable, str(source/"tests/spice.py"), "--pdk", str(args.pdk.resolve()),
           "--ngspice", args.ngspice, "--suite", "boundaries", "--columns", "1", "--corner", "ss",
           "--temp", "-40", "--vdd", "1.65", "--mhz", "1", "--work", str(work)]
    sim = subprocess.run(cmd)
    if sim.returncode not in (0,1):
        raise RuntimeError(f"{name} simulator failed ({sim.returncode})")
    with (work/"decisions.csv").open() as f:
        rows = list(csv.DictReader(f))
    if len(rows) != 48:
        raise RuntimeError("Incomplete boundary sweep")
    i, case = next((i,r) for i,r in enumerate(rows)
                   if (r["x"],r["weight"],r["k"],r["t"],r["frac"]) == ("0x7f","0xff","7","6","0.5"))
    log = (work/"ngspice.log").read_text()
    readings = {}
    for tag in ("s","r","y"):
        match = re.search(rf"^{tag}_{i}_0\s*=\s*([-+.\deE]+)",log,re.MULTILINE)
        if not match:
            raise RuntimeError(f"Missing {tag} measurement")
        readings[tag] = float(match[1])
    separation_mv = (readings["s"] - readings["r"])*1000
    if abs(separation_mv / (1650/16) - float(case["input_margin_steps"])) > 1e-5:
        raise RuntimeError("Node voltages disagree with the recorded normalized margin")
    failures = sum(r["passed"] != "True" for r in rows)
    if sim.returncode != int(bool(failures)):
        raise RuntimeError("Unexpected bench return code; inspect its log and retained weights")
    return dict(share_switch=name,corner="ss",vdd_V=1.65,temperature_C=-40,clock_MHz=1,
                X="0x7f",W="0xff",k=7,T=6,fraction=0.5,precompare_sample_ns=162390,
                sense_sum_V=readings["s"],sense_ref_V=readings["r"],separation_mV=round(separation_mv,3),
                count_step_mV=103.125,margin_steps=case["input_margin_steps"],digital_output_V=readings["y"],
                meets_0p20_step=case["passed"],sweep_cases=48,sweep_failures=failures)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pdk", type=Path, required=True)
    parser.add_argument("--ngspice", default="ngspice")
    parser.add_argument("--work", type=Path, default=Path("build/cold_ab"))
    args = parser.parse_args()
    results = [run_variant(name, regular, args) for name,regular in (("regular",True),("low_threshold",False))]
    summary = args.work/"cold_switch_comparison.csv"
    with summary.open("w",newline="") as f:
        w = csv.DictWriter(f,fieldnames=results[0]); w.writeheader(); w.writerows(results)
    for row in results:
        print(f"{row['share_switch']}: {row['separation_mV']:.3f} mV; {row['margin_steps']} step")
    print(summary)


if __name__ == "__main__":
    main()
