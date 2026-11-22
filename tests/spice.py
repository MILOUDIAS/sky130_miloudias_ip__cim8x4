"""Exercise the MOS/MiM array in ngspice. No Python dependencies. SPDX-License-Identifier: Apache-2.0"""
import argparse
import csv
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "analog"))
from generate import array, names, instance


def new_signals(columns):
    return {s: {} for s in ["sam","shr","ev","vsel","vg"] + names("x",8) + names("wr",8)
            + names("d",columns) + names("coarse",7) + names("fine",4)}


def bench_stimulus(columns, period, cases, masks):
    signals = new_signals(columns)
    def put(name, t, value):
        signals[name][t] = int(value)

    for row in range(8):
        start = 10 + 40 * row
        for c, mask in enumerate(masks):
            put(f"d{c}", start, (mask >> row) & 1)
        put(f"wr{row}", start + 6, 1)
        put(f"wr{row}", start + 28, 0)

    for i, (x, threshold, quarters) in enumerate(cases):
        t = 400 + i * 4 * period
        external = quarters is None  # FRAC = 11: compare against VEXT instead of the replica
        for r in range(8):
            put(f"x{r}", t, (x >> r) & 1)
        for j in range(7):
            put(f"coarse{j}", t, j < threshold)
        for j in range(4):
            put(f"fine{j}", t, j < (2 if external else quarters))
        put("vsel", t, external)
        phases = [("sam", 0.5, 1), ("shr", 1.5, 3.5), ("ev", 2, 3)]
        if external:
            phases.append(("vg", 1.5, 3.5))
        for name, rise, fall in phases:
            put(name, t + rise * period, 1)
            put(name, t + fall * period, 0)
    compare_times = [400+(4*i+2)*period for i in range(len(cases))]
    return signals, compare_times


def read_rtl_trace(path):
    # The replay fixture programs all eight rows once, then issues evaluation commands.
    signals=new_signals(4)
    groups={"x":8,"wr":8,"d":4,"coarse":7,"fine":4}
    rows={}; cases=[]; edges=[]
    prev_ev=0
    with path.open() as f:
        for entry in csv.DictReader(f):
            row={k:int(v) for k,v in entry.items()}
            time=row["ns"]
            for name,width in groups.items():
                for bit in range(width):
                    signals[f"{name}{bit}"][time]=(row[name]>>bit)&1
            for name in ("sam","shr","ev","vsel","vg"):
                if name in row:
                    signals[name][time]=row[name]
            if row["wr"]:
                assert not cases and row["wr"].bit_count()==1, "expected programming before evaluations"
                rows[row["wr"].bit_length()-1]=row["d"]
            if row["ev"] and not prev_ev:
                edges.append(time)
                cases.append((row["x"],row["coarse"].bit_count(),row["fine"].bit_count()))
            prev_ev=row["ev"]
    if len(rows)!=8 or not cases:
        raise ValueError("incomplete RTL trace")
    masks=[sum(((rows[r]>>c)&1)<<r for r in range(8)) for c in range(4)]
    return signals,edges,cases,masks


def deck(pdk, columns, corner, vdd, temp, period, work, signals, compare_times, seed, guard_steps=0, cases=(), masks=(),
         vdda=3.3, vext_source="3.3", reltol=0.001, probe=False):
    work.mkdir(parents=True, exist_ok=True)
    netlist = array(columns)
    if guard_steps:
        # Test-only equal/opposite series voltages retain the floating buses and input gate loads.
        # Change the perturbation before sampling, while the previous compare is in reset.
        for col, mask in enumerate(masks):
            positive = ["0 0"]
            negative = ["0 0"]
            last = 0.0
            for t, (x, threshold, _) in zip(compare_times, cases):
                direction = -1 if (x & mask).bit_count() > threshold else 1
                bias = direction * guard_steps * (vdd / 16) / 2
                start = t - 2 * period
                for seq, sign in ((positive, 1), (negative, -1)):
                    seq.extend([f"{start:.4f}n {sign*last:.10g}", f"{start+0.5:.4f}n {sign*bias:.10g}"])
                last = bias
            old = f"Xcmp{col} sum{col} ref{col} ev"
            assert netlist.count(old) == 1
            new = (f"Vs_off{col} sense{col} sum{col} PWL({' '.join(positive)})\n"
                   f"Vr_off{col} reference{col} ref{col} PWL({' '.join(negative)})\n"
                   f"Xcmp{col} sense{col} reference{col} ev")
            netlist = netlist.replace(old, new)
    (work / "array.spice").write_text(netlist)
    nodes = ["vp", "0", "sam", "shr", "ev"] + names("x", 8) + names("wr", 8) + names("d", columns)
    nodes += names("coarse", 7) + names("fine", 4) + names("y", columns) + names("q", 8 * columns)
    nodes += ["vpa", "vext", "vsel", "vg"]
    lines = ["SKY130 charge sharing - generated transistor-level test",
             f'.lib "{pdk}" {corner}',f'.include "{ROOT / "analog/cells.spice"}"',
             f'.include "{work / "array.spice"}"', f".temp {temp}", f".options method=gear reltol={reltol}",
             f"Vsupply vp 0 {vdd}", f"Vanalog vpa 0 {vdda}", f"Vext vext 0 {vext_source}",
             instance("dut", nodes, "acim_array")]
    if seed is not None:
        if seed <= 0:
            raise ValueError("Use a positive mismatch seed.")
        lines.insert(1,f".option seed={seed}")
    measurements = []
    for i, t in enumerate(compare_times):
        for c in range(columns):
            for tag, node, clock in [("s", f"xdut.sum{c}", -0.01), ("r", f"xdut.ref{c}", -0.01),
                                     ("sa", f"xdut.sum{c}", 0.06), ("ra", f"xdut.ref{c}", 0.06),
                                     ("y", f"y{c}", 0.97)]:
                measurements.append(f".meas tran {tag}_{i}_{c} FIND v({node}) AT={t+clock*period:.4f}n")
            if guard_steps:
                for tag, node, clock in [("pinp", f"xdut.sense{c}", -0.01), ("pinn", f"xdut.reference{c}", -0.01),
                                         ("left", f"xdut.xcmp{c}.ol", 0.97), ("right", f"xdut.xcmp{c}.oright", 0.97)]:
                    measurements.append(f".meas tran {tag}_{i}_{c} FIND v({node}) AT={t+clock*period:.4f}n")
    stop = compare_times[-1] + 2*period
    for j in range(columns * 8):
        measurements.append(f".meas tran q_{j} FIND v(q{j}) AT={stop-5:.4f}n")

    for name, changes in signals.items():
        value = 0
        pairs = ["0 0"]
        for time, new in sorted(changes.items()):
            if new != value:
                pairs.extend([f"{time:.4f}n {value*vdd:g}", f"{time+0.5:.4f}n {new*vdd:g}"])
                value = new
        lines.append(f"V_{name} {name} 0 PWL(" + " ".join(pairs) + ")")
    saved = names("q", columns*8) + names("y", columns) + names("xdut.sum", columns) + names("xdut.ref", columns)
    if guard_steps:
        for c in range(columns):
            saved.extend([f"xdut.sense{c}", f"xdut.reference{c}", f"xdut.xcmp{c}.ol", f"xdut.xcmp{c}.oright"])
    if probe:
        saved += [f"xdut.xcmp{c}.{n}" for c in range(columns) for n in ("ol", "oright", "ml", "mr", "tail")] + ["xdut.vxi"]
    lines += [".save " + " ".join(f"v({n})" for n in saved), f".tran 10n {stop:.4f}n 0 12n"]
    (work / "bench.sp").write_text("\n".join(lines + measurements + [".end", ""]))


def run(args):
    work = args.work.resolve()
    cases = [(0xff, 7, 2), (0, 0, 2), (0xff, 0, 2), (0x55, 3, 2), (0xaa, 4, 2),
             (0x80, 0, 3), (0x01, 1, 1)]
    if args.suite == "quick":
        cases = cases[:2]
    elif args.suite == "boundaries":
        cases = [(((1 << (t + side)) - 1), t, q) for t in range(8) for side in [0, 1] for q in [1, 2, 3]]
    elif args.suite == "rotated":
        # Eight circular permutations have identical k but activate different physical rows.
        cases = [(((0x0f << r) | (0x0f >> (8-r))) & 0xff, t, 2)
                 for r in range(8) for t in [3,4]]
    masks = [0xff, 0x0f, 0x55, 0x80][:args.columns]
    if args.suite == "application":
        if args.columns != 4:
            raise ValueError("the application uses four columns")
        masks = [0x0f, 0x33, 0x55, 0xf0]
        cases = [(0x0f, 2, 2)] + [(1 << r, 0, 2) for r in range(8)]
    if args.suite == "midpoints":
        cases = [((1 << (t + side)) - 1, t, 2) for t in range(8) for side in (0, 1)]
    vext_values = []
    if args.suite == "vext":
        if args.columns != 1:
            raise ValueError("the VEXT level map uses one column")
        masks = [0xff]
        cases = []
        steps = int(round(args.vext_window_mv / args.vext_step_mv))
        for k in (range(args.vext_from_k, 9) if args.vext_k is None else [args.vext_k]):
            centre = args.vdd * (4 + args.vext_gain * k) / 16
            for n in range(-steps, steps + 1):
                cases.append(((1 << k) - 1, 0, None))
                vext_values.append(round(centre + n * args.vext_step_mv / 1000, 6))
    if args.guard_steps < 0 or (args.guard_steps and (args.suite != "midpoints" or args.rtl_trace)):
        raise ValueError("use a nonnegative guard with the midpoint sequence")
    corner = args.corner + ("_mm" if args.seed is not None else "")
    period = 1000 / args.mhz
    if args.rtl_trace:
        if args.columns != 4 or args.mhz != 1:
            raise ValueError("the RTL trace fixture uses four columns at 1 MHz")
        signals, edges, cases, masks = read_rtl_trace(args.rtl_trace)
    else:
        signals, edges = bench_stimulus(args.columns, period, cases, masks)
    vext_source = str(args.vext_dc)
    if vext_values:
        pairs = [f"0 {vext_values[0]}"]
        for i in range(1, len(vext_values)):
            t = edges[i] - 2 * period  # case start, before sampling
            pairs.extend([f"{t:.4f}n {vext_values[i-1]}", f"{t+0.5:.4f}n {vext_values[i]}"])
        vext_source = "PWL(" + " ".join(pairs) + ")"
    deck(args.pdk.resolve(), args.columns, corner, args.vdd, args.temp, period, work, signals, edges, args.seed,
         args.guard_steps, cases, masks, args.vdda, vext_source,
         args.reltol, args.probe)
    simulator = shutil.which(args.ngspice)
    if not simulator:
        raise SystemExit("Set --ngspice to the ngspice executable.")
    with (work / "ngspice.log").open("w") as log:
        subprocess.run([str(Path(simulator).resolve()), "-n", "-b", str(work/"bench.sp")],
                       stdout=log, stderr=subprocess.STDOUT, cwd=work, check=True)
    log = (work / "ngspice.log").read_text(errors="replace")
    vals = {name: float(val) for name,val in re.findall(r"^([a-z]+_\d+(?:_\d+)?)\s*=\s*([-+.\deE]+)", log, re.M)}
    if not vals:
        raise RuntimeError(f"No measurements found in {work}/ngspice.log")
    if args.suite == "vext":
        return vext_report(args, corner, cases, vext_values, masks, vals, work)
    results = []
    for i, (x, threshold, quarters) in enumerate(cases):
        for c, mask in enumerate(masks):
            k = (x & mask).bit_count()
            expected = int(k > threshold)
            polarity = 1 if expected else -1
            step = args.vdd/16
            before = vals[f"s_{i}_{c}"] - vals[f"r_{i}_{c}"]
            after = vals[f"sa_{i}_{c}"] - vals[f"ra_{i}_{c}"]
            output = vals[f"y_{i}_{c}"]
            rail_ok = output >= 0.8*args.vdd if expected else output <= 0.2*args.vdd
            margin = polarity * before / step
            passed = rail_ok and margin >= (0.2 if quarters == 2 else 0)
            evidence = {}
            if args.guard_steps:
                pins = vals[f"pinp_{i}_{c}"] - vals[f"pinn_{i}_{c}"]
                applied = polarity * (before - pins) / step
                left, right = vals[f"left_{i}_{c}"], vals[f"right_{i}_{c}"]
                low, high = 0.2 * args.vdd, 0.8 * args.vdd
                resolved = (left <= low and right >= high) if expected else (left >= high and right <= low)
                passed = passed and abs(applied - args.guard_steps) < 0.0001 and resolved
                evidence = dict(applied_adverse_steps=round(applied,6),left_v=left,right_v=right)
            results.append(dict(corner=corner,seed=args.seed,vdd=args.vdd,temp=args.temp,mhz=args.mhz,
                                column=c,x=hex(x),weight=hex(mask),k=k,t=threshold,frac=quarters/4,
                                expected=expected,output_v=output,guard_steps=args.guard_steps,input_margin_steps=round(margin,6),
                                kick_diff_mv=round(1000*(after-before),5),passed=passed,**evidence))
    with (work/"decisions.csv").open("w",newline="") as out:
        writer=csv.DictWriter(out,fieldnames=results[0]);writer.writeheader();writer.writerows(results)
    errors = sum(not r["passed"] for r in results)
    weight_errors = retained_errors(args, masks, vals)
    mid = [r["input_margin_steps"] for r in results if r["frac"]==0.5]
    print(f"{len(results)} decisions, {errors} failed; {8*args.columns} retained bits, {weight_errors} failed; "
          f"minimum midpoint input margin {min(mid):.4f} step; max |differential change after evaluate| "
          f"{max(abs(r['kick_diff_mv']) for r in results):.3f} mV")
    return int(bool(errors or weight_errors))


def retained_errors(args, masks, vals):
    errors = 0
    for r in range(8):
        for c, mask in enumerate(masks):
            q = vals[f"q_{r*args.columns+c}"]
            want = (mask >> r) & 1
            errors += int(not (q >= 0.8*args.vdd if want else q <= 0.2*args.vdd))
    return errors


def vext_report(args, corner, cases, vext_values, masks, vals, work):
    """Level map: sweep VEXT around each count's sum voltage and locate the comparator trip."""
    rows = []
    for i, ((x, _, _), v) in enumerate(zip(cases, vext_values)):
        y = vals[f"y_{i}_0"]
        bit = 1 if y >= 0.8*args.vdd else 0 if y <= 0.2*args.vdd else None
        rows.append(dict(corner=corner, seed=args.seed, vdd=args.vdd, temp=args.temp, mhz=args.mhz,
                         k=(x & masks[0]).bit_count(), vext_v=v, sum_v=vals[f"s_{i}_0"], ref_v=vals[f"r_{i}_0"],
                         output_v=y, bit=bit))
    with (work/"vext_cases.csv").open("w", newline="") as out:
        writer = csv.DictWriter(out, fieldnames=rows[0]); writer.writeheader(); writer.writerows(rows)
    summary, problems = [], []
    for k in sorted({r["k"] for r in rows}):
        points = sorted((r["vext_v"], r["bit"]) for r in rows if r["k"] == k)
        ones = [v for v, b in points if b == 1]
        zeros = [v for v, b in points if b == 0]
        if any(b is None for _, b in points):
            problems.append(f"k={k}: unresolved output")
        if not ones or not zeros or max(ones) > min(zeros):
            problems.append(f"k={k}: trip not bracketed or not monotonic")
            continue
        sums = [r["sum_v"] for r in rows if r["k"] == k]
        trip = (max(ones) + min(zeros)) / 2
        summary.append(dict(corner=corner, vdd=args.vdd, temp=args.temp, k=k, ideal_v=round(args.vdd*(4+k)/16, 6),
                            sum_v=round(sum(sums)/len(sums), 6), trip_v=round(trip, 6),
                            trip_minus_sum_mv=round(1000*(trip - sum(sums)/len(sums)), 3)))
    if summary:
        with (work/"vext_levels.csv").open("w", newline="") as out:
            writer = csv.DictWriter(out, fieldnames=summary[0]); writer.writeheader(); writer.writerows(summary)
    settle_mv = max(abs(r["ref_v"] - r["vext_v"]) for r in rows) * 1000
    weight_errors = retained_errors(args, masks, vals)
    if len(summary) > 1:
        steps = [1000*(b["trip_v"] - a["trip_v"]) for a, b in zip(summary, summary[1:])]
        sum_steps = [1000*(b["sum_v"] - a["sum_v"]) for a, b in zip(summary, summary[1:])]
        print(f"VEXT level map: {len(rows)} evaluations; trip step {min(steps):.1f}-{max(steps):.1f} mV "
              f"(sum step {min(sum_steps):.2f}-{max(sum_steps):.2f} mV, ideal {1000*args.vdd/16:.2f} mV); "
              f"trip minus sum {min(s['trip_minus_sum_mv'] for s in summary):.1f} to "
              f"{max(s['trip_minus_sum_mv'] for s in summary):.1f} mV; reference bus within {settle_mv:.3f} mV of VEXT; "
              f"{weight_errors} retained-bit errors")
    for problem in problems:
        print(problem)
    return int(bool(problems or weight_errors or settle_mv > 1.0))


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--pdk", type=Path, required=True, help="open_pdks libs.tech/ngspice/sky130.lib.spice")
    p.add_argument("--ngspice", default="ngspice")
    p.add_argument("--corner", choices=("tt","ss","ff","sf","fs"), default="tt")
    p.add_argument("--vdd", type=float, default=1.8)
    p.add_argument("--temp", type=float, default=25)
    p.add_argument("--mhz", type=float, choices=(0.5,1.0), default=1.0)
    p.add_argument("--columns", type=int, choices=(1,4), default=4)
    p.add_argument("--suite", choices=("quick","directed","boundaries","rotated","application","midpoints","vext"), default="directed")
    p.add_argument("--vdda", type=float, default=3.3, help="3.3 V supply of the VEXT level shifter")
    p.add_argument("--vext-dc", type=float, default=3.3, help="shared-line voltage while the VEXT switch is off")
    p.add_argument("--vext-gain", type=float, default=0.985, help="sweep centre VDD*(4+gain*k)/16; about 0.95 at the hot corner")
    p.add_argument("--vext-window-mv", type=float, default=45)
    p.add_argument("--vext-step-mv", type=float, default=3)
    p.add_argument("--vext-k", type=int, choices=range(9), help="map one count only")
    p.add_argument("--vext-from-k", type=int, choices=range(9), default=0,
                   help="lowest count to map; at SS/-40 C the k=0 sum (0.41 V) is below the comparator's input range")
    p.add_argument("--reltol", type=float, default=1e-4,
                   help="solver tolerance; 1e-3 can flip comparator decisions near regeneration, so 1e-4 is the sign-off default")
    p.add_argument("--probe", action="store_true", help="also save comparator internal nodes")
    p.add_argument("--guard-steps", type=float, default=0, help="adverse comparator input perturbation in units of VDD/16")
    p.add_argument("--rtl-trace", type=Path, help="replay CSV pin transitions recorded by controller_tb")
    p.add_argument("--seed", type=int, help="enable the PDK local mismatch corner with this positive seed")
    p.add_argument("--work", type=Path, default=Path("build/spice"))
    sys.exit(run(p.parse_args()))
