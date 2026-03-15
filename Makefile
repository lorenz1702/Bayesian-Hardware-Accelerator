# Directory where your Bash and Tcl scripts are located
SCRIPTS_DIR = scripts

# THIS LINE IS CRUCIAL to prevent the "Nothing to be done" error!
.PHONY: help sim build clean

help:
	@echo "=== Vivado Project Control ==="
	@echo "Available commands:"
	@echo "  make sim TB=<testbench_name>  - Runs the simulation"
	@echo "  make build TOP=<module_name>  - Generates the bitstream"
	@echo "  make clean                    - Deletes all temporary Vivado logs and folders"

sim:
	@if [ -z "$(TB)" ]; then \
		echo "ERROR: No testbench specified!"; \
		echo "Usage: make sim TB=<testbench_name>"; \
		exit 1; \
	fi
	@echo "Starting simulation for $(TB)..."
	@cd $(SCRIPTS_DIR) && ./run_sim.sh $(TB)

build:
	@if [ -z "$(TOP)" ]; then \
		echo "ERROR: No top module specified!"; \
		echo "Usage: make build TOP=<module_name>"; \
		exit 1; \
	fi
	@echo "Starting FPGA build for $(TOP)..."
	@cd $(SCRIPTS_DIR) && ./run_build.sh $(TOP)

clean:
	@echo "Cleaning up temporary files..."
	@cd $(SCRIPTS_DIR) && rm -rf xsim.dir .Xil *.jou *.log *.pb *.wdb waves.vcd usage_statistics_webtalk.*
	@echo "Clean up complete!"