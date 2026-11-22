"""Clocked comparator trip brackets at controlled common modes. SPDX-License-Identifier: Apache-2.0"""
import argparse
import csv
import re
import subprocess
from pathlib import Path

CELLS = Path(__file__).resolve().parents[1] / "analog/cells.spice"
COMMON_MODES = (0.32, 0.50, 0.68)
# Sweep twice on the same device sample to expose history dependence.
GRID_MV = [i / 2 for i in range(-50, 51)]


def trip_sweep(pdk, simulator, work, corner, vdd, temp, seed):
    work.mkdir(parents=True, exist_ok=True)
    model = corner if seed is None else corner + "_mm"
    deck = ["Clocked comparator trip bracket", f'.lib "{pdk}" {model}',
            f'.include "{CELLS}"', f".temp {temp}", ".options method=gear reltol=0.0001",
            f"Vdd vp 0 {vdd}", "Xcmp sig ref ev y vp 0 compare",
            f"Vev ev 0 PULSE(0 {vdd} 1000n 0.5n 0.5n 999.5n 4000n)"]
    if seed is not None:
        deck.insert(1, f".option seed={seed}")
    stimuli = []
    for cm in COMMON_MODES:
        for direction in ("up", "down"):
            for delta in (GRID_MV if direction == "up" else reversed(GRID_MV)):
                stimuli.append((cm, direction, delta))
    for name, sign in (("sig", 1), ("ref", -1)):
        source = []
        for i, (cm, _, delta) in enumerate(stimuli):
            value = vdd * cm + sign * delta / 2000
            at = i * 4000
            if i:
                source.extend([f"{at}n {previous:.9f}", f"{at+1}n {value:.9f}"])
            else:
                source.append(f"0 {value:.9f}")
            previous = value
        deck.append(f"V{name} {name} 0 PWL({' '.join(source)})")
    deck.extend([".save v(y) v(xcmp.ol) v(xcmp.oright)", f".tran 50n {len(stimuli)*4000}n 0 50n"])
    for i in range(len(stimuli)):
        for tag, node in (("y","y"), ("l","xcmp.ol"), ("r","xcmp.oright")):
            deck.append(f".meas tran {tag}_{i} find v({node}) at={i*4000+1970}n")
    deck.extend([".end",""])
    path = work/"offset.sp"
    path.write_text("\n".join(deck))
    with (work/"ngspice.log").open("w") as log:
        subprocess.run([simulator, "-n", "-b", str(path)], stdout=log, stderr=subprocess.STDOUT, check=True, cwd=work)
    log = (work/"ngspice.log").read_text()
    measured = {key:float(value) for key,value in re.findall(r"^([ylr]_\d+)\s*=\s*([-+.\deE]+)",log,re.M)}
    groups = {}
    for i, (cm, direction, delta) in enumerate(stimuli):
        left, right, y = (measured[f"{tag}_{i}"] for tag in ("l","r","y"))
        low, high = 0.2*vdd, 0.8*vdd
        bit = None
        if left <= low and right >= high and y >= high:
            bit = 1
        elif left >= high and right <= low and y <= low:
            bit = 0
        groups.setdefault((cm,direction), []).append((delta, bit))
    results = []
    for (cm,direction), samples in groups.items():
        zeros = [x for x,bit in samples if bit == 0]
        ones = [x for x,bit in samples if bit == 1]
        if not zeros or not ones or max(zeros) >= min(ones):
            raise ValueError(f"missing or nonmonotonic trip bracket at {cm}, sweep {direction}")
        lo, hi = max(zeros), min(ones)
        if any(bit is None and not lo < x < hi for x,bit in samples):
            raise ValueError(f"unresolved decision outside the bracket at {cm}, sweep {direction}")
        results.append(dict(corner=model,seed=seed,vdd=vdd,temp_C=temp,common_v=round(cm*vdd,6),
                            direction=direction,low_mV=lo,high_mV=hi))
    with (work/"trip.csv").open("w",newline="") as out:
        writer=csv.DictWriter(out, fieldnames=results[0]); writer.writeheader(); writer.writerows(results)
    print(f"{model} seed={seed} | trip bracket envelope {min(r['low_mV'] for r in results):g} to "
          f"{max(r['high_mV'] for r in results):g} mV over six sweeps")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pdk", type=Path, required=True)
    parser.add_argument("--ngspice", default="ngspice")
    parser.add_argument("--work", type=Path, default=Path("build/offset"))
    parser.add_argument("--corner", choices=("tt","ss","ff","sf","fs"), default="tt")
    parser.add_argument("--vdd", type=float, default=1.8)
    parser.add_argument("--temp", type=float, default=25)
    parser.add_argument("--seed", type=int)
    args=parser.parse_args()
    if args.seed is not None and args.seed <= 0:
        parser.error("choose a positive mismatch seed")
    trip_sweep(args.pdk.resolve(), args.ngspice, args.work.resolve(), args.corner, args.vdd, args.temp, args.seed)
