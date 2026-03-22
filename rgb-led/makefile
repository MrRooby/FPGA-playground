.PHONY: sim rtl clean

RTL_DIR := rtl

sim:
	iverilog -g2012 -o sim top.v modules/strip_tx.v modules/led_tx.v test/test_bench
	vvp sim

rtl:
	mkdir -p $(RTL_DIR)
	# flattened full design
	yosys -p 'read_verilog top.v modules/*.v; hierarchy -check -top top; proc; opt; flatten; opt; write_json $(RTL_DIR)/rtl_flat.json'
	netlistsvg $(RTL_DIR)/rtl_flat.json -o $(RTL_DIR)/rtl_flat.svg

	# top-only view
	yosys -p 'read_verilog top.v modules/*.v; hierarchy -check -top top; proc; opt; prep -top top; write_json $(RTL_DIR)/top.json'
	netlistsvg $(RTL_DIR)/top.json -o $(RTL_DIR)/top.svg

	# strip_tx-only view
	yosys -p 'read_verilog modules/strip_tx.v modules/led_tx.v; hierarchy -check -top strip_tx; proc; opt; prep -top strip_tx; write_json $(RTL_DIR)/strip_tx.json'
	netlistsvg $(RTL_DIR)/strip_tx.json -o $(RTL_DIR)/strip_tx.svg

	# led_tx-only view
	yosys -p 'read_verilog modules/led_tx.v; hierarchy -check -top led_tx; proc; opt; prep -top led_tx; write_json $(RTL_DIR)/led_tx.json'
	netlistsvg $(RTL_DIR)/led_tx.json -o $(RTL_DIR)/led_tx.svg

	# white theme for dark backgrounds
	for f in $(RTL_DIR)/*.svg; do \
		sed 's/#000/#fff/g' "$$f" > "$$f.tmp" && mv "$$f.tmp" "$$f"; \
	done

clean:
	rm -f dump.vcd
	rm -f $(RTL_DIR)/*.json $(RTL_DIR)/*.svg
