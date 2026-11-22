# SKY130 charge-domain analog in-memory compute macro

This is a schematic-level prototype of the 8-row × 4-column Chipalooza proposal. It stores 32 writable weight bits and resolves four unsigned dot-product thresholds on each evaluation. The analog source is an editable ngspice hierarchy. The four-column netlist and the synthesizable SystemVerilog controller are included.

## Run it

Use Python 3.10+, GNU Make, Icarus Verilog and ngspice. The transistor tests need an open_pdks SKY130A installation containing both the ngspice models and the SKY130 primitive SPICE library. The recorded runs used ngspice 44.2, Icarus 12.0 and open_pdks build `fa87f8f4bbcc7255b6f0c0fb506960f531ae2392`. For that archived build the two model packages are `common.tar.zst` and `sky130_fd_pr.tar.zst`. Extract both into the same PDK root. The application includes its own source only. [PDK release](https://github.com/chipfoundry/volare/releases/tag/sky130-fa87f8f4bbcc7255b6f0c0fb506960f531ae2392)

```sh
make test
export PDK_ROOT=/path/to/pdks
make spice
make replay
make characterize
make vext
make vext-leak
```

`make test` exercises ideal arithmetic and the host protocol, including count mode, the ERR self-check and the external-reference (VEXT) mode. `make spice` checks the complete transistor array against directed patterns. `make replay` records the actual RTL control transitions for eight row writes, three evaluations and one count-mode sequence, then uses these transitions to drive the four-column SPICE array. This is one-way trace replay. SPICE decisions are checked against the independent host arithmetic. CSVs, generated stimuli and simulator logs appear in `build/`.

[Editable draw.io architecture diagram](docs/ACIM_Architecture.drawio) · [Rendered architecture](docs/ACIM_Architecture.svg) · [Cold-switch comparison](docs/cold_switch_comparison.csv)

To reproduce the proposal's cold-corner switch comparison (about 20 to 47.8 mV), run `make cold-ab` with the PDK and simulator settings above. This runs both switch variants and writes the two node-voltage measurements, the output, and the normalized margin to `build/cold_ab/cold_switch_comparison.csv`. The unmodified design sources stay in place.

## Four-mask demonstration

Program column masks 0x0F, 0x33, 0x55 and 0xF0. At X = 0x0F and T = 2 the overlap counts are 4, 2, 2 and 0, producing Y[3:0] = 0001. For a one-hot input and T = 0, the four result bits must reproduce the selected row. Compare the result with the directly read row and the programmed row. Repeat on silicon with complemented patterns so every physical cell is tested in both states.

`make demo` runs the RTL command sequence and checks all 2,048 four-bit results for this mask set. `make application` exercises the example plus eight one-hot inputs on the nominal four-column transistor schematic.

## Comparator characterization

`make offset` sweeps the isolated comparator's differential input with common mode fixed at 0.32, 0.50 and 0.68 times the supply. `make guard` tests one cold column at both adjacent counts for every midpoint threshold while opposing its decision by 0.20 count step. `make characterize` runs the full recorded set, including both benches at three process/voltage/temperature conditions and eight local mismatch seeds at TT and SS. Each command accepts the same `PDK_LIB` and `NGSPICE` overrides as the original SPICE target. See the [verification record](docs/verification.md) for the signed trip ranges, test conditions, results and scope.

## Edit the design

| File | What it controls |
| --- | --- |
| `analog/cells.spice` | Buffered static latch, AND gate, transmission gates, sampling capacitance, comparator and reset paths. Geometry is in µm with SKY130 device subcircuits. |
| `analog/generate.py`, `analog/acim_array.spice` | Regular array and replica connectivity. Regenerate with `make netlist` after editing the generator. |
| `rtl/acim_ctrl.sv`, `rtl/acim_top.sv` | Toggle handshake, write decoder, threshold decoder, non-overlapping phases and 4,096-frame burst. |
| `rtl/acim_array_blackbox.sv`, `tests/array_model.sv` | Logical black-box interface for synthesis and the corresponding functional test view. Compile one view at a time. |
| `tests/spice.py` | SPICE pattern generator and automated checks for comparator rails, input margin, evaluation disturbance and retained weights. |

### Electrical interface

External logical controls are D[7:0], ROW[2:0], T[2:0], FRAC[1:0], CMD[2:0], REQ and RESET_N (21 bits). Status is Y[3:0], RDO[3:0], ACK and ERR (10 bits). CLK uses the requested dedicated pad and VEXT one shared analog line. The reusable core works at 1.8 V nominal; VDDA (3.3 V) powers only the VEXT level shifter and pad-side switch. The chip-level pad, supply switching and protection remain integration work.

| CMD | Operation | Uses | Result |
| --- | --- | --- | --- |
| 000 | Read row | ROW | Row's four stored bits on RDO |
| 001 | Write row | ROW, D[3:0] | Four latches of the row written together |
| 010 | Evaluate | D as X, T, FRAC | Y after four clocks (7 clocks REQ to ACK) |
| 011 | Burst | D as X, T, FRAC | 4,096 frames alternating X and its complement |
| 100 | Count | D as X, T | Eight frames at T = 0..7 with the 1/2 reference; one 4-bit count per column; Y = count > T; ERR if a column's decisions are not monotonic (35 clocks REQ to ACK) |
| 101 | Read count | ROW[1:0] as column | That column's count on RDO |
| 110, 111 | Reserved | - | ACK only |

Codes 000-011 keep the original 2-bit command meanings. FRAC 00, 01 and 10 select a 1/2, 1/4 or 3/4 count above T; FRAC 11 connects VEXT to every comparator's reference input during SHARE and COMPARE. ERR is sticky until reset.

Inside the RTL, port `stored[4*r+c]` reads row r and column c. SPICE port groups use ascending suffixes starting at 0. In subcircuit declaration order the groups are `vp vn sam shr ev x0..7 wr0..7 d0..3 coarse0..6 fine0..3 y0..3 q0..31`. RTL `data` maps to d, `cmp` to y, `stored` to q, and `sample_gate/share_gate/evaluate` to sam/shr/ev. Supply pins are explicit in SPICE.

1. Hold REQ low during reset. After synchronous reset release, write all eight rows using command 001. While idle, set payload before toggling REQ and retain it until ACK matches. Command 00 reads the selected row. Stored data survives a controller reset while the core is powered.
2. In command 010, column c returns 1 if `popcount(X & W[c]) > T`. FRAC 00 selects one half, 01 one quarter, and 10 three quarters of a count above T. Command 100 sums the eight midpoint decisions on chip to recover k.
3. Relative to the acceptance edge, SAMPLE runs from 0.5–1 clocks, SHARE from 1.5–3.5, and COMPARE from 2–3. Capture at clock 3, update Y and ACK at clock 4. Input synchronization adds latency before acceptance. Verify generated clock gating and non-overlap after synthesis and extraction.
4. Command 011 runs 4,096 frames, alternating the captured vector and its complement. At 1 MHz this occupies 16.384 ms from acceptance to completion. The last result and ACK update together.

### Analog implementation

Each column has a local reference, a bus reset on both signal and reference, and matched branch counts. The seventh zero-based data row is split into four quarter branches with common control. The corresponding four reference branches can be driven independently. Both sides include seven full-sized data/reference branches and eight ballast branches. The analytical voltage before parasitic loading is VDD × (4+k)/16.

The sharing switch uses low-threshold NMOS and PMOS devices to improve cold-corner settling.

The VEXT test path (`ls_hv`, `vext_in` and `nvx` in `analog/cells.spice`) starts with a 5 V-oxide transmission gate at the shared line (PMOS body at VDDA, so 3.3 V on the line cannot forward-bias it), enabled through a 1.8 V-to-3.3 V level shifter, then a short high-resistance poly resistor and clamp diodes to the 1.8 V rails. One 5 V-oxide NMOS per column, its gate driven to 3.3 V by a second level shifter while VGATE is high (SHARE and COMPARE only, never during the bus reset), connects the clamped node to the reference bus. An identical always-off device loads each sum bus so both comparator inputs see the same junction load.

Two earlier versions of the per-column switch failed in simulation and are recorded in the verification report. A regular-threshold 1.8 V transmission gate left the reference bus up to 114 mV short of VEXT around mid-rail at SS/1.65 V/-40 C. A low-threshold gate fixed that but leaked enough at FF/1.9 V/110 C to pull the floating reference bus toward the switch node, dropping the hot slow-clock margin from 0.456 to 0.115 step. The thick-oxide NMOS with 3.3 V gate drive avoids both. The write and sampling gates use the regular 1.8 V devices. The SPICE model represents each full capacitor as four parallel 5 µm × 5 µm SKY130 M3 MiM units. A quarter branch uses one. In the PDK model, multiplicity scales nominal capacitance and the finger-count parameter adjusts the local mismatch term. The schematic uses estimated source/drain areas and perimeters. Routing capacitance, gradients, actual junction sharing and layout-dependent offset require extraction. The two output loads on each clocked comparator match nominally. A physical layout will need a symmetric capacitor pattern, dummy perimeter and balanced routing, followed by DRC, LVS and PEX before wrapper integration.

### Transistor-level schematics

`xschem/` holds xschem schematics of the comparator (`compare.sch`), one compute cell (`cim_cell.sch`: weight, AND and switched unit capacitor) and the VEXT input path for one column (`vext_path.sch`). They use the open_pdks sky130 symbols. Each `.sch` is generated from a small Python description, so cell edits stay readable in a diff. `make schematics` (needs `PDK_ROOT`, xschem, netgen, xvfb-run, rsvg-convert and Pillow) regenerates them, netlists each in LVS mode and compares it with netgen against `analog/cells.spice`. The cells are wired as `analog/generate.py` instantiates them (`xschem/ref_composites.spice`). The rendered PNGs go to `docs/schematics/`. All three report "Circuits match uniquely". Renaming any gate label in a schematic makes netgen report a mismatch, so the check compares connectivity, not just device counts.

| Schematic | Devices |
| --- | --- |
| [Comparator](docs/schematics/compare.png) | 15 MOS, 2 MIM |
| [Compute cell](docs/schematics/cim_cell.png) | 22 MOS, 1 MIM (4 × 5 µm × 5 µm) |
| [VEXT input path](docs/schematics/vext_path.png) | 16 MOS (12 of them 5 V oxide), 1 poly resistor, 2 clamp diodes |

## Reproduce a specific electrical test

```sh
python3 tests/spice.py --pdk "$PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice" \
  --columns 1 --suite boundaries --corner ss --vdd 1.65 --temp -40 --work build/cold
python3 tests/spice.py --pdk "$PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice" \
  --columns 1 --suite directed --seed 101 --work build/mismatch101
```

The `boundaries` suite checks both adjacent counts at every threshold and all three distinct fractional settings. The `quick` suite tests full-to-zero history. The `rotated` suite holds count four constant while rotating the active rows. Each run records the input differential before the comparator clocks, its change across evaluation and the final digital output. Midpoint tests require a pre-evaluation signed input margin of at least 0.20 × VDD/16 and the expected output within 20% of its rail. The input margin is a diagnostic and does not include input-referred comparator offset. See the verification report for coverage and remaining checks.

[Verification results](docs/verification.md) · [Upstream design review](docs/github-review.md) · [Apache 2.0 license](LICENSE)
