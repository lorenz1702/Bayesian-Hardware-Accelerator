`timescale 1ns / 1ps

module bnn_alu_tb;

    // 1. Signale deklarieren (Inputs als 'reg', Outputs als 'wire')
    reg signed [7:0]  tb_x;
    reg signed [7:0]  tb_mu;
    reg signed [7:0]  tb_sigma;
    reg signed [3:0]  tb_epsilon;
    reg signed [23:0] tb_bias;
    
    wire signed [23:0] tb_y;

    // 2. Das Modul instanziieren (Device Under Test - DUT)
    bnn_alu dut (
        .x(tb_x),
        .mu(tb_mu),
        .sigma(tb_sigma),
        .epsilon(tb_epsilon),
        .bias(tb_bias),
        .y(tb_y)
    );

    // 3. Den Testablauf definieren
    initial begin
        // Startwerte setzen
        tb_x       = 80;    // 0.80
        tb_mu      = 50;    // 0.50
        tb_sigma   = 10;    // 0.10
        tb_bias    = 1000;  // 0.10 (skaliert mit 10.000)
        
        // Testfall 1: Negatives Rauschen (-2)
        tb_epsilon = -2;
        #10; // 10 Nanosekunden warten, bis der Strom durch die Gatter geflossen ist
        
        $display("--- Testfall 1: Negatives Rauschen ---");
        $display("Erwartet: 3400");
        $display("Ergebnis ALU: %d", tb_y);

        // Testfall 2: Positives Rauschen (+3)
        // Rechnung: W_eff = 50 + (10 * 3) = 80.  Y = (80 * 80) + 1000 = 7400
        tb_epsilon = 3;
        #10;
        
        $display("--- Testfall 2: Positives Rauschen ---");
        $display("Erwartet: 7400");
        $display("Ergebnis ALU: %d", tb_y);
        
        // Testfall 3: Kein Rauschen (0) -> Das Standard-Netz
        // Rechnung: W_eff = 50. Y = (80 * 50) + 1000 = 5000
        tb_epsilon = 0;
        #10;
        
        $display("--- Testfall 3: Kein Rauschen (Standard) ---");
        $display("Erwartet: 5000");
        $display("Ergebnis ALU: %d", tb_y);

        // Simulation beenden
        $finish;
    end

endmodule