//******************************************************************************************
// Design: testbench.sv
// Author: Adam 
// Description: 
// v 0.1
//******************************************************************************************


module testbench();

    logic               clk, rst;
    logic [32 - 1 : 0]  address;
    logic [32 - 1 : 0]  wdata;
    logic               read;
    logic               write;
    logic               flush;
    logic [32 - 1 : 0]  rdata;
    logic               stall;


    //intantiate top module
    top dut (.*);

    // clk
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk; 
        end
    end


    task reset_dut();
        rst     = 0;
        read    = 0;
        write   = 0;
        flush   = 0;
        address = 0;
        wdata   = 0;
        #50;
        rst = 1;
        #20;
    endtask


    //check for cache hit - should miss initially
    task test1();
        $display("-- Test1: Read Miss --");

        read    = 1;
        write   = 0;
        address = 32'h0000_0010;

        #10;
        read    = 0;
        assert (dut.cache_controller_instance.hit == 0 && dut.stall == 1 && dut.mem_read == 1) 
                          else $error("Test failed!");
        
                          
        #50;
    endtask

     //check for cache hit - expect hit
    task test2();
        $display("-- Test2: Read hit --");

        read    = 1;
        write   = 0;
        address = 32'h0000_0010;

        #10;
        read    = 0;
        assert (dut.cache_controller_instance.hit == 1 && dut.read_data == 1) 
                          else $error("Test failed!");

        #50;
    endtask


     //write miss
    task test3();
        $display("-- Test3: Write Miss --");

        read    = 0;
        write   = 1;
        address = 32'h0000_0020;

        #10;
        write    = 0;
        assert (dut.cache_controller_instance.hit == 0) 
                          else $error("Test failed!");

        #50;
    endtask


     //write hit
    task test4();
        $display("-- Test4: Write Hit --");

        read    = 0;
        write   = 1;
        address = 32'h0000_0020;

        #10;
        write    = 0;
        assert (dut.update == 1 && dut.mem_write == 1) 
                          else $error("Test failed!");

        #50;
    endtask


     //read after write - coherency

    int i;
    reg [31:0] base_addr = 32'h0000_0030;
    task test5();
        $display("-- Test5: Multiple Reads After Writes --");

       

        
        for (i = 0; i < 5; i++) begin
            // Write
            write   = 1;
            read    = 0;
            address = base_addr + (i << 2);  
            wdata   = 32'hDEADBEEF + i;
            #20;
            write = 0;
            #20;
    
            // Read
            read    = 1;
            write   = 0;
            address = base_addr + (i << 2);
            #20;
            $display("-- Read #%0d: Addr = 0x%08h, Data = 0x%08h --", i, address, rdata);
            read = 0;
            #20;
        end
    endtask


    // flush 
    task test6();

    endtask

    initial begin
        $display("--------------Start!-------------------");

        reset_dut();

        test1();

        test2();

        test3();

        test4();

        test5();

        test6();

        $display("--------------Finish!-------------------");
    end
endmodule