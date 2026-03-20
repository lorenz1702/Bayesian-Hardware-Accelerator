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

    initial begin
        for (int i = 0; i < (2**ADDR_WIDTH); i++) begin
            ram[i] = {DATA_WIDTH{1'b0}}; 
        end
    end

    always @(negedge clk) begin
        if (we) ram[wr_addr] = wr_data;
        
        if (!we) begin
            if (rd_data !== ram[rd_addr]) 
                $error("❌ MISMATCH (Addr %0d): expected %0d, Hardware says %0d", 
                       rd_addr, ram[rd_addr], rd_data);
        end
    end

    initial begin
        RamTransaction tr;
        tr = new();

        $display("Start Constrained Random Test...");

        for (int i = 0; i < 20; i++) begin
            if (!tr.randomize()) begin
                $fatal("Randomization failed!");
            end

            we      = tr.we;
            wr_addr = tr.wr_addr;
            wr_data = tr.wr_data;
            rd_addr = tr.rd_addr;
            
            @(posedge clk);
            #1; 

            if (we)
                $display("Takt %0d: Write data %3d to addr %0d", i, wr_data, wr_addr);
            else
                $display("Takt %0d: Read data %3d at addr %0d", i, rd_data, rd_addr);    
        end

        $display("Test end");
        $finish; 
    end

endmodule