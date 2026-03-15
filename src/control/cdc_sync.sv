`timescale 1ns / 1ps

module cdc_sync(
    input logic clk,
    input logic async_start,
    output logic sync_start
);
    logic ff1;
    always_ff @(posedge clk) begin
        ff1         <= async_start;
        sync_start  <= ff1;
    end
endmodule