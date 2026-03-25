`timescale 1ns / 1ps

module weight_rom_tb;


    reg [3:0] tb_address;
    
    wire signed [7:0] tb_mu;
    wire signed [7:0] tb_sigma;
    wire signed [23:0] tb_bias;


    rom dut (
        .address(tb_address),
        .mu(tb_mu),
        .sigma(tb_sigma),
        .bias(tb_bias)
    );

    initial begin

        #10; 
        
        $display("========================================");
        $display("   STARTE ROM TEST                      ");
        $display("========================================");

        
        tb_address = 4'd0;
        #10; 
        $display("Address 0 (Expected: mu=50, sigma=10, bias=1000)");
        $display("Read  : mu=%d, sigma=%d, bias=%d\n", tb_mu, tb_sigma, tb_bias);

        // --- Testcase 4: Wrong Address (z.B. 15) ---

        tb_address = 4'd15;
        #10;
        $display("Address 15 (Expected: unknown/x)");
        $display("Read  : mu=%d, sigma=%d\n", tb_mu, tb_sigma);

        $display("========================================");
        $display("   TEST BEENDET                         ");
        $display("========================================");

        $finish; // Simulation stop
        end

endmodule