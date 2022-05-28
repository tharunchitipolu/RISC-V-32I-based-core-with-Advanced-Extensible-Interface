`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2022 14:25:37
// Design Name: 
// Module Name: axi_seperate_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_seperate_tb#(parameter XLEN = 32)();

// parameters
parameter L_SIZE = 4;
parameter LINES = 8;
parameter SIZE = LINES+L_SIZE;


//axi burst types
parameter FIXED = 2'b00;
parameter INCR = 2'b01;
parameter WRAP = 2'b10;


wire ARID;//hv to check when and how to seperate for icache and dcache
wire [XLEN-1:0] ARADDR;
wire [3:0] ARLEN;  //no.of beats
wire [2:0] ARSIZE; //4bytes
wire [1:0] ARBURST; //burst_type //0->FIXED//1->INCR//2->WRAP
wire ARCACHE;
wire ARVALID;
wire ARREADY;///check if ARREADY is wire or output


/////read data channel

wire RID;
wire [XLEN-1:0]RDATA;
wire RRESP;
wire RLAST;
wire RVALID;
wire RREADY;/// check RREADY


/////write address channel

wire AWID;
wire [XLEN-1:0] AWADDR;
wire [3:0] AWLEN;
wire [2:0] AWSIZE;
wire [1:0] AWBURST;
wire AWCACHE;
wire AWVALID;
wire AWREADY;

/////write data channel

wire WID;
wire [XLEN-1:0] WDATA;
wire WSTRB;
wire WLAST;
wire WVALID;
wire WREADY;

///write response channel

wire BID;
wire BRESP;
wire BVALID;
wire BREADY;


reg [XLEN-1:0] i_addr, i_data;
reg rst, read, write, clk, fill_random;
wire [XLEN-1:0] o_data;
wire stall;


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


cache master_1(                     
                                    .rst(rst), .clk(clk),.read(read),.write(write),.stall(stall),
                                    .i_addr(i_addr),.i_data(i_data),.o_data(o_data),

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


initial 
    begin
   #800
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
    
    
    
    
always@*
begin
#50 clk <= !clk;
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



endmodule
