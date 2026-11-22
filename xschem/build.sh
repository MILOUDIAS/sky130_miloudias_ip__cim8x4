#!/usr/bin/env bash
# Generate, LVS-check and render the transistor-level schematics. SPDX-License-Identifier: Apache-2.0
# Needs PDK_ROOT (sky130A), xschem, netgen, xvfb-run, rsvg-convert and python3 with Pillow.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p out
SETUP="$PDK_ROOT/sky130A/libs.tech/netgen/sky130A_setup.tcl"
NETGEN=$(command -v netgen-lvs || command -v netgen)
# Reference netlist: cells.spice with sample_cap's size parameter resolved, plus the per-column composites.
sed -e 's/ params: size=4//' -e 's/{size}/4/g' ../analog/cells.spice > out/ref.spice
cat ref_composites.spice >> out/ref.spice
for cell in compare cim_cell vext_path; do
    rm -f "out/${cell}.spice" "out/lvs_${cell}.out" "out/${cell}.svg" "out/${cell}.png"
    python3 "make_${cell}.py" "${cell}.sch"
    xschem --rcfile xschemrc -x -q -n -s --tcl "set lvs_netlist 1" -o out "${cell}.sch" >/dev/null 2>&1
    "$NETGEN" -batch lvs "out/ref.spice ${cell}" "out/${cell}.spice ${cell}" "$SETUP" "out/lvs_${cell}.out" >/dev/null 2>&1 || true
    if grep -q "Circuits match uniquely" "out/lvs_${cell}.out"; then echo "LVS ${cell}: match"; else echo "LVS ${cell}: FAIL"; exit 1; fi
    xvfb-run -a xschem --rcfile xschemrc --tcl "set dark_colorscheme 0" -q \
        --command "xschem zoom_full; xschem print svg out/${cell}.svg; xschem exit closewindow force" "${cell}.sch" >/dev/null 2>&1 || true
    rsvg-convert -w 2600 -b white "out/${cell}.svg" -o "out/${cell}.png"
    python3 - "out/${cell}.png" <<'PY'
import sys
from PIL import Image, ImageChops
p = sys.argv[1]
im = Image.open(p).convert("RGB")
box = ImageChops.difference(im, Image.new("RGB", im.size, "white")).getbbox()
m = 40
im.crop((max(box[0] - m, 0), max(box[1] - m, 0), min(box[2] + m, im.width), min(box[3] + m, im.height))).save(p)
PY
done
