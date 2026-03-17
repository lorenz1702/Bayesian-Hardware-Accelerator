`timescale 1ns / 1ps

module lfsr #(
    parameter int WIDTH = 16,
    parameter logic [WIDTH-1:0] SEED = 16'h5678,
    // Bin: 1011_0100_0000_0000 -> Hexadecimal: B400
    parameter logic [WIDTH-1:0] TAPS = 16'hB400
)(
    input wire clk,
    input wire rst,
    output reg [WIDTH-1:0] lfsr
);
    wire feedback;

    assign  feedback = ^(lfsr & TAPS);

    always @(posedge clk) begin
        if (rst) begin
            lfsr <= SEED; 
        end else begin
            lfsr <= {lfsr[WIDTH-2 : 0], feedback};
        end
    end

endmodule