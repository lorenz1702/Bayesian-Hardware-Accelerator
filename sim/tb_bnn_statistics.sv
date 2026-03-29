`timescale 1ns / 1ps

module tb_bnn_statistics;

    logic clk = 0;
    logic reset;
    logic signed [7:0] x_in;
    logic x_valid;
    logic ready;
    logic signed [31:0] bnn_result;
    logic bnn_valid;
    logic ready_to_receive;

    localparam int Y_FRAC_BITS = 7;

    top_modul u_top_modul (
        .clk(clk),
        .reset(reset),
        .x_in(x_in),
        .x_valid(x_valid),
        .ready(ready),
        .bnn_result(bnn_result),
        .bnn_valid(bnn_valid),
        .ready_to_receive(ready_to_receive)
    );

    always #5 clk = ~clk;

    function real to_fixed_point(input int raw_value, input int frac_bits);
        return $itor(raw_value) / (2.0 ** frac_bits);
    endfunction

    initial begin
        //int test_x_values[] = '{8'sd50, 8'sd0, -8'sd50};
        
        int test_x_values[] = '{50,20,15,10,5, 0, -5, -10,-15,-20, -50};


        int num_samples = 1000;
        
        real sum_y;
        real sum_sq_y;
        real current_y;
        real emp_mean;
        real emp_var;

        reset = 1'b1;
        x_valid = 1'b0;
        x_in = 8'sd0;
        ready_to_receive = 1'b0;
        
        #20;
        reset = 1'b0;
        ready_to_receive = 1'b1;
        @(posedge clk);

        $display("\n--------------------------------------------------");
        $display(" 🚀 STARTING STATISTICAL BNN VERIFICATION");
        $display("--------------------------------------------------");

        foreach (test_x_values[i]) begin
            $display("\n---> Collecting %0d samples for X = %0d", num_samples, $signed(test_x_values[i]));
            
            sum_y = 0.0;
            sum_sq_y = 0.0;
            
            for (int s = 0; s < num_samples; s++) begin
                x_in = test_x_values[i];
                x_valid = 1'b1;
                
                wait(x_valid && ready);
                @(posedge clk);
                #1;
                x_valid = 1'b0;
                
                wait(bnn_valid && ready_to_receive);
                current_y = to_fixed_point(bnn_result, Y_FRAC_BITS);
                
                sum_y = sum_y + current_y;
                sum_sq_y = sum_sq_y + (current_y * current_y);
                
                @(posedge clk);
                #1;
            end
            
            emp_mean = sum_y / num_samples;
            emp_var = (sum_sq_y / num_samples) - (emp_mean * emp_mean);
            
            $display("   [Results for X = %0d]", $signed(test_x_values[i]));
            $display("   Mean     = %f", emp_mean);
            $display("   Variance = %f", emp_var);
        end

        $display("\n✅ Statistical Verification completed!");
        #50;
        $finish;
    end

endmodule