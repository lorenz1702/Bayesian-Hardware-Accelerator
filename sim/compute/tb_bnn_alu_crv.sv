

class AluTx;


    rand logic signed [7:0] x;
    rand logic signed [7:0] mu;
    rand logic signed [7:0] sigma;
    rand logic signed [9:0] epsilon;
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
        
  
        calc_w = (int'(mu) <<< 7) + (sigma * epsilon);
        result = (calc_w * x) + (int'(bias) <<< 7);
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
    logic signed [31:0] y_tmp;
    bnn_alu u_alu(.*);

    always #5 clk = ~clk;

    
    int expected_queue [$]; 

    
    always @(posedge clk) begin
        if (valid_in && ready_out) begin
            
            expected_queue.push_back(expected_y(x, mu, sigma, epsilon, bias));
        end
    end

    
    always @(negedge clk) begin
        if (valid_out && ready_in) begin
            
            
            if (expected_queue.size() > 0) begin
                
                
                int expected_val = expected_queue.pop_front();
                
                real hw_real = to_fixed_point(y_out, Y_FRAC_BITS);
                real sw_real = to_fixed_point(expected_val, Y_FRAC_BITS); 
                
                if (y_out !== expected_val) begin
                    $error("❌ MISMATCH: HW=%0d (%.3f) | SW=%0d (%.3f)", 
                           $signed(y_out), hw_real, $signed(expected_val), sw_real);
                end else begin
                    $display("✅ MATCH: Y = %0d (As fixed-Point: %.3f)", $signed(y_out), hw_real);
                end
                
            end else begin
                $error("❌ HW is valid_out, but SW Model is empty!");
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
        
        $display("✅ TC-1.1 finished!");

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
        $display("✅ TC-1.2 finished!");


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
        $display("✅ TC-1.3 finished!");

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
        $display("✅ TC-1.4 finished!");



        // =========================================================================
        // [TC-1.5] EXTREME VALUES (Corner Cases & Overflow Check)
        // =========================================================================
        $display("\n--------------------------------------------------");
        $display(" 🌋 STARTING TC-1.5: EXTREME VALUES (Max/Min)");
        $display("--------------------------------------------------");

        for (int i = 0; i < 10; i++) begin
            
            
            if (!tx.randomize() with {
                
                x       inside {8'h7F, 8'h80};
                mu      inside {8'h7F, 8'h80};
                sigma   inside {8'h7F, 8'h80};
                bias    inside {8'h7F, 8'h80};
                
     
                epsilon inside {10'h1FF, 10'h200};
            }) begin
                $fatal("❌ Randomize failed!");
            end
            
            
            x       = tx.x;
            mu      = tx.mu;
            sigma   = tx.sigma;
            epsilon = tx.epsilon;
            bias    = tx.bias;
            
            
            // 2. Handshake starten
            valid_in = 1'b1;

            // 3. Auf die Flanke warten, ALU lesen lassen, DANN abschalten!
            @(posedge clk);
            #1;               // <--- DER RETTER IN DER NOT!
            valid_in = 1'b0;

            // 4. Warten bis die ALU fertig gerechnet hat
            wait(valid_out == 1'b1);
            
            // 5. Einen Takt warten, damit die Queue lesen kann
            @(posedge clk);
            #1;               // <--- Auch hier sicherheitshalber
            
        end
        $display("✅ TC-1.5 completed!");




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
        $display("✅ TC-2.1 finished!");


        // =========================================================================
        // [TC-2.2] Receiver Backpressure
        // =========================================================================
        $display("\n--------------------------------------------------");
        $display(" 🟢 START TC-2.2: Receiver Backpressure");
        $display("--------------------------------------------------");

        

        y_tmp = y_out;

        for (int i = 0; i < 10; i++) begin
            if (!tx.randomize()) $fatal("Randomization failed!");   
            ready_in = 0; 

            @(posedge clk);
            #1;  
            x       = tx.x;
            mu      = tx.mu;
            sigma   = tx.sigma;
            epsilon = tx.epsilon;
            bias    = tx.bias;
        
            valid_in = 1'b1;

            if (y_out !== y_tmp) begin
                    $error("❌ Not Stable: HW=%0d | Old_value=%0d ", 
                           $signed(y_out), $signed(y_tmp));
                end else begin
                    $display("✅ Stable: Y = %0d ", $signed(y_out));
                end
            
            
            @(posedge clk);
            #1;
        end

        ready_in =1;

        @(posedge clk);
        #1;

        if (y_out !== y_tmp) begin
            $display("✅ Changed right: Y = %0d", $signed(y_out));
        end else begin
            $error("❌ Did not change: Y = %0d", $signed(y_out));
        end
    


        $display("✅ TC-2.2 finished!");

        // =========================================================================
        // [TC-2.3] SENDER STARVATION 
        // =========================================================================
        $display("\n--------------------------------------------------");
        $display(" 🏜️ STARTE TC-2.3: SENDER STARVATION");
        $display("--------------------------------------------------");

        
        if (!tx.randomize()) $fatal("❌ Randomize fehlgeschlagen!");
        x = tx.x; mu = tx.mu; sigma = tx.sigma; epsilon = tx.epsilon; bias = tx.bias;
        
        valid_in = 1'b1;
        ready_in = 1'b1; 
        
        @(posedge clk);
        
        
        valid_in = 1'b0; 
        
       
        wait(valid_out == 1'b1);
        

        @(posedge clk); 
        

        $display("Watch valid_out for 5 clocks...");
        
        for (int i = 0; i < 5; i++) begin
            @(posedge clk);
            
            
            if (valid_out !== 1'b0) begin
                $error("❌ ERROR: valid_out is 1, even though valid_in has been 0!");
            end else begin
                $display("✅ Starvation cycle %0d: valid_out correctly remains 0.", i+1);
            end
        end
        
        $display("✅ TC-2.3 finished!");


        $finish; 
    
    end
    // =========================================================================
    // GLOBALER WATCHDOG TIMER
    // =========================================================================
    initial begin

        #50000; 
        
        $fatal("\n=======================================================\n❌ GLOBAL WATCHDOG TIMEOUT).\n=======================================================\n");
    end

    

endmodule