//******************************************************************************************
// Design: data_array.v
// Author: Adam 
// Description: 
// v 0.1
//******************************************************************************************


module data_array # (
       parameter WIDTH=32,
       parameter DATA_WIDTH_MEM=128
)
    (
      input                         clk, rst, clr,

      //from cpu
      input [WIDTH - 1: 0]          address,
      input [WIDTH - 1: 0]          wdata,

      //input from controller
      input                         refill,
      input                         update,
      input                         read_data,


      //input from main memory
      input [DATA_WIDTH_MEM - 1: 0] data_mem,

      //output to cpu
      output [WIDTH - 1 : 0]        rdata
);


// parameters
parameter BLOCK_SIZE  = 4;
parameter CACHE_LINES = 4;
parameter WORD_SIZE   = 32;

//tag, index and offset bits;
localparam INDEX_BITS  = 2;
localparam OFFSET_BITS = 4;

//extract index and offset bits from address
wire [INDEX_BITS - 1 : 0]          index = address[OFFSET_BITS + INDEX_BITS - 1: OFFSET_BITS];
wire [OFFSET_BITS - 1 : 0]   offset      = address[OFFSET_BITS - 1 : 0];

//define data arrays
reg [WORD_SIZE*BLOCK_SIZE - 1 : 0] data_array [0 : CACHE_LINES - 1];

//temp var
reg [31:0] r_read_data;

integer i;

always @(posedge clk or negedge rst) begin 
    if (~rst || clr) begin
        for (i = 0; i < CACHE_LINES; i = i + 1) begin
            data_array[i] <= 0;
        end
    end
    else if (read_data) begin // read from the data array
        r_read_data <= data_array[index][(offset >> 2) * WORD_SIZE +: WORD_SIZE];
    end
    else if (refill) begin   // copy data from memory
        data_array[index][(offset >> 2) * WORD_SIZE +: WORD_SIZE] <= data_mem;
    end
    else if (update) begin  // copy data from cpu
        data_array[index][(offset >> 2) * WORD_SIZE +: WORD_SIZE] <= wdata;
    end
end

assign rdata = r_read_data;

endmodule