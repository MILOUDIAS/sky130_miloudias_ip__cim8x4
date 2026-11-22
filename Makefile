PYTHON ?= python3
IVERILOG ?= iverilog
VVP ?= vvp
NGSPICE ?= ngspice
PDK_LIB ?= $(PDK_ROOT)/sky130A/libs.tech/ngspice/sky130.lib.spice
RTL = rtl/acim_ctrl.sv rtl/acim_top.sv
TEST = tests/array_model.sv tests/controller_tb.sv
SPICE = $(PYTHON) tests/spice.py --pdk "$(PDK_LIB)" --ngspice "$(NGSPICE)"

.PHONY: test ideal rtl demo netlist spice replay application offset guard schematics
test: ideal rtl demo
ideal:
	$(PYTHON) tests/golden.py
build/controller.vvp: $(RTL) $(TEST)
	mkdir -p build
	$(IVERILOG) $(IVFLAGS) -g2012 -s controller_tb -o $@ $^
rtl: build/controller.vvp
	$(VVP) $(VVPFLAGS) $<
netlist:
	$(PYTHON) analog/generate.py analog/acim_array.spice
spice:
	$(SPICE) --suite directed --work build/full_tt
replay: build/controller.vvp
	$(VVP) $(VVPFLAGS) $< +TRACE=build/rtl.csv
	$(SPICE) --rtl-trace build/rtl.csv --work build/replay

demo: build/controller.vvp
	$(VVP) $(VVPFLAGS) $< +DEMO
application:
	$(SPICE) --suite application --work build/application
offset:
	$(PYTHON) tests/offset.py --pdk "$(PDK_LIB)" --ngspice "$(NGSPICE)" --work build/offset
guard:
	$(SPICE) --columns 1 --suite midpoints --guard-steps 0.20 --corner ss --vdd 1.65 --temp -40 --work build/guard_cold

.PHONY: characterize
characterize:
	$(PYTHON) tests/characterize.py --pdk "$(PDK_LIB)" --ngspice "$(NGSPICE)"

.PHONY: cold-ab
cold-ab:
	$(PYTHON) tests/reproduce_cold.py --pdk "$(PDK_LIB)" --ngspice "$(NGSPICE)"

# External-reference (FRAC = 11) level map at three corners, and VEXT path leakage / on-resistance.
.PHONY: vext vext-leak
vext:
	$(SPICE) --columns 1 --suite vext --work build/vext_tt
	# At SS/1.65 V/-40 C the k=0 sum (0.41 V) is below the comparator input range; map k=1..8.
	$(SPICE) --columns 1 --suite vext --corner ss --vdd 1.65 --temp -40 --vext-from-k 1 --work build/vext_cold
	$(SPICE) --columns 1 --suite vext --corner ff --vdd 1.9 --temp 110 --vext-gain 0.95 --work build/vext_hot
vext-leak:
	$(PYTHON) tests/vext_leak.py --pdk "$(PDK_LIB)" --ngspice "$(NGSPICE)"
schematics:
	xschem/build.sh
	mkdir -p docs/schematics
	cp xschem/out/compare.png xschem/out/cim_cell.png xschem/out/vext_path.png docs/schematics/
