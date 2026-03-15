`timescale 1ns / 1ps

module tb_arbiter();

    logic req_debug;
    logic req_fsm;
    logic gnt_debug;
    logic gnt_fsm;

    // Instantiate Device Under Test (DUT)
    arbiter dut (
        .req_debug(req_debug),
        .req_calc(req_fsm),
        .gnt_debug(gnt_debug),
        .gnt_calc(gnt_fsm)
    );

    initial begin
        $display("Time | Req_Debug | Req_FSM || Gnt_Debug | Gnt_FSM");
        
        $monitor("%4t |     %b     |    %b    ||     %b     |    %b", 
                 $time, req_debug, req_fsm, gnt_debug, gnt_fsm);

        // Scenario 1: Idle
        req_debug = 0; req_fsm = 0; #10;

        // Scenario 2: Only FSM requests
        req_debug = 0; req_fsm = 1; #10;

        // Scenario 3: Only Debug requests
        req_debug = 1; req_fsm = 0; #10;

        // Scenario 4: Collision (Both request) -> Debug should win
        req_debug = 1; req_fsm = 1; #10;

        // Scenario 5: Debug releases, FSM still waiting -> FSM should win
        req_debug = 0; req_fsm = 1; #10;

        $finish;
    end

endmodule