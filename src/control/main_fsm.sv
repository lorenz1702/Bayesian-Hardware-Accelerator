`timescale 1ns / 1ps

typedef enum logic [1:0]{
    IDLE,
    FETCH_WEIGHTS,
    CALC,
    DONE
} State;


module main_fsm(
    input logic clk,
    input logic reset,
    input logic sync_start,

    // Communication with arbiter
    output logic req_fsm,
    input logic gnt_fsm,

    // Communication fifo
    output logic 

    output logic [3:0] addr,

);

State current_state, next_state;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state   <= IDLE;
    end else begin
        current_state   <= next_state;
        bnn_valid       <= 1'b0;
    end
end

always_comb begin

    case (current_state) 
        IDLE: begin
            next_state = (sync_start==2'b01) ? FETCH_WEIGHTS : IDLE;
        end
        FETCH_WEIGHTS: begin
            req_fsm = 1;
            if (gnt_fsm) begin
                addr = 2'b00;
                next_state = CALC;
            end else begin
                next_state = FETCH_WEIGHTS;
            end
        end
        CALC: begin
            if (clt_is_valid & alu_ready_out)begin
                next_state = DONE;
            end
        end
        DONE: begin
            bnn_valid = 1'b1;
            next_state = IDLE;
            
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

endmodule