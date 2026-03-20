`timescale 1ns / 1ps

module weight_rom_tb;

    // 1. Signale deklarieren (Inputs als reg, Outputs als wire)
    reg [3:0] tb_address;
    
    wire signed [7:0] tb_mu;
    wire signed [7:0] tb_sigma;
    wire signed [23:0] tb_bias;

    // 2. Den ROM instanziieren (Device Under Test - DUT)
    rom dut (
        .address(tb_address),
        .mu(tb_mu),
        .sigma(tb_sigma),
        .bias(tb_bias)
    );

    // 3. Testablauf
    initial begin
        // Kurze Pause, damit $readmemh in Ruhe laden kann
        #10; 
        
        $display("========================================");
        $display("   STARTE ROM TEST                      ");
        $display("========================================");

        // --- Testfall 1: Adresse 0 ---
        tb_address = 4'd0;
        #10; // 10ns warten
        $display("Adresse 0 (Erwartet: mu=50, sigma=10, bias=1000)");
        $display("Gelesen  : mu=%d, sigma=%d, bias=%d\n", tb_mu, tb_sigma, tb_bias);

        // --- Testfall 2: Adresse 1 ---
        tb_address = 4'd1;
        #10;
        $display("Adresse 1 (Erwartet: mu=-20, sigma=5, bias=1000)");
        $display("Gelesen  : mu=%d, sigma=%d, bias=%d\n", tb_mu, tb_sigma, tb_bias);

        // --- Testfall 3: Adresse 2 ---
        tb_address = 4'd2;
        #10;
        $display("Adresse 2 (Erwartet: mu=10, sigma=25, bias=1000)");
        $display("Gelesen  : mu=%d, sigma=%d, bias=%d\n", tb_mu, tb_sigma, tb_bias);
        
        // --- Testfall 4: Ungültige Adresse (z.B. 15) ---
        // Da wir nur 3 Zeilen in der Datei haben, sollte der Rest 'x' (unknown) sein
        tb_address = 4'd15;
        #10;
        $display("Adresse 15 (Erwartet: unknown/x)");
        $display("Gelesen  : mu=%d, sigma=%d\n", tb_mu, tb_sigma);

        $display("========================================");
        $display("   TEST BEENDET                         ");
        $display("========================================");

        $finish; // Simulation stoppen
    end

endmodule