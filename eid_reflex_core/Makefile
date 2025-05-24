# -------- Simu Verilator ----------
VERILATOR ?= $(shell command -v verilator 2>/dev/null)
SRC  = $(wildcard src/*.v)
TB   = test/eid_tb.v
VCD  = test/sim.vcd

.PHONY: sim gen check wave clean

sim:
ifeq ($(VERILATOR),)
			@echo ">> Verilator non trouvé – simulation SKIPPED"; \
		touch $(VCD)
else
		verilator -Wall --trace $(SRC) $(TB) -exe -cc -o sim && \
		make -C obj_dir -f Veid_tb.mk && ./obj_dir/sim
endif
wave: sim
	        gtkwave $(VCD) test/.gtkwave &>/dev/null &
clean:
	        rm -rf obj_dir $(VCD)

gen:
		python3 test/gen_vectors.py

check: gen
		gcc -Wall -Isrc test/test_ref.c src/eid_model.c -o test/check && \
		./test/check
