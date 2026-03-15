# build.tcl

# 1. Prüfen, ob ein Argument (der Modulname) übergeben wurde
if { $argc != 1 } {
    puts "Fehler: Bitte genau ein Top-Modul als Argument übergeben."
    puts "Verwendung: vivado -mode batch -source build.tcl -tclargs <top_modul_name>"
    exit 1
}

# Den übergebenen Namen aus der Liste der Argumente auslesen
set top_module [lindex $argv 0]

# Ziel-FPGA definieren (passe den Part an dein Board an!)
set part_num "xc7a35tcpg236-1" 

puts "=== Starte Build für Top-Modul: $top_module ==="

# 2. Dateien einlesen
read_verilog [glob -nocomplain ../src/control/*.sv]
read_verilog [glob -nocomplain ../src/memory/*.sv]
# read_vhdl [glob -nocomplain ../src/*.vhd]
read_xdc [glob -nocomplain ../constr/*.xdc]

# 3. Synthese (jetzt mit der dynamischen Variablen!)
synth_design -top $top_module -part $part_num

# 4. Platzierung & Routing (Implementation)
opt_design
place_design
route_design

# 5. Bitstream generieren (Wir benennen die Datei direkt nach dem Modul!)
write_bitstream -force ../${top_module}.bit

# 6. Reports generieren
report_timing_summary -file ../${top_module}_timing_summary.rpt
report_utilization -file ../${top_module}_utilization.rpt

puts "=== Build für $top_module erfolgreich abgeschlossen! ==="