module arbiter (
    input logic clk,
    input logic reset,
    input logic req_calc,
    input logic req_debug,
    
    output logic gnt_calc,
    output logic gnt_debug
);


assign gnt_calc = req_calc;

assign gnt_debug = req_debug & (~req_calc);
    
endmodule