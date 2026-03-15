# xsim_cfg.tcl

# 1. Create and open a VCD file
open_vcd waves.vcd

# 2. Tell the simulator which signals to log into the VCD file.
# The '/*' means: Include the top-level module and all submodules (recursively).
log_vcd [get_objects -r /*]

# 3. Run the simulation indefinitely (until $finish is called in the testbench)
run all

# 4. Safely close and save the VCD file
close_vcd

# 5. Quit the simulator
quit