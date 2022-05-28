`timescale 1ns / 1ps



module slave#(parameter SIZE = 14, XLEN = 32)(

                                    clk,rst,fill_random,fill_values,


                                    ////AXI
                                    
                                    /////read address channel

                                    ARID,ARADDR,ARBURST,ARCACHE,
                                    ARLEN,ARREADY,ARSIZE,ARVALID,
                                    
                                    /////read data channel

                                    RDATA,RID,RLAST,RVALID,RRESP,
                                    RREADY,

                                    /////write address channel

                                    AWID,AWADDR,AWLEN,AWBURST,AWCACHE,
                                    AWVALID,AWREADY,AWSIZE,

                                    /////write data channel

                                    WID,WDATA,WLAST,WREADY,WVALID,WSTRB,

                                    ///write response channel
                                    
                                    BID,BRESP,BVALID,BREADY,
                                    
                                    read_request_handshake, write_request_handshake
                                    
                                    
);

///axi interface

/////read address channel 

input [1:0] ARID;//hv to check when we seperate for icache and dcache
input [XLEN-1:0] ARADDR;
input [3:0] ARLEN;  //no.of beats
input [2:0] ARSIZE; //4bytes
input [1:0] ARBURST; //burst_type //0->FIXED//1->INCR//2->WRAP
input ARCACHE;
input ARVALID;
output reg ARREADY;///check if ARREADY is output or inputt


/////read data channel

output reg [1:0] RID;
output reg [XLEN-1:0] RDATA;
output reg RRESP;
output reg RLAST;
output reg RVALID;
input RREADY;/// check RREADY


/////write address channel

input [1:0] AWID;
input [XLEN-1:0] AWADDR;
input [2:0] AWSIZE;
input [3:0] AWLEN;
input [1:0] AWBURST;
input AWCACHE;
input AWVALID;
output reg AWREADY;

/////write data channel

input [1:0] WID;
input [XLEN-1:0] WDATA;
input WSTRB;
input WLAST;
input WVALID;
output reg WREADY;

///write response channel

output reg [1:0] BID;
output reg BRESP;
output reg BVALID;
input BREADY;


//axi burst types
parameter FIXED = 2'b00;
parameter INCR = 2'b01;
parameter WRAP = 2'b10;


reg [XLEN-1:0]memory_array[(1<<SIZE)-1:0];


reg [XLEN-1:0] start_addr,last_addr;
reg [3:0] No_of_beats;  //no.of beats
reg [2:0] beat_size; //4bytes
reg [1:0] burst_type;
reg [1:0] id;

input rst, clk, fill_random,fill_values;
output reg read_request_handshake, write_request_handshake;

reg [SIZE+1:2] request_line;

integer i;
always@*
    begin
    request_line = start_addr[SIZE+1:2];
    end
always@(posedge clk)
begin
    if (rst)
    begin
        for (i = 0; i <= (1<<SIZE); i = i+1)
        begin
        memory_array[i] = 32'b0; 
        end
        
        ARREADY <= 1'b0;
        
        
        RLAST <= 1'b0;
        RVALID <= 1'b0;
        
        AWREADY <= 1'b0;
        
        WREADY <= 1'b0;
        

    end
    else if (fill_random)
    begin
        for (i = 0; i <= (1<<SIZE); i = i+1)
        begin
        memory_array[i] = $random; 
        end
    end
    else if(fill_values)
    begin
           memory_array[0] <= 32'h00A00593; // addi x11, zero, 10 --- 000000001010_00000_000_01011_0010011
	       memory_array[1] <= 32'h00B00613; // addi x12, zero, 11 -- 000000001011_00000_000_01100_0010011
	       memory_array[2] <=32'hC58833; // add x16, x11, x12  -- 0000000_01100_01011_000_10000_0110011
	       memory_array[3] <=32'b0000000_01011_00000_010_00001_0100011;
           memory_array[4] <=32'b0000000_01100_00000_010_00010_0100011;
	       memory_array[5] <=32'b000000000001_00000_000_00001_0000011;
	       memory_array[6] <=32'b000000000010_00000_100_00001_0000011;
         
    
    end
    
end


always@(posedge clk)
begin
    if (ARVALID)
    begin
    id <= ARID;
    burst_type <= ARBURST;
    start_addr <= ARADDR;
    No_of_beats <= ARLEN;
    beat_size <= ARSIZE;
    last_addr <= ARADDR + No_of_beats*beat_size;
    ARREADY <= 1'b1; 
    // if (burst_type = INCR)
    //     begin
    //         start_addr <= ARADDR;
    //         No_of_beats <= ARLEN;
    //         beat_size <= ARSIZE;
    //         ARREADY <= 1'b1; 
    //     end
    // if ()    
    end
    if (ARVALID &&ARREADY)
    begin
        read_request_handshake <= 1'b1;
        ARREADY <= 1'b0;
    end

    if (read_request_handshake)
    begin

        if (burst_type == INCR)
        begin
            
            if (!RVALID)
            begin
            RDATA <= memory_array[start_addr[SIZE+1:2]];
            RVALID <= 1'b1;
            RID <= id;
            
            end
            else if (RVALID&&!RREADY)
            begin
            RDATA <= memory_array[start_addr[SIZE+1:2]];
            end

            
	   
            
            if (RVALID&&RREADY&&!RLAST)
            begin
            start_addr = start_addr + beat_size;
            RDATA <= memory_array[start_addr[SIZE+1:2]];
            end
            
            if (RREADY&&RVALID&&RLAST)
            begin
            
            RDATA <= memory_array[start_addr[SIZE+1:2]];
            read_request_handshake <= 1'b0;
            RVALID <= 1'b0;
	        RLAST <= 1'b0;
		
            end
            
            if((start_addr == (last_addr))&&!RLAST)
                begin
                RLAST <= 1'b1; 
                end
            else 
                begin
                RLAST <= 1'b0;
                end

        end
        

    
    end
end









///////writing onto slave




always@(posedge clk)
begin
    if (AWVALID)
    begin
    id <= AWID; 
    burst_type <= AWBURST;
    start_addr <= AWADDR;
    No_of_beats <= AWLEN;
    beat_size <= AWSIZE;
    //last_addr <= start_addr + No_of_beats*beat_size;
    AWREADY <= 1'b1; 
    // if (burst_type = INCR)
    //     begin
    //         start_addr <= ARADDR;
    //         No_of_beats <= ARLEN;
    //         beat_size <= ARSIZE;
    //         ARREADY <= 1'b1; 
    //     end
    // if ()    
    end
    if (AWVALID &&AWREADY)
    begin
        write_request_handshake <= 1'b1;
        AWREADY <= 1'b0;

    end
    
    
end
always@(posedge clk)
begin
    if (write_request_handshake)
    begin
//        if (WVALID)
//        begin
//            if (burst_type == INCR)
//            begin
//                WREADY <= 1'b1;
              
                
//                if (WVALID&&WREADY&&!WLAST)
//                begin
//                    memory_array[start_addr[XLEN-1:2]] <= WDATA;
//                    start_addr <= start_addr + beat_size;
//                end
                
//                if (WVALID&&WREADY&&WLAST)
//                begin
//                    write_request_handshake <= 1'b0;
//		            WREADY <= 1'b0; 
//                end


//            end
            if (!WLAST)
                begin
                    if (WVALID)
                        begin
                        WREADY<=1'b1;
                        end
                    if (WVALID&&WREADY)
                        begin
                        memory_array [start_addr[SIZE+1:2]] <= WDATA;
                        start_addr <= {{start_addr[XLEN-1:2] + 1'b1},2'b00};
                        end  
                end
        
            if(WLAST&&WVALID)
                begin
                if (WREADY)  
                    begin
                    memory_array[start_addr[SIZE+1:2]] <= WDATA;
        //            cache_tags[cache_write_address[SIZE+1:L_SIZE+2]] <= cache_write_address[XLEN-1:SIZE+2];
        //            valid_array[cache_write_address[SIZE+1:L_SIZE+2]] <= 1'b1;
                    WREADY <= 1'b0;
                    write_request_handshake <=1'b0;
//                    write_transaction_complete <= 1'b1;
                
                    end
               
                end
    end

        
        

    
end
//end


endmodule
