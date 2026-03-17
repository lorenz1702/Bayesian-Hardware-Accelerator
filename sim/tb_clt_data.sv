`timescale 1ns / 1ps

module tb_clt_data;

    // Parameters for a wide Gaussian curve (Range approx. -6 to +6 with 12 stages)
    localparam int NUM_STAGES = 12;
    // localparam int WIDTH = 8;
    // localparam int TAPS = 8'hB8;
    // localparam logic [WIDTH-1:0] BASE_SEED = 8'hA5;

    localparam int WIDTH = 16;
    localparam logic [WIDTH-1:0] SEED = 16'h5678;
    localparam logic [WIDTH-1:0] TAPS = 16'hB400;



    // Total number of valid samples to collect for the Python plot
    localparam int SAMPLES_TO_COLLECT = 100000;
    // Ensure the simulation runs long enough to collect all samples
    localparam int SIMULATION_CYCLES = (SAMPLES_TO_COLLECT + 10) * WIDTH;

    logic clk;
    logic rst_n;
    logic enable;

    logic clt_valid;
    logic signed [WIDTH + $clog2(NUM_STAGES) - 1 : 0] clt_out;

    // Instantiate the Central Limit Theorem (CLT) module
    CLT #(
        .NUM_STAGES(NUM_STAGES),
        .WIDTH(WIDTH),
        .TAPS(TAPS),
        .BASE_SEED(BASE_SEED)
    ) u_clt (
        .clk(clk),
        .reset_n(rst_n),
        .enable(enable),
        .clt_valid(clt_valid),
        .clt_out(clt_out)
    );

    // Clock generator (100 MHz -> 10ns period)
    always #5 clk = ~clk;

    int sample_counter = 0;
    int file_id; // File handle for data export
    real float_val;

    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        enable = 0;
        sample_counter = 0;

        // Open file for writing the results
        file_id = $fopen("clt_data.txt", "w");
        if (!file_id) begin
            $display("ERROR: Could not open file clt_data.txt for writing.");
            $finish;
        end

        $display("==================================================");
        $display("   STARTING DATA COLLECTION");
        $display("   Stages: %0d, Width: %0d", NUM_STAGES, WIDTH);
        $display("   Target samples: %0d", SAMPLES_TO_COLLECT);
        $display("==================================================");

        #100; // Reset phase
        rst_n = 1;
        #20;
        enable = 1; // Enable the CLT logic

        // Collection loop
        while (sample_counter < SAMPLES_TO_COLLECT) begin
            @(posedge clk);
            #1; // Wait for non-blocking assignments to stabilize

            if (clt_valid) begin
                // Scaling: Convert the raw sum to a normalized float value
                float_val = real'($signed(clt_out)) / real'(1 << WIDTH);
                
                // Write only the raw float value to the file for easy Python parsing
                $fdisplay(file_id, "%f", float_val);
                
                sample_counter++;
                
                // Print progress to console every 1000 samples
                if (sample_counter % 1000 == 0) begin
                    $display("Collected %0d / %0d samples...", sample_counter, SAMPLES_TO_COLLECT);
                end
            end
        end

        // Cleanup and finish
        $fclose(file_id);
        $display("==================================================");
        $display("   DATA COLLECTION FINISHED");
        $display("   Data saved in: scripts/clt_data.txt");
        $display("==================================================");

        $finish;
    end

endmodule