.PHONY: sim

sim:
	iverilog -g2012 -o sim top.v modules/strip_tx.v modules/led_tx.v test/test_bench
	vvp sim

clean:
	rm dump.vcd sim
