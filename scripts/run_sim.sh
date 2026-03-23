#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No top module specified!"
    echo "Usage: ./run_sim.sh <testbench_top_module>"
    exit 1
fi

TOP_MODULE=$1
SNAPSHOT="${TOP_MODULE}_snapshot"

echo "=== Starting simulation for: $TOP_MODULE ==="

echo "Compiling..."
xvlog -sv ../src/memory/*.sv ../src/control/*.sv ../src/compute/*.sv ../sim/*.sv ../sim/memory/*.sv ../sim/compute/*.sv ../src/*.sv

echo "Elaborating..."
xelab -debug typical -top $TOP_MODULE -snapshot $SNAPSHOT

echo "Simulating..."
xsim $SNAPSHOT -tclbatch xsim_cfg.tcl

echo "=== Simulation finished ==="