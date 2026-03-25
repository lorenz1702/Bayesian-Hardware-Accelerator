`timescale 1ns / 1ps

module tb_lfsr;

    
    reg clk;
    reg rst;
    logic [7:0] lfsr_out;
    real float_val;

    
    lfsr #(
    .WIDTH(8),           
    .SEED(8'hA1),        
    .TAPS(8'hB8)         //  (1011_1000)
    ) lfsr_8bit_inst (
    .clk(clk),
    .rst_n(rst),
    .lfsr(lfsr_out) 
    );


    
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;

        #20;
        rst = 1;

        $display("==================================================");
        $display("   STARTING LFSR TEST (200 Cycles)");
        $display("==================================================");
        $display(" Cycle |   Binary   | Unsigned | Signed ");
        $display("--------------------------------------------------");

        // Automate 200 test cycles
        for (int i = 1; i <= 200; i++) begin
            @(posedge clk); 
            #1; 


            

            float_val = ($signed(lfsr_out)) / 128.0;

          
            $display("%4d  |  %8b  |   %3d    |  %4d  |  %f", 
            i, lfsr_out, lfsr_out, $signed(lfsr_out), float_val);

        end

        $display("==================================================");
        $display("   TEST FINISHED");
        $display("==================================================");

        $finish;
    end

endmodule