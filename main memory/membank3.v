//******************************************************************************************
// Design: membank3.v
// Author: Adam 
// Description: 
// v 0.1
//******************************************************************************************


module membank3 (
    input          clk,
    input          rst,
    input   [27:0] addr,
    input          write_en,
    input   [31:0] wdata,
    output  [31:0] rdata
);

    localparam DEPTH = 256;
    reg [31:0] mem [0:DEPTH-1];
    integer i;
    // 
    initial begin
        
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = 32'h00000000;

        // Load sample values
        mem[0] = 32'h000000E0; 
        mem[1] = 32'h000000F0;
        mem[2] = 32'h000000F0;
        mem[3] = 32'h000000E0;
    end

    always @(posedge clk or negedge rst) begin 
        if (~rst)
            mem[addr] <= 0;
        else if (write_en)
            mem[addr] <= wdata;
    end

    assign rdata = mem[addr];
endmodule
