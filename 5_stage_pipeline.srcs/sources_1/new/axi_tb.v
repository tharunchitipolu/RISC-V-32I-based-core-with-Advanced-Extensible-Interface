`timescale 1ns / 1ps

//`include "cache.v"
module axi_tb#(parameter XLEN = 32)();

// parameters
parameter L_SIZE = 4;
parameter LINES = 8;
parameter SIZE = LINES+L_SIZE;


//axi burst types
parameter FIXED = 2'b00;
parameter INCR = 2'b01;
parameter WRAP = 2'b10;


reg ARID;//hv to check when and how to seperate for icache and dcache
reg [XLEN-1:0] ARADDR;
reg [3:0] ARLEN;  //no.of beats
reg [2:0] ARSIZE; //4bytes
reg [1:0] ARBURST; //burst_type //0->FIXED//1->INCR//2->WRAP
reg ARCACHE;
reg ARVALID;
wire ARREADY;///check if ARREADY is reg or output


/////read data channel

wire RID;
wire [XLEN-1:0]RDATA;
wire RRESP;
wire RLAST;
wire RVALID;
reg RREADY;/// check RREADY


/////write address channel

reg AWID;
reg [XLEN-1:0] AWADDR;
reg [3:0] AWLEN;
reg [2:0] AWSIZE;
reg [1:0] AWBURST;
reg AWCACHE;
reg AWVALID;
wire AWREADY;

/////write data channel

reg WID;
reg [XLEN-1:0] WDATA;
reg WSTRB;
reg WLAST;
reg WVALID;
wire WREADY;

///write response channel

wire BID;
wire BRESP;
wire BVALID;
reg BREADY;


reg [XLEN-1:0] i_addr, i_data;
reg rst, read, write, clk, fill_random;
reg [XLEN-1:0] o_data;


reg read_request_handshake_master, read_transaction_pending_master;
reg read_transaction_complete_master;

reg write_request_handshake_master, write_transaction_pending_master;
reg write_transaction_complete_master;

reg write_scycle, need_writethrough, write_dcycle, write_valid;
reg [XLEN-1:0] write_data, write_addr;

reg [XLEN-1:0] cache_write_address, axi_read_address, axi_write_address;


reg [LINES-1:0] request_line,line ;
reg [L_SIZE-1:0] request_within_line, within_line ;

reg [XLEN-(SIZE+2)-1:0] tag_value;
reg valid_value, read_pending, write_pending;
reg stall,read_valid, needload;
reg [XLEN-1:0] data_value,r_addr ;
reg line_dirty;




reg [XLEN-1:0] start_addr,last_addr;
reg [3:0] No_of_beats;  //no.of beats
reg [2:0] beat_size; //4bytes
reg [1:0] burst_type;



//reg [31:0] register [15:0]; 

/// memory arrays
reg [XLEN-1:0] cache [(1<<SIZE)-1:0];
reg [XLEN-(SIZE+2)-1:0] cache_tags [(1<<LINES)-1:0] ;
reg valid_array [(1<<LINES)-1:0];
reg dirty_array [(1<<LINES)-1:0];

reg [XLEN-1:L_SIZE+2] tag_line,r_tag_line;


slave slave_1(
                                    
                                    .rst(rst), .clk(clk),.fill_random(fill_random),
                                    
                                    
                                    ////AXI 
                                    
                                    /////read address channel

                                    .ARID(ARID),.ARADDR(ARADDR),.ARBURST(ARBURST),.ARCACHE(ARCACHE),
                                    .ARLEN(ARLEN),.ARREADY(ARREADY),.ARSIZE(ARSIZE),.ARVALID(ARVALID),
                                    
                                    /////read data channel

                                    .RDATA(RDATA),.RID(RID),.RLAST(RLAST),.RVALID(RVALID),.RRESP(RRESP),
                                    .RREADY(RREADY),

                                    /////write address channel

                                    .AWID(AWID),.AWADDR(AWADDR),.AWLEN(AWLEN),.AWBURST(AWBURST),.AWCACHE(AWCACHE),
                                    .AWVALID(AWVALID),.AWREADY(AWREADY),.AWSIZE(AWSIZE),

                                    /////write data channel

                                    .WID(WID),.WDATA(WDATA),.WLAST(WLAST),.WREADY(WREADY),.WVALID(WVALID),.WSTRB(WSTRB),

                                    ///write response channel
                                    
                                    .BID(BID),.BRESP(BRESP),.BVALID(BVALID),.BREADY(BREADY)
);

//integer i;

initial 
    begin
//    #800
        clk <= 1'b1;
        rst <= 1'b1;
//        WVALID <= 1'b0;
//        WLAST <= 1'b0;
        
        
        
        
        
        #101
        rst <= 1'b0;
        fill_random <= 1'b1;
        
//        for (i = 0; i < 16; i = i+1)
//        begin
//        register[i] = $random; 
//        end
        
//        #100
//        fill_random <= 1'b0;
//        read <= 1'b1;
//        write <= 1'b0;
//        i_addr <= 32'h12000000;
        
//        #100
        
//        read <= 1'b1;
//        write <= 1'b0;
//        i_addr <= 32'h12000040;

          #100 
          fill_random <= 1'b0;
          count <= 1'b0;
          
          
  
        
//        axi_read_address <= 32'h10000000;
//        read_transaction_pending <= 1'b1;
//        read_request_handshake_master <= 1'b0;
//        write_request_handshake_master <= 1'b0;
        
        
//        axi_write_address <= 32'h10000000;
//        write_transaction_pending <= 1'b1;
//        write_request_handshake_master <= 1'b0;
       
        
//        ARVALID <= 1'b1;
//        ARADDR <= 32'h10000000;
//        reg_write_address <= 32'b0; 
//        ARSIZE <= 3'b100;
//        ARLEN <= 3'b111;
//        ARBURST <= 2'b01;
    
        
   
                
        
       

    end
reg [3:0] count;
always@(posedge clk)
          begin
          if((!stall)&&!(fill_random))
            begin
            count <= count+1;
            end
            
            
end
always@(*)
begin
          case(count)

            
            4'b0000 : begin
                        read = 1'b1;
                        write = 1'b0;
                        i_addr = 32'h12000000; 
                        i_data = 32'bz;
                      end
            4'b0001 : begin
                        read = 1'b1;
                        write = 1'b0;
                        i_addr = 32'h12000040; 
                        i_data = 32'bz;
                      end
            4'b0010 : begin
            //write_dcycle case
                        read = 1'b0;
                        write = 1'b1;
                        i_addr = 32'h12000004; 
                        i_data = 32'h12345678;                        
            
                      end
            4'b0011 : begin
            //write_scycle case
                        read = 1'b0;
                        write = 1'b1;
                        i_addr = 32'h12000008;
                        i_data = 32'h87654321; 
                      end
            4'b0100 : begin
            //read after immediate write
                        read = 1'b1;
                        write = 1'b0;
                        i_addr = 32'h12000008; 
                        i_data = 32'bz;
                        
                      end 
            4'b0101 : begin
            //read with write_through
                        read = 1'b1;
                        write = 1'b0;
                        i_addr = 32'h12004004; 
                        i_data = 32'bz;
                        
                      end   
            4'b0110 : begin
            //
                        read = 1'b1;
                        write = 1'b0;
                        i_addr = 32'h12004008; 
                        i_data = 32'bz;
                        
                      end 
            4'b0111 : begin
            //write_scycle case
                        read = 1'b0;
                        write = 1'b1;
                        i_addr = 32'h12004008;
                        i_data = 32'h12345678;
                        
                      end
            4'b1000 : begin
            //write with write_through
                        read = 1'b0;
                        write = 1'b1;
                        i_addr = 32'h12000008;
                        i_data = 32'h12345678;
                        
                      end
            4'b1001 : begin
//            write with needload
                        read = 1'b0;
                        write = 1'b1;
                        i_addr = 32'h12000208;
                        i_data = 32'h23456789;
                        
                      end                     
                                           
                             
                                        
            default : begin
            
                        read = 1'bz;
                        write = 1'bz;
                        i_addr = 32'hz;
                        i_data = 32'hz;
                        
                      end     
            endcase
            
          end  
          
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////


always@(*)
begin

    request_line = i_addr[SIZE+1:L_SIZE+2];
    request_within_line = i_addr[L_SIZE+1:2];

end


always@*
    begin
    #50 clk <= !clk;
    
//    if (RLAST == 1'b1)
//        begin
//        RVALID <= 1'b0;
//        end
        
    end
//always@(posedge clk)
//    begin
//    if (RVALID == 1'b1)
//        begin
//        RDATA <= RDATA + 1;
//        end
//    end 
always@(*)
begin

    request_line = i_addr[SIZE+1:L_SIZE+2];
    request_within_line = i_addr[L_SIZE+1:2];

end



integer i,j,k;
always@(posedge clk)
begin
    if (rst)
    begin

        for (i = 0;i<={1<<SIZE};i = i + 1)
        begin
        cache[i] = 32'b0;
        end    
        for (j = 0;j<={1<<LINES};j= j + 1)
        begin
        cache_tags[j] = 0;
        valid_array[j] = 0;
	    dirty_array[j] = 0;
        end

	stall = 1'b0;

	read_transaction_complete_master = 1'b0;
	read_request_handshake_master = 1'b0;
	read_transaction_pending_master = 1'b0;
	
    write_transaction_complete_master = 1'b0;
	write_request_handshake_master = 1'b0;
	write_transaction_pending_master = 1'b0;
	
	
	ARVALID <= 1'b0;
	
	RREADY <= 1'b0;
	
	AWVALID<= 1'b0;
	
	WVALID <= 1'b0;
    WLAST <= 1'b0;

    end
    else 
    begin
            
        if (!stall)
        begin
            if (read)
            begin
            
            
//                read_pending <= read;
//                tag_value <= cache_tags[line];
//                valid_value <= valid_array[line];
//                line_dirty <= dirty_array[line];
//                data_value <= cache[i_addr];
//                r_addr <= i_addr;
            

            if (write_pending&&write_dcycle&&(r_addr == i_addr))
                begin
                data_value <= write_data;
                read_valid <= 1'b1;
                read_pending <= 1'b0;
                
                
                
                end
            else  
                begin
                write_scycle <= 1'b0; 
                read_pending <= 1'b1;
                write_pending <= 1'b0;
                tag_value <= cache_tags[request_line];
                valid_value <= valid_array[request_line];
                line_dirty <= dirty_array[request_line];
                data_value <= cache[i_addr[SIZE+1:2]];
                line <= request_line;
                within_line <= request_within_line;
                r_addr <= i_addr;
                
                end
            end
            else if (write)
            begin
                    
                r_tag_line = {tag_value, line};
                tag_line = i_addr[XLEN-1:L_SIZE+2];
                
                if ((r_tag_line == tag_line)&&valid_value)
                    begin
                    write_scycle <= 1'b1;
                    stall <= 1'b0;
                    cache[i_addr[SIZE+1:2]] <= i_data;
                    dirty_array[request_line] <= 1'b1;
                    write_valid <= 1'b1;
                    read_pending <= 1'b0;
                    write_pending <= 1'b0;
                    line <= request_line;
                    within_line <= request_within_line;
                    
                    end
                else
                    begin
                    write_scycle <= 1'b0;
                    write_pending <= 1'b1;
                    read_pending <=1'b0;
                    tag_value <= cache_tags[request_line];
                    valid_value <= valid_array[request_line];
                    data_value <= cache[i_addr[SIZE+1:2]];
                    r_addr <= i_addr;
                    line_dirty <= dirty_array[request_line];
                    write_data <= i_data;
                    write_addr <= i_addr;
                    line <= request_line ;

                    end
                    
//                 if (write_scycle)
//                    begin
//                    write_scycle <= 1'b0;
//                    end

                end

        end
        else if(stall)
        begin
            if (read_pending||write_pending)
            begin
                    
                    tag_value <= cache_tags[r_addr[SIZE+1:L_SIZE+2]];
                    valid_value <= valid_array[r_addr[SIZE+1:L_SIZE+2]];
                    line_dirty <= dirty_array[r_addr[SIZE+1:L_SIZE+2]];
                    data_value <= cache[r_addr[SIZE+1:2]];	
    
            end
            
            
        end
    end
        
end

































////////////////////////////////////////////////////////////////////////
//////////////////////////// read transaction //////////////////////////
////////////////////////////////////////////////////////////////////////


always@(*)
begin
if(read_pending)
    begin
        if (tag_value == r_addr[XLEN-1:SIZE+2]&&valid_value)
            begin
                read_valid = 1'b1;
                stall = 1'b0;
            end
        else if (line_dirty&&valid_value)
            begin
                need_writethrough = 1'b1;
                read_valid = 1'b0; 

            end
        else if  (!line_dirty)
            begin
                need_writethrough = 1'b0;
                needload = 1'b1;
                read_valid = 1'b0;
            end
    end
end



always@*
begin
    if (read_pending&&read_valid)
        begin
            o_data = data_value;  


            ///
            read_transaction_pending_master  = 1'b0;
            read_transaction_complete_master = 1'b0;
            write_transaction_pending_master = 1'b0;
            write_transaction_complete_master = 1'b0;
            
            //

        end
    else if ((read_pending&&!read_valid))
        begin
            //cache miss
            //stall the stage
            stall = 1'b1;
            

            //go to axi interface
            if (need_writethrough)
                begin
                    if (!write_transaction_complete_master )
                        begin
                        write_transaction_pending_master  = 1'b1;
                        axi_write_address = {tag_value, r_addr[SIZE+1:L_SIZE+2],6'b0 };
                        end
                    else if (write_transaction_complete_master )
                        begin
                        write_transaction_pending_master  = 1'b0;
                        need_writethrough =1'b0;
                        needload = 1'b1;
                        
                        end
                end
                        
            if (needload)
                begin
                if (!read_transaction_complete_master)
                        begin
                        read_transaction_pending_master  = 1'b1;
                        axi_read_address = {r_addr[XLEN-1:L_SIZE+2],6'b0};
                        end
                else if (read_transaction_complete_master)
                        begin
                        read_transaction_pending_master = 1'b0;
                        needload = 1'b0;
                 	end
                        
                end

            
            //we start the read transaction
            
            

        end


end


always@(posedge clk)
begin
    if(read_transaction_pending_master&&!read_request_handshake_master)
    begin
        if(!ARREADY)
        begin
            ARADDR <= axi_read_address;///change
            ARSIZE <= 3'b100;
            ARLEN <= 4'b1111;
            ARBURST <= INCR;
            ARVALID <= 1'b1;
        end
        if (ARREADY&&ARVALID)
        begin
            ARVALID <= 1'b0;
            read_request_handshake_master <= 1'b1;
            cache_write_address <= axi_read_address;
        end
    end
end


always@(posedge clk)
begin
    if (read_request_handshake_master )
    begin
        if (!RLAST)
        begin
            if (RVALID)
                begin
                RREADY<=1'b1;
                end
            if (RVALID&&RREADY)
                begin
                cache[cache_write_address[SIZE+1:2]] <= RDATA;
                cache_write_address <= {{cache_write_address[XLEN-1:2] + 1'b1},2'b00};
                end  
        end

        if(RLAST&&RVALID)
        begin
        if (RREADY)
            begin
            cache[cache_write_address[SIZE+1:2]] <= RDATA;
            cache_tags[cache_write_address[SIZE+1:L_SIZE+2]] <= cache_write_address[XLEN-1:SIZE+2];
            valid_array[cache_write_address[SIZE+1:L_SIZE+2]] <= 1'b1;
            RREADY <= 1'b0;
            read_request_handshake_master <=1'b0;
            read_transaction_complete_master <= 1'b1;
        
            end
       
        end  
    end
end

















////////////////////////////////////////////////////////////////////////
//////////////////////////// write transaction /////////////////////////
////////////////////////////////////////////////////////////////////////

always@(*)
begin
if(write_pending)
    begin
        if ((tag_value == r_addr[XLEN-1:SIZE+2])&&valid_value&&!line_dirty)
            begin
                write_scycle = 1'b0;
                write_dcycle = 1'b1;
                stall = 1'b0;
                write_valid = 1'b0;
                //write_valid = 1'b1;
            end
        else if (line_dirty&&valid_value)
            begin

                ///if writing onto different onto a line...but has different tag....
                ///...we load the data from memory....but we have to check whether the existing data is dirty or not
                write_scycle = 1'b0;
                write_dcycle = 1'b0;
                need_writethrough = 1'b1;
                write_valid = 1'b0;


                

            end
        else if((!line_dirty&&valid_value)||(!valid_value))
            begin
                write_scycle = 1'b0;
                write_dcycle = 1'b0;
                needload = 1'b1;
                need_writethrough = 1'b0;
                write_valid = 1'b0;

            end
    end
end


always@*
begin
    
    if ((write_pending&&!write_valid))
        begin
            //cache miss
            //stall the stage
    

            //go to axi interface
            if (need_writethrough)
                begin
                    stall = 1'b1;
                    if (!write_transaction_complete_master)
                        begin
                        write_transaction_pending_master = 1'b1;
                        axi_write_address = {tag_value,r_addr[SIZE+1:L_SIZE+2],6'b0 };
                        end
                    else if (write_transaction_complete_master )
                        begin
                        write_transaction_pending_master = 1'b0;
                        need_writethrough =1'b0;
                        needload = 1'b1;
                        
                        end
                end
                        
            if (needload)
                begin
                stall = 1'b1;
                if (!read_transaction_complete_master)
                        begin
                        read_transaction_pending_master = 1'b1;
                        axi_read_address = {r_addr[XLEN-1:L_SIZE+2],6'b0};
                        end
                else if (read_transaction_complete_master)
                        begin
                        read_transaction_pending_master = 1'b0;
                        needload = 1'b0;
                        end
                        
                end

            

 
            //we start the read transaction
            
            

        end
 //  else 
 //   begin
 //     stall = 1'b0; 
 //  end


end


always@(posedge clk)
begin
    if(write_pending&&!write_valid)
    begin
        if (write_dcycle)
        begin
            cache[write_addr[SIZE+1:2]] <= write_data;
            dirty_array[line] <= 1'b1;
            write_valid <= 1'b1;
            write_dcycle  <= 1'b0;

        end
        else if (read_transaction_complete_master) 
        begin
            cache[write_addr[SIZE+1:2]] <= write_data;
            dirty_array[line] <= 1'b1;
            write_valid <= 1'b1;
            write_pending <= 1'b0;
            stall <= 1'b0;
            read_transaction_pending_master  <= 1'b0;
            read_transaction_complete_master <= 1'b0;
            write_transaction_pending_master <= 1'b0;
            write_transaction_complete_master<= 1'b0;
        end

    end


end





always@(posedge clk)
begin
    if(write_transaction_pending_master&&!write_request_handshake_master)
    begin
        if (!AWREADY)
        begin
            AWADDR <= axi_write_address;
            AWSIZE <= 3'b100;
            AWLEN <= 4'b1111;
            AWBURST <= INCR;
            AWVALID <= 1'b1;
           // AWREADY <= 1'b1;

            ///for our sake
            burst_type <= AWBURST;
            start_addr <= AWADDR;
            No_of_beats <= AWLEN;
            beat_size <= AWSIZE;
            
        end
        if (AWREADY&&AWVALID)
        begin
            last_addr <= start_addr + No_of_beats*beat_size;
            AWVALID <= 1'b0;
            write_request_handshake_master <= 1'b1;


        end 
    end

end

always@(posedge clk)
begin
    if (write_request_handshake_master)
    begin
        

    // if (burst_type = INCR)
    //     begin
    //         start_addr <= ARADDR;
    //         No_of_beats <= ARLEN;
    //         beat_size <= ARSIZE;
    //         ARREADY <= 1'b1; 
    //     end
   
        if (burst_type == INCR)
        begin
            if (!WVALID )
            begin
            WDATA <= cache[start_addr[SIZE+1:2]];
            WVALID <= 1'b1;
            end
            else if (WVALID&&!WREADY)
            begin
            WDATA <= cache[start_addr[SIZE+1:2]];
            end
            
            
            
            if (WVALID&&WREADY&&!WLAST)
            begin
            start_addr = start_addr + beat_size;
            WDATA <= cache[start_addr[SIZE+1:2]];
            end
            
            if (WREADY&&WREADY&&WLAST)
            begin
            WDATA <= cache[start_addr[SIZE+1:2]];
            WVALID <= 1'b0;
            write_request_handshake_master <= 1'b0;
            write_transaction_complete_master <= 1'b1;

            end
            
            
            if((start_addr == (last_addr))&&!WLAST)
                begin
                WLAST <= 1'b1;
                end
            else 
                begin
                WLAST <= 1'b0;
                end
            

    end
        

    
 end
end






endmodule