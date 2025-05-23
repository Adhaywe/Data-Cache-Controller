//******************************************************************************************
// Design: top.v
// Author: Adam 
// Description: 
// v 0.1
//******************************************************************************************



module top # (
    parameter WIDTH=32
)
    (
    input                  clk, rst,
    input [WIDTH - 1 : 0]  address,
    input [WIDTH - 1 : 0]  wdata,
    input                  read,
    input                  write,
    input                  flush,

    output [WIDTH - 1 : 0] rdata,
    output                 stall
);


wire          refill;
wire          update;
wire          mem_read;
wire          mem_ready;
wire          mem_write;
wire          read_data;
wire [127:0]  data_mem;


cache_controller #(
    .WIDTH( 32)
) cache_controller_instance (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .address(address),
    .read(read),
    .write(write),
    .mem_ready(mem_ready),
    .refill(refill),
    .update(update),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .read_data(read_data),
    .stall(stall)
);


data_array #(
    .WIDTH(32),
    .DATA_WIDTH_MEM(128)
) data_array_instance (
    .clk(clk),
    .rst(rst),
    .clr(flush),
    .address(address),
    .wdata(wdata),
    .refill(refill),
    .update(update),
    .read_data(read_data),
    .data_mem(data_mem),
    .rdata(rdata)
);

mem128b mem128b_instance (
    .clk(clk),
    .rst(rst),
    .clr(flush),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .addr(address),
    .wdata(wdata),
    .block_rdata(data_mem),
    .ready(mem_ready)
);

endmodule