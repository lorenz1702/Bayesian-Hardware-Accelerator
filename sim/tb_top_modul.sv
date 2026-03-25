`timescale 1ns / 1ps

module tb_top_modul;

    // --- 1. Signale deklarieren ---
    reg clk;
    reg reset;
    
    // Inputs ins Top-Modul
    logic [7:0]  pixel_in;
    logic        pixel_valid;
    logic        bnn_ready_in;
    
    // Outputs aus dem Top-Modul
    logic [31:0] bnn_result;
    logic        bnn_valid;

    // --- 2. Das DUT (Device Under Test) instanziieren ---
    top_modul dut (
        .clk(clk),
        .reset(reset),
        .x_in(pixel_in),
        .x_valid(pixel_valid),
        .bnn_result(bnn_result),
        .bnn_valid(bnn_valid), //,
        .ready_to_receive(bnn_ready_in)
    );

    // --- 3. Den Takt (100 MHz) erzeugen ---
    always #5 clk = ~clk;

    // --- 4. FSM-Spion (Grey-Box Verification) ---
    // Dieser Block triggert automatisch, wenn die FSM im Inneren den Zustand wechselt!
    always @(dut.u_fsm.current_state) begin
        case (dut.u_fsm.current_state)
            2'd0: $display("[%0t ns] FSM: ---> IDLE (Warte auf Daten)", $time);
            2'd1: $display("[%0t ns] FSM: ---> CALC (Berechne Rauschen & ALU)", $time);
            2'd2: $display("[%0t ns] FSM: ---> DONE (Ergebnis fertig!)", $time);
        endcase
    end





    // --- 5. Der Testablauf (Stimulus) ---
    initial begin
        // Startwerte setzen
        clk = 0;
        reset = 1;
        pixel_in = 8'd0;
        pixel_valid = 0;
        bnn_ready_in = 0; // Außenwelt ist noch NICHT bereit

        $display("==================================================");
        $display("   STARTE TOP-MODUL SYSTEM-TEST");
        $display("==================================================");

        // Reset loslassen
        #20;
        reset = 0;
        @(posedge clk);
        
        // Außenwelt meldet: "Ich bin bereit, Ergebnisse zu empfangen!"
        bnn_ready_in = 1;

        // ---------------------------------------------------------
        // TEST 1: Ein einzelnes Pixel durch die Pipeline schicken
        // ---------------------------------------------------------
        $display("\n--- TEST 1: Sende Pixel '50' ---");
        
        pixel_in = 8'd50;
        pixel_valid = 1; // "Push" in den FIFO
        @(posedge clk);
        pixel_valid = 0; 
        

        wait(bnn_valid == 1'b1);
        @(posedge clk); // Einen Takt warten, damit das Ergebnis stabil anliegt
        
        $display("[%0t ns] ERGEBNIS 1: Y = %0d", $time, $signed(bnn_result));

        #50; // Kurz durchatmen

        // ---------------------------------------------------------
        // TEST 2: Stress-Test! Drei Pixel direkt hintereinander
        // ---------------------------------------------------------
        $display("\n--- TEST 2: Sende 3 Pixel schnell hintereinander ---");
        
        // Wir pushen 3 Werte (10, 20, -30) in den FIFO
        pixel_valid = 1;
        pixel_in = 8'd10;          @(posedge clk);
        pixel_in = 8'd20;          @(posedge clk);
        pixel_in = -8'd30;         @(posedge clk);
        @(posedge clk);  // <--- DIESE ZEILE HINZUFÜGEN!
        pixel_valid = 0;

        // Eine For-Schleife, um die 3 Ergebnisse abzufangen
        for (int i = 1; i <= 3; i++) begin
            wait(bnn_valid == 1'b1);
            @(posedge clk);
            $display("[%0t ns] ERGEBNIS %0d: Y = %0d", $time, i+1, $signed(bnn_result));
            
            // Kurz warten, damit das DONE-Signal der FSM wieder auf IDLE abfallen kann
            // (Wir warten, bis bnn_valid wieder 0 ist, bevor wir auf das nächste warten)
            wait(bnn_valid == 1'b0); 
        end

        #50;
        $display("==================================================");
        $display("   TEST BEENDET");
        $display("==================================================");
        $finish;



        
    end

        // --- WATCHDOG TIMER ---
    // Dieser Block läuft parallel. Wenn die Simulation zu lange dauert,
    // zieht er die Notbremse, speichert die Waveform und beendet hart!
    initial begin
        #50000; // Wenn nach 50.000 ns (50 Mikrosekunden) nichts passiert ist...
        $display("==================================================");
        $display(" WATCHDOG ALARM: Simulation hing fest und wurde abgebrochen!");
        $display("==================================================");
        $finish;
    end

endmodule