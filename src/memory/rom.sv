`timescale 1ns / 1ps


module rom(
    input wire [3:0] address,
    output reg signed [7:0] mu,
    output reg signed [7:0] sigma,
    output reg signed [7:0] bias

    );
    
    reg [15:0] rom_array [0:15];
    
    reg [23:0] bias_array [0:0];
    
    initial begin
        $readmemh("../src/memory/weight.mem", rom_array);
        $readmemh("../src/memory/bias.mem", bias_array);
    end
    
    always @(*) begin
        // the first 8 Bit are mu, the latest 8 Bit are sigma
        mu    = rom_array[address][15:8];
        sigma = rom_array[address][7:0];
        
        bias  = bias_array[0];
    end
    
endmodule