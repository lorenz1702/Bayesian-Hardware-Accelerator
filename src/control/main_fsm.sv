`timescale 1ns / 1ps

typedef enum{
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

State state, next_state;

always_ff @(posedge clk) begin
    if (reset) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always_comb begin
    case (state) 
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
            
        end
        DONE: begin
            
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

endmodule