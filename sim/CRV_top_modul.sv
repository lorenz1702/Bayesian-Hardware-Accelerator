class Transaction;


    function new();
        
    endfunction //new()
endclass


module CRV_top_modul;
    function int expected_y(
        
    input logic signed [7:0] x, 
        input logic signed [7:0] mu, 
        input logic signed [7:0] sigma, 
        input logic signed [9:0] epsilon, 
        input logic signed [7:0] bias
    );
        int calc_w;
        int result;
        
  
        calc_w = (int'(mu) <<< 6) + (sigma * epsilon);
        result = (calc_w * x) + (int'(bias) <<< 12);
        return result;
    endfunction

    function real to_fixed_point(input int raw_value, input int frac_bits);

        return $itor(raw_value) / (2.0 ** frac_bits);
    endfunction


    logic clk;
    logic rst_n;
    logic [7:0] pixel_in;
    logic pixel_valid;
    logic [31:0] bnn_result;
    logic bnn_valid;
    logic bnn_ready_in;

    top_modul u_top_modul (
        .clk(clk),
        .rst_n(rst_n),
        .x(pixel_in),
        .x_valid(pixel_valid),
        .bnn_result(bnn_result), 
        .bnn_valid(bnn_valid),
        .ready_to_receive(bnn_ready_in)
    );


endmodule