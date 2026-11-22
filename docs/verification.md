# Verification record

The current results were produced with ngspice 42 and Icarus Verilog 12.0, using the SKY130A foundry-device models from open_pdks revision `fa87f8f4bbcc7255b6f0c0fb506960f531ae2392`, at a solver tolerance of reltol 1e-4 (see "External reference (VEXT) path" for why). The simulation hierarchy includes writable transistor latches, switches, weighted MiM branches, replicas, comparators and the VEXT test path. Standalone electrical checks use ideal pin drivers with a 0.5 ns transition. Digital datapath behavior and analog readout are checked independently, and the replay uses the controller's actual edge ordering. Every electrical run holds the shared VEXT line at 3.3 V with its switches off.

## Results

| Run | Simulations | Correct decisions meeting the bench criteria | Worst midpoint margin, steps | Largest absolute differential change, mV |
| --- | ---: | ---: | ---: | ---: |
| Four-column directed | 1 | 28/28 | 0.460 | 1.684 |
| RTL control trace replay (incl. one count sequence) | 1 | 44/44 | 0.461 | 1.486 |
| Nominal nearest boundaries | 1 | 48/48 | 0.460 | 0.201 |
| Cold nearest boundaries | 1 | 48/48 | 0.464 | 0.217 |
| Hot nearest boundaries | 1 | 48/48 | 0.452 | 0.239 |
| Nominal row rotations | 1 | 16/16 | 0.460 | 0.117 |
| Two slow-clock directed runs | 2 | 14/14 | 0.453 | 1.857 |
| Endpoint PVT grid | 45 | 90/90 | 0.509 | 0.225 |
| Eight TT mismatch seeds | 8 | 56/56 | 0.452 | 1.719 |

The first prototype (ngspice 44.2, reltol 1e-3, before the VEXT path) gave the same pass counts with worst-case margins within 0.01 step of these. Adding devices changes which random values each mismatch seed draws, so per-seed numbers are not directly comparable between the two netlists.

The 392 column decisions above include repeated patterns evaluated under different conditions. Eight independent TT mismatch seeds were used. Repeating seed 101 produced an identical decisions CSV and is excluded from the count. Every run checked all retained weight bits at its end. A single-column run checks eight bits and a four-column run checks 32. The transistor-level analog test coverage is sampled.

At nominal conditions the full array ran seven directed four-column evaluations. For the 45-point grid, each process corner (TT/SS/FF/SF/FS), supply (1.65/1.80/1.90 V), and temperature (−40/25/+110 °C) combination ran two endpoint checks on one column at 1 MHz. The more extensive 48-case sequences exercise k=T and k=T+1 at ¼, ½ and ¾ fractions at each integer T. The cold sequence used SS/1.65 V/−40 °C/1 MHz and the hot sequence FF/1.90 V/+110 °C/0.5 MHz. The slow-clock directed runs used the same cold and hot corners at 0.5 MHz. [All recorded decisions](spice_results.csv)

## A failure that changed the circuit

At SS, 1.65 V, −40 °C and 1 MHz, the k=7, T=6 midpoint case returned the correct bit but had only 0.194 steps of signed input margin (20.0 mV), below the 0.20-step test floor. Changing the **sharing switch only** to the SKY130 low-threshold NMOS/PMOS pair produced 0.464 steps (47.8 mV) for the same case. To reproduce the comparison in a working copy, use `tg` or `tg_share` on the `Xshare` line in `analog/cells.spice` and run the cold boundary command in the README. Both networks use the same dimensions, estimated junction geometries and unit capacitors.

### Source of the proposal’s cold-corner result

`make cold-ab` runs two copies of the same one-column boundary bench. Only the `Xshare` subcircuit selection changes, from `tg` to `tg_share`. Input 0x7F and weight 0xFF give k = 7. Threshold 6 with the midpoint fraction gives a 6.5-count reference. Case 40 (zero-based) samples sum and reference at 162.390 μs, 10 ns before evaluation. The ngspice measurements are `s_40_0` and `r_40_0`. The digital output is `y_40_0`. Both variants resolved high. The regular switch missed the specified 0.20-step pre-comparison check for this case. The generated decks, stdout reports and ngspice logs are available in `build/cold_ab` after a rerun. [Cold-switch comparison CSV](cold_switch_comparison.csv)

## How to interpret the metrics

The input-margin column uses the signed difference between sum and replica, sampled 0.01 clock period before evaluation and normalized by VDD/16. Its sign is chosen to be positive for the correct decision. The minimum criterion is 0.20 step for midpoint tests. For the quarter- and three-quarter-count tests the bench checks the expected polarity and output rail. The change in differential voltage is sampled from 0.01 period before evaluate to 0.06 period after evaluate. It includes comparator loading, residual settling, and leakage over that interval. It is a disturbance diagnostic, not a de-embedded kickback measurement. The output is checked at 0.97 period into evaluation and must cross 80% or 20% of VDD as appropriate.

## Digital coverage

The independent Python model checks 1,572,864 ideal comparisons covering every 8-bit activation and column weight, eight thresholds and the three internal FRAC encodings (FRAC 11 now selects VEXT). It confirms that the eight midpoint decisions of every input and weight pair form a thermometer code and reconstructs all 65,536 exact counts from them, which is the count-mode arithmetic.

The controller regression completes 3,366 host commands. They include 2,048 one-shot evaluations (512 of them in VEXT mode against the model's external level), 256 count sets with all four counts read back, a sweep of eight external reference levels, both reserved commands, and a full 4,096-frame burst. A test hook inverts one decision inside a count; ERR latches, stays set through a later evaluation and clears on reset. The bench also interrupts a burst with reset, verifies stored data, checks sample/share and VEXT-gate non-overlap, and rejects early or partial results. Timing is exact: 7 clocks REQ to ACK for an evaluation, 35 for a count and 16,387 for a burst. The demo run adds 256 count sets on the worked-example masks.

Three deliberate controller faults were each caught by the regression: removing the ERR check, shifting the count-mode threshold sequence by one step, and letting VGATE overlap the bus reset.

## External reference (VEXT) path

FRAC = 11 connects VEXT to all four comparator reference inputs during SHARE and COMPARE. The path is a 5 V-oxide pad-side transmission gate (enabled through a 1.8 V-to-3.3 V level shifter), a 1-square high-resistance poly resistor, clamp diodes to the 1.8 V rails, and one 5 V-oxide NMOS per column whose gate a second level shifter drives to VDDA. An identical, always-off NMOS loads each sum bus. `make vext` and `make vext-leak` reproduce the results below. The level map runs at reltol 1e-4.

**Level map.** One column with all weights 1 is driven with k = 0..8 ones. For each k, VEXT steps in 3 mV increments over a 90 mV window around the expected sum. The trip point is the midpoint between the highest VEXT that returns 1 and the lowest that returns 0, and every sweep must be monotonic with fully resolved outputs. The reference bus must sit within 1 mV of VEXT at the comparison instant.

| Corner | Counts mapped | Sum step, mV (ideal VDD/16) | Trip minus sum, mV | Reference bus vs VEXT |
| --- | --- | --- | --- | --- |
| TT, 1.80 V, 25 C, 1 MHz | 0-8 | 108.9-114.7 (112.5) | -2.8 to +0.1 | within 0.001 mV |
| SS, 1.65 V, -40 C, 1 MHz | 1-8 | 100.1-104.8 (103.1) | -6.4 to 0.0 | within 0.001 mV |
| FF, 1.90 V, 110 C, 1 MHz | 0-8 | 114.8-121.5 (118.75) | -1.5 to +0.7 | within 0.001 mV |

At SS/1.65 V/-40 C the k = 0 sum (0.41 V) is below the comparator's input common-mode range: the comparator returns 0 there for every VEXT tried, including VEXT 33 mV below the sum. Normal operation never needs a 1 decision below about 0.48 V at that corner, where the boundary tests pass, so this limits the level map rather than the macro. The cold map therefore covers k = 1..8.

**Leakage and on-resistance** (`tests/vext_leak.py`, operating point). With 3.3 V on the shared line and both switches off, the line sources at most 0.087 nA (FS, 1.9 V, 110 C); the clamped internal node stays at or below VDD. With the switches on, the per-column path resistance, counting the shared pad switch four times because all four banks charge through it, is 9.8-10.9 k ohm, so a 3.4 pF reference bank settles in about 37 ns, well inside the half clock before COMPARE. [Level map](vext_levels.csv) · [All level-map evaluations](vext_results.csv) · [Leakage](vext_leak.csv)

**Two rejected switch designs.** A regular-threshold 1.8 V transmission gate per column left the reference bus up to 114 mV short of VEXT around mid-rail at SS/1.65 V/-40 C (mid-rail dead zone). A low-threshold gate fixed that, but its off-state leakage at FF/1.9 V/110 C pulled the floating reference bus toward the switch node and cut the hot slow-clock directed margin from 0.456 to 0.115 step, failing one decision. The 5 V-oxide NMOS with 3.3 V gate drive avoids both and restores the original margins.

**Solver tolerance.** At reltol 1e-3, ngspice occasionally resolved the comparator to the wrong rail with 27-40 mV of correct-sign input in the level map, and once in a mismatch guard run (TT, seed 102, k = 7, T = 6). Both cases resolve correctly at 1e-4, so every bench now defaults to reltol 1e-4.

## Application and one-hot readback

At TT/1.80 V/25 °C/1 MHz, the four-column transistor simulation returned the expected four result bits for the feature-mask example and the four stored bits of each row for eight one-hot inputs. All 36 decisions met the rail and midpoint input checks. All 32 buffered weight bits also passed direct voltage checks. A separate RTL run checked the eight addressed reads, the eight one-hot results, the worked result Y = 0001, and 2,048 four-bit outputs across the 256 input values and eight thresholds. [Application decisions](application_results.csv)

## Input-referred offset

The clocked comparator in `analog/cells.spice` is driven by two ideal voltage sources. Their average stays fixed for each sweep. The differential Vsignal − Vreference runs from −25 to +25 mV in 0.5 mV steps and returns along the same grid. Common modes are 0.32, 0.50 and 0.68 × VDD. The evaluate edge rises in 0.5 ns, and the state is checked 970 ns into the evaluate phase at a 1 MHz core clock. The latch nodes must be complementary at the 20/80% levels and the buffered output must agree. Each bound is the last resolved low or the first resolved high. The bench checks for nonmonotonic transitions and unresolved values outside the bracket.

| Condition | Samples | Envelope over common modes and sweep directions |
| --- | --- | --- |
| TT/1.80 V/25 °C, SS/1.65 V/−40 °C and FF/1.90 V/+110 °C | 3 unseeded cases | −0.5 to +0.5 mV |
| TT/1.80 V/25 °C | Seeds 101–108 | −12.0 to +12.5 mV |
| SS/1.65 V/−40 °C | Seeds 101–108 | −12.0 to +12.5 mV |

These trip brackets come from the first prototype run (ngspice 44.2); the comparator cell is unchanged. The table spans 114 brackets, six per run. Identical seed numbers across corners reuse the chosen seeds. These finite samples give no population yield estimate. The ideal-source test quantifies differential trip at specified common modes. See the loaded-column experiment below for operation with floating charge-sharing nodes. [Comparator trip brackets](offset_results.csv)

## Residual margin under adverse input perturbation

With the complete one-column array and local replica in circuit, two ideal series test sources shift the comparator inputs by equal and opposite amounts. The total shift is 0.20 × VDD/16 against the correct decision and is applied before sampling. The sources retain gate loading on the floating buses. The fixed weight mask is 0xFF. For each T from 0 through 7, the bench applies k = T and k = T + 1 at the midpoint. It verifies the actual signed shift from the simulated input voltages and checks both internal regenerative nodes and the digital output 0.97 µs after the clock edge. The original pre-regeneration margin check also runs. The sources are present only in the test deck.

All 304 decisions passed on the current netlist (VEXT path in place, shared line at 3.3 V) at reltol 1e-4; the smallest pre-injection margin was 0.446 step. At reltol 1e-3 one decision (TT, seed 102, k = 7, T = 6) resolved to the wrong rail with about 29 mV of correct net input and resolves correctly at 1e-4, which is why the benches now default to the tighter tolerance. The data include 16 decisions at each of the three unseeded corners above and 16 at each of eight mismatch seeds for both TT and SS. At SS the 0.20-step applied shift is 20.625 mV. A pass establishes a lower bound for that case. The reported `input_margin_steps` column is the array-bus differential before test injection. The `applied_adverse_steps` column records the shift sensed at the comparator pins. Layout parasitics, extracted slew, other row permutations and noise require further characterization. [Loaded-column results](guard_results.csv)

## Reproduction and remaining work

Run `make test`, `make replay` and `make characterize` as in the README. Regenerate the electrical matrix with `python3 tests/sweep.py --pdk "$PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice" --jobs 2`. The CSV lists an expected bit, measured output voltage and analog diagnostics for every recorded decision. Run `make vext` and `make vext-leak` for the external-reference results. The engineering prototype still needs xschem schematics, CACE characterization, physical layout, parasitic extraction, post-layout mismatch and offset verification, digital timing closure, whole-core power, DRC/LVS, pad/wrapper integration and silicon characterization. The 20 µW nominal core power and nominal 200 × 200 µm footprint are proposal targets.
