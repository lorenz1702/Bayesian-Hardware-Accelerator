class TopTx;
    rand logic signed [7:0] x_in;
    rand logic x_valid;
    rand logic ready_to_receive;

    constraint x_in_range {
        x_in >= -20;
        x_in <= 20;
    }


endclass

class ROM;


    logic signed [7:0] rom_mu;
    logic signed [7:0] rom_sigma;
    logic signed [7:0] rom_bias;


    function new(logic signed [7:0] init_mu, 
                 logic signed [7:0] init_sigma, 
                 logic signed [7:0] init_bias);
                 
        this.rom_mu    = init_mu;
        this.rom_sigma = init_sigma;
        this.rom_bias  = init_bias;
        
    endfunction

endclass


module CRV_top_modul;

    logic signed [7:0] rom_mu;
    logic signed [7:0] rom_sigma;
    logic signed [7:0] rom_bias;




    function int expected_y(

    input logic signed [7:0] x, 
        input logic signed [7:0] mu, 
        input logic signed [7:0] sigma, 
        input logic signed [9:0] epsilon, 
        input logic signed [7:0] bias
    );
        int calc_w;
        int result;
        
  
        calc_w = (int'(mu) <<< 7) + (sigma * epsilon);
        result = (calc_w * x) + (int'(bias) <<< 7);
        return result;
    endfunction

    function real to_fixed_point(input int raw_value, input int frac_bits);

        return $itor(raw_value) / (2.0 ** frac_bits);
    endfunction


    logic clk = 0;
    logic reset;
    logic [7:0] x_in;
    logic x_valid;
    logic x_ready;
    logic [31:0] bnn_result;
    logic bnn_valid;
    logic bnn_ready_in;

    top_modul u_top_modul (
        .clk(clk),
        .reset(reset),
        .x_in(x_in),
        .x_valid(x_valid),
        .x_ready(x_ready),
        .bnn_result(bnn_result), 
        .bnn_valid(bnn_valid),
        .ready_to_receive(bnn_ready_in)
    );

    localparam int Y_FRAC_BITS = 7;

    always #5 clk = ~clk;

    
    int expected_queue [$]; 
    
    always @(posedge clk) begin
        if (x_valid && x_ready) begin
           
            logic signed [9:0] spied_epsilon = u_top_modul.u_clt.clt_out;
            expected_queue.push_back(expected_y(x_in, rom_mu, rom_sigma, spied_epsilon, rom_bias));
        end
    end


    always @(negedge clk) begin
        if (bnn_valid && bnn_ready_in) begin
            
            
            if (expected_queue.size() > 0) begin
                
                
                int expected_val = expected_queue.pop_front();
                
                real hw_real = to_fixed_point(bnn_result, Y_FRAC_BITS);
                real sw_real = to_fixed_point(expected_val, Y_FRAC_BITS); 
                real x_real = to_fixed_point(x_in, 0);
                
                if (bnn_result !== expected_val) begin
                    $error("❌ MISMATCH: HW=%0d (%.3f) | SW=%0d (%.3f)", 
                           $signed(bnn_result), hw_real, $signed(expected_val), sw_real);
                end else begin
                    $display("✅ MATCH: Y = %0d (As fixed-Point: %.3f) X = %.3f", $signed(bnn_result), hw_real, $signed(x_in));
                end
                
            end else begin
                $error("❌ HW is valid_out, but SW Model is empty!");
            end
        end
    end

   
    always @(u_top_modul.u_fsm.current_state) begin
        case (u_top_modul.u_fsm.current_state)
            2'd0: $display("[%0t ns] FSM: ---> IDLE", $time);
            2'd1: $display("[%0t ns] FSM: ---> WAIT_FOR_CLT", $time);
            2'd2: $display("[%0t ns] FSM: ---> WAIT_FOR_ALU", $time);
        endcase
    end

    initial begin
        TopTx tx;
        ROM rom;
        tx = new();

        
        //rom = new(8'h04, 8'h03, -8'sd10);
        rom = new(8'h04, 8'h01, -8'sd10);
        rom_mu = rom.rom_mu;
        rom_sigma = rom.rom_sigma;
        rom_bias = rom.rom_bias;

        // Setup / Reset
        reset = 1;
        bnn_ready_in = 0; // Not ready at the beginning
        #20;
        reset = 0;
        @(posedge clk);


        $display("\n--------------------------------------------------");
        $display(" 🚀 STARTING TC-1.1: SINGLE TRANSACTION");
        $display("--------------------------------------------------");

        if (!tx.randomize()) $fatal("❌ Randomize failed!");

        
        x_in = tx.x_in;
        bnn_ready_in = 1'b1; 
        

        x_valid = 1'b1;


        wait(x_valid && x_ready);
        @(posedge clk);
        #1; 
 
        x_valid = 1'b0;

        
        wait(bnn_valid && bnn_ready_in);
        @(posedge clk);
        #1;

        $display("✅ TC-1.1 completed!");


        $display("\n--------------------------------------------------");
        $display(" 🚀 STARTING TC-1.2: Continuous Flow");
        $display("--------------------------------------------------");

        for (int i = 0; i < 100; i++) begin
            if (!tx.randomize()) $fatal("❌ Randomize failed!");

            
            x_in = tx.x_in;
            bnn_ready_in = 1'b1; 
            

            x_valid = 1'b1;

            wait(x_valid && x_ready);
            @(posedge clk);
            #1; 
 
            x_valid = 1'b0;

            
            wait(bnn_valid && bnn_ready_in);
            @(posedge clk);
            #1;
        end




        $display("\n--------------------------------------------------");
        $display(" 🚀 STARTING TC-2.1: Receiver Backpressure Test");
        $display("--------------------------------------------------");

        for (int i = 0; i < 5; i++) begin
            if (!tx.randomize()) $fatal("❌ Randomize failed!");

            
            x_in = tx.x_in;
            bnn_ready_in = 1'b1; 
            

            x_valid = 1'b1;

            wait(x_valid && x_ready);
            @(posedge clk);
            #1; 
 
            x_valid = 1'b0;

            
            wait(bnn_valid && bnn_ready_in);
            @(posedge clk);
            #1;

            
            bnn_ready_in = 1'b0; 
            $display("⏸️  Receiver is now NOT ready. Holding back the next transaction...");

            
            #30; 

            
            bnn_ready_in = 1'b1; 
            $display("▶️ Receiver is ready again. Resuming transactions...");
        end


        $display("\n--------------------------------------------------");
        $display(" 🚀 STARTING TC-2.2: SENDER STARVATION");
        $display("--------------------------------------------------");

        bnn_ready_in = 1'b1; 
        x_valid      = 1'b0;
        x_in         = 8'h00;

        for (int i = 0; i < 20; i++) begin
            @(posedge clk);
            #1; 

            if (u_top_modul.u_fsm.current_state !== 2'd0) begin
                $error("❌ TC-2.2 ERROR: FSM left IDLE state while x_valid is 0!");
            end

            if (bnn_valid !== 1'b0) begin
                $error("❌ TC-2.2 ERROR: bnn_valid is 1! Hardware is outputting ghost data.");
            end

            if (x_ready !== 1'b0) begin
                $error("❌ TC-2.2 ERROR: x_ready is 1 while no valid data is provided!");
            end
        end

        $display("✅ TC-2.2 completed!");

        $display("\n--------------------------------------------------");
        $display(" 🚀 STARTING TC-3.1: IN-FLIGHT RESET");
        $display("--------------------------------------------------");

        if (!tx.randomize()) $fatal("❌ Randomize failed!");
        x_in = tx.x_in;
        x_valid = 1'b1;
        bnn_ready_in = 1'b1;

        wait(x_valid && x_ready);
        @(posedge clk);
        #1;
        x_valid = 1'b0;

        @(posedge clk);
        #1;

        reset = 1'b1;
        
        expected_queue.delete();

        @(posedge clk);
        #1;

        if (bnn_valid !== 1'b0) begin
            $error("❌ TC-3.1 ERROR: bnn_valid did not drop to 0 after reset!");
        end
        if (u_top_modul.u_fsm.current_state !== 2'd0) begin
            $error("❌ TC-3.1 ERROR: FSM did not return to IDLE after reset!");
        end

        reset = 1'b0;
        @(posedge clk);
        #1;

        if (!tx.randomize()) $fatal("❌ Randomize failed!");
        x_in = tx.x_in;
        x_valid = 1'b1;

        wait(x_valid && x_ready);
        @(posedge clk);
        #1;
        x_valid = 1'b0;

        wait(bnn_valid && bnn_ready_in);
        @(posedge clk);
        #1;

        $display("✅ TC-3.1 completed!");

        $display("\n--------------------------------------------------");
        $display(" 🚀 STARTING TC-3.2: CLT DELAY TOLERANCE");
        $display("--------------------------------------------------");

        if (!tx.randomize()) $fatal("❌ Randomize failed!");
        x_in = tx.x_in;
        x_valid = 1'b1;
        bnn_ready_in = 1'b1;

        @(posedge clk);
        #1;

        force u_top_modul.u_fsm.clt_is_valid = 1'b0;

        for (int i = 0; i < 10; i++) begin
            @(posedge clk);
            #1;

            if (u_top_modul.u_fsm.current_state !== 2'd1) begin
                $error("❌ TC-3.2 ERROR: FSM is not in WAIT_FOR_CLT state!");
            end

            if (x_ready !== 1'b0) begin
                $error("❌ TC-3.2 ERROR: x_ready asserted while clt_is_valid is forced to 0!");
            end
        end

        release u_top_modul.u_fsm.clt_is_valid;

        wait(x_valid && x_ready);
        @(posedge clk);
        #1;
        x_valid = 1'b0;

        wait(bnn_valid && bnn_ready_in);
        @(posedge clk);
        #1;

        $display("✅ TC-3.2 completed!");


        #50;
        $finish;



    end

    initial begin

        #50000; 
        
        $fatal("\n=======================================================\n❌ GLOBAL WATCHDOG TIMEOUT).\n=======================================================\n");
    end


endmodule