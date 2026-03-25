`timescale 1ns / 1ps

module bnn_alu(


    input logic clk,
    input logic reset,

    // Handshake Input
    input logic valid_in,  //FIFO: Data is there
    output logic ready_out, //ALU: Is ready

    input signed [7:0] x,
    input signed [7:0] mu,
    input signed [7:0] sigma,
    input signed [9:0] epsilon,
    input signed [7:0] bias,

    //Handshake Output 
    output logic valid_out,  //result ready
    input logic ready_in,     //Outworld read ready

    output signed [31:0] y_out
    );

    logic signed [31:0] y_acc;

    logic signed [17:0] w;
    logic signed [31:0] product;

    assign ready_out = ready_in;

    assign y_out = y_acc;
    
    always_comb begin
        w = (18'(mu) <<< 7) + (sigma * epsilon);
        product = (w * x) + (32'(bias) <<< 7);
    end


    always_ff @(posedge clk) begin
        if (reset) begin 
            y_acc <= 0;
            valid_out <= 0;
        end else begin
            if (valid_in && ready_out) begin
                
                y_acc <= product;
                valid_out <= 1;
            end else if (valid_out && ready_in) begin
                valid_out <= 0;
            end
        end
    end
endmodule