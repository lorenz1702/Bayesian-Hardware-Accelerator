

class AluTx;


    rand logic signed [7:0] x;
    rand logic signed [7:0] mu;
    rand logic signed [7:0] sigma;
    rand logic signed [7:0] epsilon;
    rand logic signed [7:0] bias;
    
endclass 




module tb_bnn_alu_crv;

    function int expected_y(
    input logic signed [7:0] x, 
        input logic signed [7:0] mu, 
        input logic signed [7:0] sigma, 
        input logic signed [9:0] epsilon, 
        input logic signed [7:0] bias
    );
        int calc_w;
        int result;
        
  
        calc_w = (int'(mu) <<< 6) + (sigma * epsilon);
        result = (calc_w * x) + (int'(bias) <<< 12);
        return result;
    endfunction

    function real to_fixed_point(input int raw_value, input int frac_bits);

        return $itor(raw_value) / (2.0 ** frac_bits);
    endfunction

    localparam int Y_FRAC_BITS = 18;
    logic clk = 0;
    logic reset;
    logic valid_in;
    logic ready_out;
    logic signed [7:0]     x;
    logic signed [7:0]     mu; 
    logic signed [7:0]     sigma;
    logic signed [9:0]     epsilon; 
    logic signed [7:0]     bias;

    logic valid_out;
    logic ready_in;

    logic signed [31:0] y_out;

    bnn_alu u_alu(.*);

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (valid_out && ready_in) begin
            int expected_val = expected_y(x, mu, sigma, epsilon, bias);
            
            
            real hw_real = to_fixed_point(y_out, Y_FRAC_BITS);
            real sw_real = to_fixed_point(expected_val, Y_FRAC_BITS);
            
            if (y_out !== expected_val) begin
                // Mit $signed(...) zwingen wir ihn, das Vorzeichen zu beachten!
                $error("❌ MISMATCH: HW=%0d (%.3f) | SW=%0d (%.3f)", 
                       $signed(y_out), hw_real, $signed(expected_val), sw_real);
            end else begin
                $display("✅ MATCH: Y = %0d (As fixed-Point: %.3f)", 
                         $signed(y_out), hw_real);
            end
        end
    end



    initial begin
        AluTx tx;
        tx = new();


        // Setup & Reset
        valid_in = 0;
        ready_in = 1; 
        reset = 1;
        #20 reset = 0;

        $display("🚀 STARTE BNN-ALU TEST-SEQUENZ");

        // =========================================================================
        // [TC-1.1] ALL POSITIVE 
        // =========================================================================
        $display("\n--------------------------------------------------");
        $display(" 🟢 STARTE TC-1.1: ALL POSITIVE");
        $display("--------------------------------------------------");




        for (int i = 0; i < 10; i++) begin
            if (!tx.randomize() with {
                x       > 0;
                mu      > 0;
                sigma   > 0;
                epsilon > 0;
                bias    > 0;
            }) begin
                $fatal("❌ Randomize fehlgeschlagen!");
            end

            @(posedge clk);
            #1;  
            x       = tx.x;
            mu      = tx.mu;
            sigma   = tx.sigma;
            epsilon = tx.epsilon;
            bias    = tx.bias;
            
            valid_in = 1'b1;


            @(posedge clk);
            #1; 
            valid_in = 1'b0; 

            wait(valid_out == 1'b1);


            @(posedge clk);
            #1;
        end
        
        $display("✅ TC-1.1 abgeschlossen!");

        // =========================================================================
        // [TC-1.1] ALL NEGATIVE
        // =========================================================================
        $display("\n--------------------------------------------------");
        $display(" 🟢 STARTE TC-1.2: ALL NEGATIVE");
        $display("--------------------------------------------------");


        


        for (int i = 0; i < 10; i++) begin
            if (!tx.randomize() with {
                x       > 0;
                mu      > 0;
                sigma   > 0;
                epsilon > 0;
                bias    > 0;
            }) begin
                $fatal("❌ Randomize fehlgeschlagen!");
            end

            @(posedge clk);
            #1;  
            x       = tx.x;
            mu      = tx.mu;
            sigma   = tx.sigma;
            epsilon = tx.epsilon;
            bias    = tx.bias;
            
            valid_in = 1'b1;


            @(posedge clk);
            #1; 
            valid_in = 1'b0; 

            wait(valid_out == 1'b1);


            @(posedge clk);
            #1;
        end
        $display("✅ TC-1.2 abgeschlossen  6666!");


        // =========================================================================
        // [TC-1.1] MIXED Signed
        // =========================================================================
        $display("\n--------------------------------------------------");
        $display(" 🟢 STARTE TC-1.3: MIXED SIGNED");
        $display("--------------------------------------------------");


        


        for (int i = 0; i < 10; i++) begin
            if (!tx.randomize()) $fatal("Randomization failed!");   

            @(posedge clk);
            #1;  
            x       = tx.x;
            mu      = tx.mu;
            sigma   = tx.sigma;
            epsilon = tx.epsilon;
            bias    = tx.bias;
            
            valid_in = 1'b1;


            @(posedge clk);
            #1; 
            valid_in = 1'b0; 

            wait(valid_out == 1'b1);


            @(posedge clk);
            #1;
        end
        $display("✅ TC-1.3 abgeschlossen!");

        // =========================================================================
        // [TC-1.4] Multiplication with Zero
        // =========================================================================
        $display("\n--------------------------------------------------");
        $display(" 🟢 STARTE TC-1.4: Mulitiplication with zero");
        $display("--------------------------------------------------");


        


        for (int i = 0; i < 10; i++) begin
            if (!tx.randomize() with {
                x == 0 || sigma == 0 || epsilon == 0;
            }) begin
                $fatal("❌ Randomize fehlgeschlagen!");
            end
            @(posedge clk);
            #1;  
            x       = tx.x;
            mu      = tx.mu;
            sigma   = tx.sigma;
            epsilon = tx.epsilon;
            bias    = tx.bias;
            
            valid_in = 1'b1;


            @(posedge clk);
            #1; 
            valid_in = 1'b0; 

            wait(valid_out == 1'b1);


            @(posedge clk);
            #1;
        end
        $display("✅ TC-1.4 abgeschlossen!");

        // =========================================================================
        // [TC-2.1] Continuous Flow(Pipeline ideal)
        // =========================================================================
        $display("\n--------------------------------------------------");
        $display(" 🟢 STARTE TC-2.1: Continuous Flow (Pipeline ideal)");
        $display("--------------------------------------------------");




        for (int i = 0; i < 10; i++) begin
            if (!tx.randomize()) $fatal("Randomization failed!");   

            @(posedge clk);
            #1;  
            x       = tx.x;
            mu      = tx.mu;
            sigma   = tx.sigma;
            epsilon = tx.epsilon;
            bias    = tx.bias;
            
            valid_in = 1'b1;


            @(posedge clk);
            #1; 
            valid_in = 1'b1; 

            wait(valid_out == 1'b1);


            @(posedge clk);
            #1;
        end
        $display("✅ TC-2.1 abgeschlossen!");

        $finish; 
        
    end
    

    

endmodule