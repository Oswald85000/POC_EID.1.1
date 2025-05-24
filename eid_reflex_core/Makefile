# -------- Simu Verilator ----------
SRC  = $(wildcard src/*.v)
TB   = test/eid_tb.v
VCD  = test/sim.vcd

sim:
	verilator -Wall --trace $(SRC) $(TB) -exe -cc -o sim && \
	make -C obj_dir -f Veid_tb.mk && ./obj_dir/sim
wave: sim
	gtkwave $(VCD) test/.gtkwave &>/dev/null &
clean:
	rm -rf obj_dir $(VCD)
