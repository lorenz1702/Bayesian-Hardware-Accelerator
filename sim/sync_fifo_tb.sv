`timescale 1ns / 1ps

module sync_fifo_tb;

    // Parameters
    parameter DATA_WIDTH = 32;
    parameter FIFO_DEPTH = 16;
    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

    // Clock and reset
    logic clk;
    logic reset;

    // FIFO signals
    logic push;
    logic [DATA_WIDTH-1:0] wr_data;
    logic pop;
    logic [DATA_WIDTH-1:0] rd_data;
    logic fifo_full;
    logic fifo_empty;

    // Instantiate the FIFO
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .push(push),
        .wr_data(wr_data),
        .pop(pop),
        .rd_data(rd_data),
        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty)
    );

    // Clock generation (100MHz clock)
    initial clk = 0;
    always #5 clk = ~clk; // Clock period of 10ns

    integer i;
    integer j;
    reg [DATA_WIDTH-1:0] test_data [0:31];
    // Test stimulus
    initial begin
        // Initialize signals
        reset = 1;
        push = 0;
        wr_data = 0;
        pop = 0;

        // Display header
        $display("Starting FIFO Testbench...");
        $display("----------------------------");

        // Apply reset
        #20;
        reset = 0;
        #10;

        // Test Case 1: Fill the FIFO
        $display("Test Case 1: Filling the FIFO");
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            if (!fifo_full) begin
                push = 1;
                wr_data = i + 100; // Arbitrary data
                #10;
            end else begin
                $display("FIFO is full at time %0t", $time);
            end
        end
        push = 0;

        // Check if FIFO is full
        if (fifo_full)
            $display("FIFO is full as expected at time %0t", $time);
        else
            $display("Error: FIFO is not full when it should be at time %0t", $time);

        // Test Case 2: Attempt to push when FIFO is full
        $display("Test Case 2: Attempting to push when FIFO is full");
        push = 1;
        wr_data = 999; // Data that should not be written
        #10;
        push = 0;
        if (fifo_full)
            $display("Push operation ignored as FIFO is full, as expected");
        else
            $display("Error: FIFO full flag not set correctly");

        // Test Case 3: Empty the FIFO
        $display("Test Case 3: Emptying the FIFO");
        for (i = 0; i < FIFO_DEPTH-1; i = i + 1) begin
            if (!fifo_empty) begin
                pop = 1;
                #10;
                pop = 0;
                // Check the read data
                if (rd_data !== (i + 100)) begin
                    $display("Data mismatch at time %0t: expected %0d, got %0d", $time, i + 100, rd_data);
                end else begin
                    $display("Data match at time %0t: read %0d", $time, rd_data);
                end
            end else begin
                $display("FIFO is empty earlier than expected at time %0t", $time);
            end
        end

        // Check if FIFO is empty
        if (fifo_empty)
            $display("FIFO is empty as expected at time %0t", $time);
        else
            $display("Error: FIFO is not empty when it should be at time %0t", $time);

        // Test Case 4: Attempt to pop when FIFO is empty
        $display("Test Case 4: Attempting to pop when FIFO is empty");
        pop = 1;
        #10;
        pop = 0;
        if (fifo_empty)
            $display("Pop operation ignored as FIFO is empty, as expected");
        else
            $display("Error: FIFO empty flag not set correctly");

        // Test Case 5: Simultaneous push and pop
        $display("Test Case 5: Simultaneous push and pop operations");
        push = 1;
        wr_data = 200;
        pop = 0;
        #10;
        push = 1;
        wr_data = 100;
        pop = 1;
        #10;
        push = 0;
        pop = 0;
        if (rd_data !== 200) begin
            $display("Data mismatch during simultaneous operation at time %0t: expected 200, got %0d", $time, rd_data);
        end else begin
            $display("Simultaneous operation successful at time %0t: read %0d", $time, rd_data);
        end

        // Final check
        #10;
        push = 0;
        pop = 1;
        #10;
        push = 0;
        pop = 0;
        if (fifo_empty)
            $display("FIFO is empty after last operation, as expected");
        else
            $display("Error: FIFO is not empty after last operation");

        // Test Case 6: Random push/pop operations
        $display("Test Case 6: Random push/pop operations");
        // Generate random data
        for (j = 0; j < 32; j = j + 1) begin
            test_data[j] = $random;
        end

        // Push data into FIFO
        for (j = 0; j < 10; j = j + 1) begin
            if (!fifo_full) begin
                push = 1;
                wr_data = test_data[j];
                #10;
            end
        end
        push = 0;

        // Pop data from FIFO
        for (j = 0; j < 5; j = j + 1) begin
            if (!fifo_empty) begin
                pop = 1;
                #10;
                pop = 0;
                if (rd_data !== test_data[j]) begin
                    $display("Data mismatch at time %0t: expected %0h, got %0h", $time, test_data[j], rd_data);
                end else begin
                    $display("Data match at time %0t: read %0h", $time, rd_data);
                end
            end
        end

        // Finish simulation
        #20;
        $display("Testbench completed.");
        $finish;
    end

endmodule

