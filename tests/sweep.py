"""Reproduce the schematic regression matrix. SPDX-License-Identifier: Apache-2.0"""
import argparse
import itertools
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path


def suites():
    tests = [
        ("full_tt", "tt", 1.8, 25, 1, 4, "directed", None),
        ("boundary_tt", "tt", 1.8, 25, 1, 1, "boundaries", None),
        ("slowdirect", "ss", 1.65, -40, 0.5, 1, "directed", None),
        ("hotdirect", "ff", 1.9, 110, 0.5, 1, "directed", None),
        ("boundary_cold", "ss", 1.65, -40, 1, 1, "boundaries", None),
        ("boundary_hot", "ff", 1.9, 110, 0.5, 1, "boundaries", None),
        ("rotated", "tt", 1.8, 25, 1, 1, "rotated", None),
    ]
    for c,v,t in itertools.product(("tt","ss","ff","sf","fs"),(1.65,1.8,1.9),(-40,25,110)):
        tests.append((f"grid_{c}_{v}_{t}",c,v,t,1,1,"quick",None))
    for seed in range(101,109):
        tests.append((f"mismatch_{seed}","tt",1.8,25,1,1,"directed",seed))
    tests.append(("repeat_101","tt",1.8,25,1,1,"directed",101))
    return tests


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pdk",type=Path,required=True)
    parser.add_argument("--ngspice",default="ngspice")
    parser.add_argument("--jobs",type=int,default=1)
    parser.add_argument("--work",type=Path,default=Path("build/sweep"))
    args=parser.parse_args()

    def run_case(case):
        name,corner,vdd,temp,mhz,columns,suite,seed=case
        cmd=[sys.executable,str(Path(__file__).with_name("spice.py")),"--pdk",str(args.pdk),
             "--ngspice",args.ngspice,"--corner",corner,"--vdd",str(vdd),"--temp",str(temp),
             "--mhz",str(mhz),"--columns",str(columns),"--suite",suite,"--work",str(args.work/name)]
        if seed is not None: cmd.extend(["--seed",str(seed)])
        run=subprocess.run(cmd,text=True,capture_output=True)
        print(name,run.stdout.strip(),run.stderr.strip(),flush=True)
        return run.returncode

    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        outcomes=list(pool.map(run_case,suites()))
    if any(outcomes): return 1
    first=args.work/"mismatch_101/decisions.csv"
    repeat=args.work/"repeat_101/decisions.csv"
    if first.read_bytes()!=repeat.read_bytes():
        raise RuntimeError("Mismatch seed 101 did not reproduce its measurements")
    return 0


if __name__=="__main__":
    sys.exit(main())
