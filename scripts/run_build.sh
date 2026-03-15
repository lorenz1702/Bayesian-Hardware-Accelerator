#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No Top-Modul"
    echo "Usage: ./run_build.sh <top_modul_name>"
    exit 1
fi

vivado -mode batch -source build.tcl -tclargs $1