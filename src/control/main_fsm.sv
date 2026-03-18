`timescale 1ns / 1ps



module main_fsm(
    input logic clk,
    input logic reset,

    // --- Status-Signale vom Datenpfad (Inputs) ---
    input  logic fifo_empty,
    input  logic clt_is_valid,
    input  logic alu_ready_out,


    // --- Steuer-Signale an den Datenpfad (Outputs) ---
    output logic fifo_pop,
    output logic alu_start,
    output logic bnn_valid,

    // Communication fifo

    output logic [3:0] addr

);

typedef enum logic [1:0]{
    IDLE,
    CALC,
    DONE
} State;

State current_state, next_state;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state   <= IDLE;
    end else begin
        current_state   <= next_state;
        
    end
end

always_comb begin
    next_state = current_state;
    bnn_valid  = 1'b0;
    fifo_pop   = 1'b0;
    alu_start  = 1'b0;

    case (current_state) 
        IDLE: begin
            if (~fifo_empty) begin
                    next_state = CALC;
                end
        end

        CALC: begin
            alu_start = 1'b1;
            if (clt_is_valid & alu_ready_out)begin
                next_state = DONE;
            end else next_state = CALC;
        end
        
        DONE: begin
            bnn_valid = 1'b1;
            fifo_pop  = 1'b1;
            next_state = IDLE;
            
        end
        default: next_state = IDLE;
    endcase
end

endmodule