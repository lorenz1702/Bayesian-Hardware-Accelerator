class RamTransaction #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4
);
    rand logic we;
    rand logic [ADDR_WIDTH-1:0] wr_addr;
    rand logic [DATA_WIDTH-1:0] wr_data;
    rand logic [ADDR_WIDTH-1:0] rd_addr;

    constraint c_we_dist {
        we dist {1'b1 := 30, 1'b0 := 70};
    }

    constraint c_data_range {
        wr_data inside { [10:100] };
    }
endclass


module tb_ram_crv;
    logic clk = 0;
    logic we;
    logic [3:0]  wr_addr;
    logic [31:0] wr_data; 
    logic [3:0]  rd_addr;
    logic [31:0] rd_data; 

    dual_port_ram u_ram(.*);

    always #5 clk = ~clk;

    localparam DATA_WIDTH = 32; 
    localparam ADDR_WIDTH = 4;  

    logic [DATA_WIDTH-1:0] ram [0:(2**ADDR_WIDTH)-1];

    // --- HELPER TASK TO RESET MEMORIES ---
    task reset_memories();
        $display("\n---> RESETTING MEMORIES (Golden Model & Hardware) <---");
        for (int i = 0; i < (2**ADDR_WIDTH); i++) begin
            ram[i]       = {DATA_WIDTH{1'bx}}; // Reset Golden Model
            u_ram.mem[i] = {DATA_WIDTH{1'bx}}; // Overwrite hardware RAM directly (White-Box)
        end
        @(negedge clk); // Synchronize to clock
    endtask


    initial begin
        RamTransaction tr;
        tr = new();

        // ====================================================================
        // TEST 1: Random reading and writing
        // ====================================================================
        reset_memories(); // <--- Reset before the test
        $display("--- Start Constrained Random Test : Random reading and writing ---");

        for (int i = 0; i < 20; i++) begin
            if (!tr.randomize()) $fatal("Randomization failed!");

            @(negedge clk);
            we      = tr.we;
            wr_addr = tr.wr_addr;
            wr_data = tr.wr_data;
            rd_addr = tr.rd_addr;
            
            @(posedge clk);
            #1; 

            if (we) begin
                ram[wr_addr] = wr_data;
                $display("Cycle %0d [WRITE]: Write data %3d to addr %0d", i, wr_data, wr_addr);
            end else begin
                $display("Cycle %0d [READ] : Read data %3b at addr %0d", i, rd_data, rd_addr);    
                if (rd_data !== ram[rd_addr]) begin
                    $error("❌ MISMATCH (Addr %0d): expected %b, Hardware says %b", 
                           rd_addr, ram[rd_addr], rd_data);
                end
            end
        end

        // ====================================================================
        // TEST 2: Basic Write & Read (Same Addr)
        // ====================================================================
        reset_memories(); // <--- Reset before the test
        $display("\n--- Start Constrained Random Test : Basic Write & Read (Same Addr) ---");

        for (int i = 0; i < 20; i++) begin
            if (!tr.randomize()) $fatal("Randomization failed!");

            // 1st Cycle: Write
            @(negedge clk);
            we      = 1'b1;
            wr_addr = tr.wr_addr;
            wr_data = tr.wr_data;
            
            @(posedge clk);
            #1;
            ram[wr_addr] = wr_data; 
            $display("Cycle %0d [WRITE]: Write data %3d to addr %0d", i, wr_data, wr_addr);

            // 2nd Cycle: Read
            @(negedge clk);
            we      = 1'b0; 
            rd_addr = wr_addr;
            
            @(posedge clk);
            #1;
            $display("Cycle %0d [READ] : Read data %3d at addr %0d", i, rd_data, rd_addr);  
            if (rd_data !== ram[rd_addr]) begin
                $error("❌ MISMATCH (Addr %0d): expected %0d, Hardware says %0d", 
                       rd_addr, ram[rd_addr], rd_data);
            end
        end

        // ====================================================================
        // TEST 3: Basic Write Back to Back + Full Memory Check
        // ====================================================================
        reset_memories(); // <--- Reset before the test
        $display("\n--- Start Constrained Random Test : Basic Write Back to Back ---");

        // Phase A: Continuous writing
        for (int i = 0; i < 20; i++) begin
            if (!tr.randomize()) $fatal("Randomization failed!");

            @(negedge clk);
            we      = 1'b1;
            wr_addr = tr.wr_addr;
            wr_data = tr.wr_data;

            @(posedge clk);
            #1;
            ram[wr_addr] = wr_data; 
            $display("Cycle %0d [WRITE]: Write data %3d to addr %0d", i, wr_data, wr_addr);
        end

        // Phase B: Read out and verify the entire memory
        $display("\n---> VERIFYING FULL MEMORY CONTENTS <---");
        for (int i = 0; i < (2**ADDR_WIDTH); i++) begin
            @(negedge clk);
            we      = 1'b0;
            rd_addr = i; // Systematically iterate over addresses 0 to 15

            @(posedge clk);
            #1;
            
            // Compare hardware with Golden Model
            if (rd_data !== ram[i]) begin
                $error("❌ MISMATCH (Addr %0d): expected %0d, Hardware says %0d", 
                       i, ram[i], rd_data);
            end else begin
                $display("✅ MATCH (Addr %0d): Data = %0d", i, rd_data);
            end
        end

        // ====================================================================
        // TEST 4: Basic Read Back to Back 
        // ====================================================================

        $display("\nTest end");
        $finish; 
    end

endmodule