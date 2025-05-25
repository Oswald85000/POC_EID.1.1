SIM ?= verilator
SRC := $(wildcard src/*.v)
TB  := test/eid_tb.v
VCD := test/sim.vcd
CSV := test/test_vectors.csv
HEX := test/test_vectors.hex
VERILATOR := $(shell command -v verilator 2>/dev/null)
IVERILOG  := $(shell command -v iverilog 2>/dev/null)

all: sim

$(HEX) $(CSV): test/gen_vectors.py
	python3 $< $(HEX) $(CSV)

gen: $(HEX) $(CSV)

sim: gen
ifeq ($(SIM),verilator)
	@if [ -z "$(VERILATOR)" ]; then echo "No simulator found - skipping."; touch $(VCD); else \
	verilator -Wall --trace -cc $(SRC) $(TB) -exe -o simv && \
	make -C obj_dir -f Veid_tb.mk && ./simv; fi
else ifeq ($(SIM),iverilog)
	@if [ -z "$(IVERILOG)" ]; then echo "No simulator found - skipping."; touch $(VCD); else \
	iverilog -g2012 -o simv $(SRC) $(TB) && vvp simv; fi
else
	@echo "No simulator found - skipping."; touch $(VCD)
endif

wave: sim
	gtkwave $(VCD) &

check: gen
	gcc -Wall -Isrc src/eid_model.c test/test_ref.c -o test_ref && ./test_ref $(CSV)

cov:
	@echo "coverage skipped"

clean:
	rm -rf obj_dir simv $(VCD) $(CSV) $(HEX) test_ref test/sim_results.csv

.PHONY: all gen sim wave check cov clean
