`timescale 1ns / 1ps

module top_modul(
    input  logic clk,        
    input  logic reset,

    input logic [7:0] x_in,
    input logic       x_valid,
    output logic [31:0] bnn_result,
    output logic        bnn_valid,
    input logic         ready_to_resive      
);

    logic [7:0] fifo_data_out;
    logic       fifo_empty;
    logic       alu_ready_out;
    logic       alu_start;
    logic       fifo_pop;
    logic       fifo_full;
    logic       clt_is_valid;
    logic       result_ready;


    main_fsm u_fsm(
        .clk(clk),
        .reset(reset),
        // Status
        .fifo_empty(fifo_empty),
        .clt_is_valid(clt_is_valid),
        .alu_ready_out(alu_ready_out),
        // Command
        .fifo_pop(fifo_pop),
        .alu_start(alu_start),
        .bnn_valid(bnn_valid)

    );


    

    sync_fifo u_fifo (
        .clk(clk),
        .reset(reset),

        .push(x_valid),
        .wr_data(x_in),
        .pop(fifo_pop),
        .rd_data(fifo_data_out),
        
        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty)
    );


    logic [7:0] mu;
    logic [7:0] sigma;
    logic [7:0] bias;
    logic [9:0] epsilon;
    
    

    bnn_alu u_alu(
        .clk(clk),
        .reset(reset),
        .valid_in(~fifo_empty & clt_is_valid & ~fifo_full),       
        .ready_out(alu_ready_out),
        .x(fifo_data_out),     

        // Rom
        .mu(mu),
        .sigma(sigma),
        .bias(bias),
        .epsilon(epsilon),

        // Handshake Output    
        .valid_out(result_valid),
        .ready_in(alu_start),

        .y_out(bnn_result)
    );

    logic [3:0] rom_addr;

    assign rom_addr = 4'd0;
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