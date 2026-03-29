# build.tcl

if { $argc != 1 } {
    puts "Error: Please provide exactly one top module as an argument."
    puts "Usage: vivado -mode batch -source build.tcl -tclargs <top_module_name>"
    exit 1
}

set top_module [lindex $argv 0]

set part_num "xc7a35tcpg236-1" 

puts "=== Starting Build for Top Module: $top_module ==="

# 2. Read source files
read_verilog [glob -nocomplain ../src/control/*.sv]
read_verilog [glob -nocomplain ../src/memory/*.sv]
# read_vhdl [glob -nocomplain ../src/*.vhd]
read_xdc [glob -nocomplain ../constr/*.xdc]

synth_design -top $top_module -part $part_num


opt_design
place_design
route_design

write_bitstream -force ../${top_module}.bit


report_timing_summary -file ../${top_module}_timing_summary.rpt
report_utilization -file ../${top_module}_utilization.rpt

puts "=== Build for $top_module successfully completed! ==="