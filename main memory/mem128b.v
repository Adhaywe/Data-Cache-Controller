//******************************************************************************************
// Design: mem128b.v
// Author: Adam 
// Description: 
// v 0.1
//******************************************************************************************


module mem128b (
    input           clk, rst, clr,

    // Control Signals
    input               mem_read,
    input               mem_write,
    input  [31:0]       addr,
    input  [31:0]       wdata,
    output  [127:0]     block_rdata,
    //output  reg [31:0]  rdata,
    output              ready
);

// Extract bank offset and block address

wire [1:0] word_offset = addr[3:2];
wire [27:0] block_addr = addr[31:4];

// Internal signals
wire [3:0] write_enable_bank = (mem_write) ? (4'b0001 << word_offset) : 4'b0000;

// Per-bank read data
wire [31:0] bank_rdata [3:0];

// Banks
membank0 bank0 (
        .clk(clk), .rst(rst),
        .addr(block_addr),
        .write_en(write_enable_bank[0]),
        .wdata(wdata),
        .rdata(bank_rdata[0])
);

membank1 bank1 (
        .clk(clk), .rst(rst),
        .addr(block_addr),
        .write_en(write_enable_bank[1]),
        .wdata(wdata),
        .rdata(bank_rdata[1])
    );

membank2 bank2 (
        .clk(clk), .rst(rst),
        .addr(block_addr),
        .write_en(write_enable_bank[2]),
        .wdata(wdata),
        .rdata(bank_rdata[2])
    );

membank3 bank3 (
        .clk(clk), .rst(rst),
        .addr(block_addr),
        .write_en(write_enable_bank[3]),
        .wdata(wdata),
        .rdata(bank_rdata[3])
    );

// Combine the block read data
assign block_rdata = { bank_rdata[3], bank_rdata[2], bank_rdata[1], bank_rdata[0] };


    // Simple ready signalfixed latency of 3 cycles)
localparam   LAT = 3;
reg    [1:0] count;
reg          r_ready;

always @(posedge clk or negedge rst) begin
        if (~rst || clr) begin
            count <= 0;
            r_ready <= 1'b1;
        end else if (mem_read || mem_write) begin
            if (count < LAT - 1) begin
                count <= count + 1;
                r_ready <= 1'b0;
            end else begin
                count <= 0;
                r_ready <= 1'b1;
            end
        end else begin
            count <= 0;
            r_ready <= 1'b1;
        end
    end

assign ready = r_ready;

endmodule
