`timescale 1ns / 1ps

module tb_compute_core();

    logic clk;
    logic reset;
    
    logic valid_in;
    logic ready_out;
    
    logic signed [7:0] x;
    logic signed [7:0] mu;
    logic signed [7:0] sigma;
    logic signed [7:0] epsilon;
    logic signed [7:0] bias;
    
    logic valid_out;
    logic ready_in;
    logic signed [31:0] y_out;

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    // Instantiate DUT (Device Under Test)
    bnn_alu dut (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_in),
        .ready_out(ready_out),
        .x(x),
        .mu(mu),
        .sigma(sigma),
        .epsilon(epsilon),
        .bias(bias),
        .valid_out(valid_out),
        .ready_in(ready_in),
        .y_out(y_out)
    );

    initial begin
        $display("Starting Handshake Testbench...");
        $monitor("Time: %4t | val_in: %b | rdy_out: %b || val_out: %b | rdy_in: %b || y_acc: %0d", 
                 $time, valid_in, ready_out, valid_out, ready_in, y_out);

        // System Initialization
        clk = 0;
        reset = 1;
        valid_in = 0;
        ready_in = 0;
        x = 0; mu = 0; sigma = 0; epsilon = 0; bias = 0;
        
        #20 reset = 0;
        @(posedge clk);
        #1;


        $display("\n--- Test 1: Ideal Flow (Both sides always ready/valid) ---");
        ready_in = 1; 

        // Input 1: w = 10 + (2 * 1) = 12  --> y = 0 + (12 * 2) = 24
        x = 2; mu = 10; sigma = 2; epsilon = 1; 
        valid_in = 1;
        @(posedge clk);
        #1;

        // Input 2: w = 5 + (0 * 0) = 5    --> y = 24 + (5 * 3) = 39
        x = 3; mu = 5; sigma = 0; epsilon = 0; bias = 3;
        valid_in = 1;
        @(posedge clk);
        #1;

        valid_in = 0; // Stop sending
        @(posedge clk);
        #1;


        $display("\n--- Test 2: Sender Stall (FIFO empty) ---");
        // Receiver is still ready, but we don't send valid data for a cycle
        ready_in = 1;
        valid_in = 0;
        
        x = 100; // Garbage data (should NOT be accumulated!)
        @(posedge clk);

        // Now we send valid data again
        // w = 2 + (0*0) = 2 --> y = 39 + (2 * 10) = 59
        x = 10; mu = 2; sigma = 0; epsilon = 0;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
        @(posedge clk);


        $display("\n--- Test 3: Receiver Stall (Backpressure) ---");
        // We send valid data, but the next stage is NOT ready
        ready_in = 0; 
        valid_in = 1;
        
        // w = 1 + (0*0) = 1 --> y = 59 + (1 * 5) = 64
        x = 5; mu = 1; sigma = 0; epsilon = 0;
        @(posedge clk);
        
        // MAC computed the result and sets valid_out = 1.
        // But because ready_in = 0, it should pause here!
        valid_in = 0; // We stop sending new inputs
        
        // Wait 3 clock cycles. y_acc should NOT change, valid_out MUST stay 1.
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        // Finally, the next stage is ready to accept the data
        ready_in = 1;
        @(posedge clk);
        
        // Clean up
        ready_in = 0;
        @(posedge clk);

        $display("\nSimulation Finished.");
        $finish;
    end

endmodule