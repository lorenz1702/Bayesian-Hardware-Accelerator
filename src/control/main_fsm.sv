`timescale 1ns / 1ps

module main_fsm(
    input  logic clk,
    input  logic reset,

    // --- Status (Inputs from outside & datapath) ---
    input  logic x_valid,
    input  logic clt_is_valid,
    input  logic alu_ready_out,
    input  logic result_valid,
    input  logic ready_to_receive,

    // --- Commands (Outputs to outside & datapath) ---
    output logic x_ready,
    output logic clt_enable,
    output logic alu_valid_in,
    output logic alu_ready_in,
    output logic bnn_valid
);

    // Define the 3 states
    typedef enum logic [1:0] {
        IDLE,           
        WAIT_FOR_CLT,   
        WAIT_FOR_ALU    
    } state_t;

    state_t current_state, next_state;

    // =========================================================================
    // 1. STATE MEMORY 
    // =========================================================================
    always_ff @(posedge clk) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end


    always_comb begin
        
        next_state   = current_state;
        x_ready      = 1'b0;
        clt_enable   = 1'b0;
        alu_valid_in = 1'b0;
        alu_ready_in = 1'b0;
        bnn_valid    = 1'b0;

        case (current_state) 
            

            IDLE: begin
                
                
                if (x_valid) begin
                    clt_enable = 1'b1; 
                    next_state = WAIT_FOR_CLT;
                end
            end


            WAIT_FOR_CLT: begin
                clt_enable = 1'b1;
                alu_ready_in = 1'b1; 
                
                if (clt_is_valid && alu_ready_out) begin
                    alu_valid_in = 1'b1; 
                    x_ready      = 1'b1; 
                    next_state   = WAIT_FOR_ALU;
                end
            end
            


            WAIT_FOR_ALU: begin
                // Directly connect the ALU's valid signal to the top-level output
                bnn_valid = result_valid;

                
                if (result_valid && ready_to_receive) begin
                    alu_ready_in = 1'b1; // Result was read!
                    next_state   = IDLE; 
                end
            end
            
            // Safety catch
            default: next_state = IDLE;
            
        endcase
    end

endmodule