//******************************************************************************************
// Design: cache_controller.v
// Author: Adam 
// Description: 
// v 0.1
//******************************************************************************************

module cache_controller # (
    parameter WIDTH=32
)
    (
    input             clk, rst,

    //input from cpu
    input [WIDTH-1:0]  address,
    input              read,
    input              write,
    input              flush,

    //input from main memory
    input              mem_ready,

    //output to cache data array
    output             refill,
    output             update,

    //output to main memory
    output             mem_read,
    output             mem_write,

    //output to data array
    output             read_data,

    //output to cpu
    output             stall
);


// parameters
//parameter BLOCK_SIZE  = 4;
parameter CACHE_LINES = 4;
//parameter WORD_SIZE   = 32;

//tag, index and offset bits;
localparam TAG_BITS    = 26;
localparam INDEX_BITS  = 2;
localparam OFFSET_BITS = 4;

// extract tag and index values from address
wire [TAG_BITS - 1 : 0]      tag = address[WIDTH - 1 : INDEX_BITS + OFFSET_BITS  ];
wire [INDEX_BITS - 1 : 0]  index = address[OFFSET_BITS + INDEX_BITS - 1: OFFSET_BITS];
//wire [OFFSET_BITS - 1 : 0]   offset     = address[OFFSET_BITS - 1 : 0];



// cache line defintion 
// | valid_bit | tag | for 4 cache line
reg                   valid_array [0 : CACHE_LINES - 1];
reg [TAG_BITS - 1: 0] tag_array   [0 : CACHE_LINES - 1];

reg hit;

integer i;

always @ (posedge clk or negedge rst) begin // @suppress "Behavior-specific 'always' should be used instead of general purpose 'always'"
    if (~rst || flush) begin
        for (i = 0; i < CACHE_LINES; i = i + 1) begin
            valid_array[i] <= 0;
            tag_array[i]   <= 0;
        end
        hit <= 0;
    end
    else begin
        if (valid_array[index] && (tag_array[index] == tag)) begin
            hit <= 1;
        end
        else
            hit <= 0;
            if (read || write) begin
                tag_array[index]   <= tag;
                valid_array[index] <= 1;
            end
    end

end

// FSM 
localparam IDLE       = 3'b000,
           READ_HIT   = 3'b001,
           READ_MISS  = 3'b010,
           REFILL     = 3'b011,
           WRITE_HIT  = 3'b100,
           WRITE_WAIT = 3'b101;

reg [2:0] state, next_state;
reg tmp_mem_read;
reg tmp_mem_write;
reg tmp_read_data;
reg tmp_refill;
reg tmp_stall;
reg tmp_update;


always @(*) begin // @suppress "Behavior-specific 'always' should be used instead of general purpose 'always'"
    next_state    = state;
    tmp_mem_read  = 0;
    tmp_mem_write = 0;
    tmp_read_data = 0;
    tmp_refill    = 0;
    tmp_stall     = 0;
    tmp_update    = 0;

    case (state)
        IDLE: begin
            if (read && hit)
                next_state = READ_HIT;
            else if (read && ~ hit)
                next_state = READ_MISS;
            else if (write && hit)
                next_state = WRITE_HIT;
            else if (write && ~ hit)
                next_state = WRITE_WAIT;
            //else
              //  next_state = IDLE;
        end

        READ_HIT: begin
            tmp_read_data  = 1;
            next_state = IDLE;
        end

        READ_MISS: begin
            tmp_stall    = 1;
            tmp_mem_read = 1;

            if (mem_ready)
                next_state = REFILL;
        end

        REFILL: begin
            tmp_stall      = 0;
            tmp_refill     = 1;
            next_state = IDLE; 
        end

        WRITE_HIT: begin
            tmp_update     = 1;
            tmp_mem_write  = 1;
            next_state = IDLE;
        end

        WRITE_WAIT: begin
            tmp_stall  = 1;     //stall the processor for n cycles for every write
            if (mem_ready) begin
               tmp_stall      = 0;
               next_state = IDLE;
            end
        end
        default: state = IDLE;
    endcase
end

assign refill    = tmp_refill;
assign stall     = tmp_stall;
assign mem_read  = tmp_mem_read;
assign mem_write = tmp_mem_write;
assign read_data = tmp_read_data;
assign update    = tmp_update;



always @(posedge clk or negedge rst) // @suppress "Behavior-specific 'always' should be used instead of general purpose 'always'"
    if (~rst) 
        state <= IDLE;
    else
        state <= next_state;

endmodule