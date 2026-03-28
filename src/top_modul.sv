`timescale 1ns / 1ps

module top_modul(
    input  logic        clk,        
    input  logic        reset,

    // --- Input Interface (Direct) ---
    input  logic [7:0]  x_in,
    input  logic        x_valid,
    output logic        ready,          

    // --- Output Interface ---
    output logic [31:0] bnn_result,
    output logic        bnn_valid,
    input  logic        ready_to_receive      
);

    // Internal wires for handshake between modules
    logic clt_is_valid;
    logic alu_ready_out;
    logic result_valid;   

    // FSM Control Signals
    logic clt_enable;
    logic alu_valid_in;
    logic alu_ready_in;

    // ROM Wires
    logic [7:0] mu;
    logic [7:0] sigma;
    logic [7:0] bias;
    logic [9:0] epsilon;
    logic [3:0] rom_addr;

    assign rom_addr = 4'd0;

    // =========================================================================
    // 1. MAIN FSM 
    // =========================================================================
    main_fsm u_fsm(
        .clk(clk),
        .reset(reset),
        
        // --- Status (Inputs to the FSM) ---
        .x_valid(x_valid),
        .clt_is_valid(clt_is_valid),
        .alu_ready_out(alu_ready_out),
        .result_valid(result_valid),
        .ready_to_receive(ready_to_receive),
        
        // --- Commands (Outputs from the FSM) ---
        .ready(ready),             // Tells the outside world: "Top modul is ready"
        .clt_enable(clt_enable),       // Starts the clt generator
        .alu_valid_in(alu_valid_in),   // Starts the ALU
        .alu_ready_in(alu_ready_in),   // Tells the ALU: "Output was read"
        .bnn_valid(bnn_valid)          // Top-level output valid
    );

    // =========================================================================
    // 2. ROM
    // =========================================================================
    rom u_rom(
        .address(rom_addr),
        .mu(mu),
        .sigma(sigma),
        .bias(bias)
    );

    // =========================================================================
    // 3. CLT (Noise Generator)
    // =========================================================================
    CLT u_clt(
        .clk(clk),
        .reset(reset),
        .enable(clt_enable),           
        .clt_valid(clt_is_valid),
        .clt_out(epsilon)
    );

    // =========================================================================
    // 4. BNN ALU
    // =========================================================================
    bnn_alu u_alu(
        .clk(clk),
        .reset(reset),
        
        // Handshake Input
        .valid_in(alu_valid_in),       
        .ready_out(alu_ready_out),
        

        .x(x_in),     

        // Parameters
        .mu(mu),
        .sigma(sigma),
        .bias(bias),
        .epsilon(epsilon),

        // Handshake Output    
        .valid_out(result_valid),      
        .ready_in(alu_ready_in),

        // Data Output
        .y_out(bnn_result)
    );

endmodule