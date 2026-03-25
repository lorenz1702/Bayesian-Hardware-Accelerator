`timescale 1ns / 1ps

module CLT #(
    parameter int NUM_STAGES = 3,
    parameter int WIDTH = 8,
    parameter int TAPS = 8'hB8,
    parameter logic [WIDTH-1:0] BASE_SEED = 8'hA5
) (
    input logic clk,
    input logic reset,
    input logic enable,

    output logic clt_valid,
    output logic signed [WIDTH + $clog2(NUM_STAGES) - 1 : 0] clt_out
);

logic [WIDTH-1:0] lfsr_state [NUM_STAGES];

genvar i;

generate
    for (i = 0; i < NUM_STAGES; i++) begin : gen_lfsr_stages
        lfsr #(.WIDTH(WIDTH),           
    .SEED(BASE_SEED ^ (i * 32'h9E3779B1)),        
    .TAPS(TAPS) )lfsr_u(
        .clk(clk),
        .rst(reset),
        .lfsr(lfsr_state[i])
    );



    end
endgenerate

logic signed [WIDTH + $clog2(NUM_STAGES) - 1 : 0] sum_temp;

always_comb begin
    sum_temp = 0;

    for (int k = 0; k < NUM_STAGES; k++) begin
        sum_temp = sum_temp + $signed (lfsr_state[k]);
    end

    
end

logic [$clog2(WIDTH-1):0] wait_counter;

always_ff @(posedge clk) begin
    if (reset) begin
        clt_out <= 0;
        clt_valid <= 0;
        wait_counter <= 0;
    end else if (enable) begin  
        
        // Check if we have already waited for WIDTH clock cycles
        // (WIDTH - 1, because we start counting from 0)
        if (wait_counter == (WIDTH - 1)) begin
            clt_out <= sum_temp;    
            clt_valid <= 1;         // Assert valid for exactly one clock cycle!
            wait_counter <= 0;      // Reset the counter
        end else begin
            clt_valid <= 0;         
            wait_counter <= wait_counter + 1; 
        end
        
    end else begin
        clt_valid <= 0; 
    end
end
    
endmodule