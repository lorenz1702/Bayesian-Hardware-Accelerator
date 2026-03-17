`timescale 1ns / 1ps

module top_modul(
    input  logic clk,        
    input  logic reset,

    input logic [7:0] x_in,
    input logic       x_valid,
    output logic [23:0] bnn_result,
    output logic        bnn_valid      
);

    logic [7:0] fifo_data_out;
    logic       fifo_empty;
    logic       alu_ready_out:
    

    sync_fifo u_fifo (
        .clk(clk),
        .reset(reset),

        .push(x_valid),
        .wr_data(x_in),
        .pop(alu_ready_out & ~fifo_empty),
        .rd_data(fifo_data_out),
        
        .fifo_empty(fifo_empty)
    );


    logic [7:0] mu;
    logic [7:0] sigma;
    logic [7:0] bias;
    logic [9:0] epsilon;
    logic        clt_is_valid;

    bnn_alu u_alu(
        .clk(clk),
        .reset(reset),
        .valid_in(~fifo_empty & clt_is_valid),       
        .ready_out(alu_ready_out),
        .x(fifo_data_out),     

        // Rom
        .mu(mu),
        .sigma(sigma),
        .bias(bias),
        .epsilon(epsilon),

        // Handshake Output    
        .valid_out(bnn_valid),
        .ready_in(1),

        .y_out(bnn_result)
    );

    logic [3:0] rom_addr;
    // ROM
    rom u_rom(
        .address(rom_addr),
        .mu(mu),
        .sigma(sigma),
        .bias(bias)
    );



    CLT u_clt(
        .clk(clk),
        .reset(reset),
        .enable(~fifo_empty),
        .clt_valid(clt_is_valid),
        .clt_out(epsilon)
    );



endmodule