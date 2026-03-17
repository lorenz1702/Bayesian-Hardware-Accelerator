`timescale 1ns / 1ps

module tb_clt;

    localparam int NUM_STAGES = 12;
    localparam int WIDTH = 8;
    localparam real DIVISOR = real'(1 << WIDTH);


    reg clk;
    reg rst_n;
    reg enable;

    reg clt_valid;
    reg signed [WIDTH + $clog2(NUM_STAGES) - 1 : 0] clt_out;


    real float_val;


    CLT #(
        .NUM_STAGES(NUM_STAGES),
        .WIDTH(WIDTH)
    )CLT_tb(
        .clk(clk),
        .reset_n(rst_n),
        .enable(enable),
        .clt_valid(clt_valid),
        .clt_out(clt_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;

        #20;

        rst_n = 1; 

        enable = 1;


        $display("==================================================");
        $display("   STARTING CLT TEST (200 Cycles)");
        $display("==================================================");
        $display(" Cycle |   Binary   | Unsigned | Signed | Valid");
        $display("--------------------------------------------------");
        $display("   Normalization Factor (Divisor): %0d", int'(DIVISOR));

        for (int i = 1; i <= 800; i++) begin 
            @(posedge clk); 
            #1;
            
            if (clt_valid) begin
            // Calculation using the real cast to avoid integer division
            float_val = real'($signed(clt_out)) / real'(1 << WIDTH);

            // Using %0d and %0b for cleaner formatting
            $display("%4d  |  %12b  |   %4d    |  %4d  |  %f | %1b", 
                      i, clt_out, clt_out, $signed(clt_out), float_val, clt_valid);
        end
        end

        $display("==================================================");
        $display("   TEST FINISHED");
        $display("==================================================");

        $finish;

    end




endmodule