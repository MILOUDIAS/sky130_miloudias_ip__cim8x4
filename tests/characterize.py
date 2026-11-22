"""Reproduce the application, trip brackets and adverse-margin tests. SPDX-License-Identifier: Apache-2.0"""
import argparse
import subprocess
import sys
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--pdk", type=Path, required=True)
parser.add_argument("--ngspice", default="ngspice")
parser.add_argument("--work", type=Path, default=Path("build/characterization"))
args = parser.parse_args()
common = ["--pdk", str(args.pdk.resolve()), "--ngspice", args.ngspice]


def run(script, name, *options):
    subprocess.run([sys.executable, str(Path(__file__).with_name(script)), *common,
                    "--work", str(args.work / name), *options], check=True)


run("spice.py", "application", "--suite", "application")
for corner, voltage, temperature in [("tt", "1.80", "25"), ("ss", "1.65", "-40"), ("ff", "1.90", "110")]:
    seeds = [None] if corner == "ff" else [None, *range(101,109)]
    for seed in seeds:
        name = corner if seed is None else f"{corner}{seed}"
        params = ["--corner", corner, "--vdd", voltage, "--temp", temperature]
        if seed is not None:
            params += ["--seed", str(seed)]
        run("spice.py", f"guard_{name}", "--columns", "1", "--suite", "midpoints", "--guard-steps", "0.20", *params)
        run("offset.py", f"offset_{name}", *params)
