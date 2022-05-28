`timescale 1ns / 1ps


module pipeline_trial1 #(parameter XLEN = 32)( 
input ld_en, rd_en, clk, rst, rst_counter,fill_random,fill_values,
//input [XLEN-1:0] Load_data
);

// ------------ PROGRAM COUNTER-------


wire [1:0]ForwardAE,ForwardBE;
wire  stall_IF, stall_ID,stall_EX,stall_MEM,stall_WR,flush_EX, flush_ID;

//////counter

wire [XLEN-1:0] pcplus4_IF; 
wire [XLEN-1:0] pc_next;
reg [XLEN-1:0]pc_IF;
wire PC_Sel;

always@(posedge clk)
begin
  if(!stall_IF) begin
  if(rst_counter||rst)
    pc_IF <= 0;

  else
    pc_IF <= pc_next;
  end
end

                          
//////////////////////PC_adder//////////////////////////////


//wire [XLEN-1:0] pc_4;

Han_Carlson_adder_32 #(.N(XLEN)) PC_ADDER (.A(32'h4),.B(pc_IF),
                                            .Cin(1'b0),
                                            .Sum(pcplus4_IF),.Cout());
//////////////////////PC next select mux////////////////////

 
assign pc_next = PC_Sel_EX ? pcplus4_IF : Jump_Adder_Out_EX ;

                                        



//--------------------------INSTRUCTION FETCH STAGE--------------------------------------            
                                    

//AXI



wire [1:0] ARID,ARID_1,ARID_2;//hv to check when and how to seperate for icache and dcache
wire [XLEN-1:0] ARADDR, ARADDR_1, ARADDR_2;
wire [3:0] ARLEN, ARLEN_1, ARLEN_2;  //no.of beats
wire [2:0] ARSIZE, ARSIZE_1, ARSIZE_2; //4bytes
wire [1:0] ARBURST, ARBURST_1, ARBURST_2; //burst_type //0->FIXED//1->INCR//2->WRAP
wire ARCACHE;
wire ARVALID, ARVALID_1, ARVALID_2;
wire ARREADY;///check if ARREADY is wire or output


/////read data channel

wire [1:0] RID;
wire [XLEN-1:0]RDATA;
wire RRESP;
wire RLAST;
wire RVALID, RVALID_1, RVALID_2;
wire RREADY, RREADY_1, RREADY_2;/// check RREADY


/////write address channel

wire [1:0] AWID,AWID_1,AWID_2;
wire [XLEN-1:0] AWADDR,AWADDR_1, AWADDR_2;
wire [3:0] AWLEN,AWLEN_1,AWLEN_2;
wire [2:0] AWSIZE,AWSIZE_1, AWSIZE_2;
wire [1:0] AWBURST,AWBURST_1, AWBURST_2;
wire AWCACHE;
wire AWVALID, AWVALID_1, AWVALID_2;
wire AWREADY;

/////write data channel

wire [1:0] WID, WID_1, WID_2;
wire [XLEN-1:0] WDATA, WDATA_1, WDATA_2;
wire WSTRB;
wire WLAST, WLAST_1,WLAST_2;
wire WVALID,WVALID_1,WVALID_2;
wire WREADY;

///write response channel

wire BID;
wire BRESP;
wire BVALID;
wire BREADY;


wire Icache_stall_ID;
reg [XLEN-1:0] I_cache_data_in;
wire [XLEN-1:0] I_cache_data_out;



reg I_cache_read, I_cache_write;

always@*
    begin
    I_cache_read = 1'b1;
    I_cache_write = 1'b0;
    end

cache#(.ID(1)) I_cache_master_1(                     
                                    .rst(rst), .clk(clk),.read(I_cache_read),.write(I_cache_write),.stall(Icache_stall_ID),
                                    .i_addr(pc_IF),.i_data(I_cache_data_in),.o_data(I_cache_data_out),

                                    ////AXI 
                                    
                                    /////read address channel

                                    .ARID(ARID_1),.ARADDR(ARADDR_1),.ARBURST(ARBURST_1),.ARCACHE(ARCACHE),
                                    .ARLEN(ARLEN),.ARREADY(ARREADY),.ARSIZE(ARSIZE_1),.ARVALID(ARVALID_1),
                                    
                                    /////read data channel

                                    .RDATA(RDATA),.RID(RID),.RLAST(RLAST),.RVALID(RVALID_1),.RRESP(RRESP),
                                    .RREADY(RREADY_1),

                                    /////write address channel

                                    .AWID(AWID_1),.AWADDR(AWADDR_1),.AWLEN(AWLEN_1),.AWBURST(AWBURST_1),.AWCACHE(AWCACHE),
                                    .AWVALID(AWVALID_1),.AWREADY(AWREADY),.AWSIZE(AWSIZE_1),

                                    /////write data channel

                                    .WID(WID_1),.WDATA(WDATA_1),.WLAST(WLAST_1),.WREADY(WREADY),.WVALID(WVALID_1),.WSTRB(WSTRB),

                                    ///write response channel
                                    
                                    .BID(BID),.BRESP(BRESP),.BVALID(BVALID),.BREADY(BREADY)
);







reg [31:0]Instruction_ID,pc_ID, pcplus4_ID;

always@(posedge clk)
begin
   if(!stall_ID)
   begin
   //Instruction_ID <= flush_ID ? 32'b0 : Instruction_IF;
   pc_ID <= flush_ID ? 32'b0 : pc_IF;
   pcplus4_ID <= flush_ID ? 32'b0 : pcplus4_IF;
   end
   
end


always@(*)
begin
    Instruction_ID = flush_ID ? 32'b0 :  I_cache_data_out;
end


///////////////////////////////////////////////////////////////////////////////////////////
//-------------------------INSTRUCTION DECODE STAGE--------------------------------------//      
///////////////////////////////////////////////////////////////////////////////////////////



wire[6:0] opcode_ID, Func7_ID;
wire[4:0] rs1_ID, rs2_ID, rd_ID;
wire RegWrite_ID, MemWrite_ID, MemRead_ID, JUMP_Op1Sel_ID, Op2Sel_ID, Branch_ID, Jump_ID;
wire[1:0] ALUop_ID;
wire[2:0] Immop_ID,Func3_ID;
wire [1:0]WBSel_ID;
wire[XLEN-1:0]Immediate_ID;



/////////////////////////   GPR   ///////////////////////////


wire[XLEN-1:0] GPR_rd_data1_ID, GPR_rd_data2_ID, GPR_wr_data;



assign opcode_ID = Instruction_ID[6:0];
assign rs1_ID = Instruction_ID[19:15];
assign rs2_ID = Instruction_ID[24:20];
assign rd_ID = Instruction_ID[11:7];


assign Func3_ID = Instruction_ID[14:12];
assign Func7_ID = Instruction_ID[31:25];



GPR gpr(.clk(clk), .reset(rst), .wr_en(RegWrite), .rd_en1(1'b1), .rd_en2(1'b1),
    .rd_addr1(rs1_ID), .rd_addr2(rs2_ID), .wr_addr(rd_ID),
    .wr_data(GPR_wr_data_WR),
    .rd_data1(GPR_rd_data1_ID),.rd_data2(GPR_rd_data2_ID));
                          
                                                               
                                       
//--------------------------control unit --------------------------------------


wire [3:0]ALU_select_ID;



Control_Unit Control_Branch(.opcode(opcode_ID),
             .RegWrite(RegWrite_ID), .MemWrite(MemWrite_ID), .MemRead(MemRead_ID),
             .JUMP_Op1Sel(JUMP_Op1Sel_ID), .Op2Sel(Op2Sel_ID), .Branch(Branch_ID),.Jump(Jump_ID),
             .ALUop(ALUop_ID),.Immop(Immop_ID),.WBSel(WBSel_ID));


alu_control_2 ALU_Control(.instruction(Instruction_ID),.alu_op(ALUop_ID),
                                .ALU_select(ALU_select_ID)  ); 


 


//--------------------------Immediate generation--------------------------------------            


Immediate_Module Imm_Gen(.instruction(Instruction_ID),.Imm_op(Immop_ID),
                         .Immediate(Immediate_ID) );


//--------------------------Branch unit --------------------------------------


wire[XLEN-1:0] Branch_in1_ID, Branch_in2_ID;
wire Branch_out_ID;


assign Branch_in1_ID = GPR_rd_data1_ID;
assign Branch_in2_ID = GPR_rd_data2_ID;

Branch_Unit BLU(.A(Branch_in1_ID), .B(Branch_in2_ID),
            .Func3(Func3_ID),
            .branch_out(Branch_out_ID));



                                


////////////////////////////////////////////////////////////////////////////////////
//--------------------------EXECUTION STAGE--------------------------------------//          
//////////////////////////////////////////////////////////////////////////////////





reg [XLEN-1:0] Instruction_EX;
reg [XLEN-1:0] pc_EX, pcplus4_EX;

wire [XLEN-1:0] Jump_Adder_Out_EX;

wire[6:0] opcode_EX, Func7_EX;
reg[4:0] rs1_EX, rs2_EX, rd_EX;
reg RegWrite_EX, MemWrite_EX, MemRead_EX, JUMP_Op1Sel_EX, Op2Sel_EX, Branch_EX, Jump_EX;
reg[1:0] ALUop_EX;
reg[2:0] Immop_EX,Func3_EX;
reg [1:0]WBSel_EX;
reg[XLEN-1:0]Immediate_EX;


reg[XLEN-1:0] GPR_rd_data1_EX, GPR_rd_data2_EX;

reg [XLEN-1:0] JUMP_ADDER_out_ID;

wire[XLEN-1:0] Branch_in1_EX, Branch_in2_EX;
reg Branch_out_EX;
reg [3:0]ALU_select_EX;


always@(posedge clk)
begin
    if(stall_EX)
    begin
   //pc and instruction data.
       Instruction_EX <= flush_EX ? 32'b0 : Instruction_ID;
       pc_EX <= flush_EX ? 32'b0 : pc_ID;
       pcplus4_EX <= flush_EX ? 32'b0 : pcplus4_ID;
    
      // gpr signals
       rs1_EX <= flush_EX ? 5'b0 : rs1_ID;
       rs2_EX <= flush_EX ? 5'b0 : rs2_ID;
       rd_EX <= flush_EX ? 5'b0 : rd_ID;
    
       GPR_rd_data1_EX <= flush_EX ? 32'b0 : GPR_rd_data1_ID;
       GPR_rd_data2_EX <= flush_EX ? 32'b0 : GPR_rd_data2_ID;
       
      //control signals
       RegWrite_EX <= flush_EX ? 1'b0 : RegWrite_ID;
       MemWrite_EX <= flush_EX ? 1'b0 : MemWrite_ID;
       MemRead_EX <= flush_EX ? 1'b0 : MemRead_ID;
       WBSel_EX  <= flush_EX ? 3'b0 : WBSel_ID;
       Op2Sel_EX <= flush_EX ? 1'b0 : Op2Sel_ID;
       ALUop_EX <= flush_EX ? 2'b0 : ALUop_ID;
       Func3_EX <= flush_EX ? 3'b0 : Func3_ID;
       ALU_select_EX <= flush_EX ? 4'b0 : ALU_select_ID;
       Immediate_EX <=  flush_EX ? 32'b0 : Immediate_ID;
       Branch_out_EX <= flush_EX ? 1'b0 : Branch_out_ID;
       
       JUMP_Op1Sel_EX <= flush_EX ? 32'b0 : JUMP_Op1Sel_ID;
       
       Jump_EX <= flush_EX ? 32'b0 : Jump_ID;
       Branch_EX <= flush_EX ? 32'b0 : Branch_in1_ID;
       
       
       
       
       end
 
end  

wire PC_Sel_EX;

assign  PC_Sel_EX  = ld_en? 1'b0 : (Branch_EX&Branch_out_EX)||Jump_EX;



wire [XLEN-1:0] ALU_in1_EX, ALU_in2_EX, ALU_out_EX;
wire [2:0] Branch_select_EX;
wire sub_arth_EX;



//-------------------forwarding muxes-----------------------------


Mux_4 #(.WORD_WIDTH(32)) Forw_ALU_1_Mux (.a0(GPR_rd_data1_EX), .a1(ALU_out_MEM), .a2(GPR_wr_data_WR), .a3(),
                                           .select(ForwardAE), 
                                           .mux_out(GPR_rd_data1_EX_AF) );
                                           


Mux_4 #(.WORD_WIDTH(32)) Forw_ALU_2_Mux (.a0(GPR_rd_data2_EX), .a1(ALU_out_MEM), .a2(GPR_wr_data_WR), .a3(),
                                           .select(ForwardBE)  , 
                                           .mux_out(GPR_rd_data2_EX_AF) );
  

assign ALU_in2_EX = Op2Sel_EX ? Immediate_EX : GPR_rd_data2_EX_AF;



wire ALU_zero;
assign ALU_in1_EX = GPR_rd_data1_EX_AF;


                      
ALU_Module ALU(.data_in1(ALU_in1_EX), .data_in2(ALU_in2_EX),.alu_select(ALU_select_EX),
	        .en(1'b1),
            .data_out(ALU_out_EX), .zero(ALU_zero));
            
            
            
//////////////////////JUMP_ADD_OP1 select mux////////////////////


wire [XLEN-1:0] JUMP_ADDER_in1_EX;

assign JUMP_ADDER_in1_EX = JUMP_Op1Sel_EX ? pc_EX : GPR_rd_data1_EX_AF;
                                      

////////////////     Jump Adder     //////////////////////   
  

Han_Carlson_adder_32 #(.N(XLEN)) JUMP_ADDER (.A(JUMP_ADDER_in1_EX),.B(Immediate_EX), .Cin(1'b0), .Sum(Jump_Adder_Out_EX),.Cout());   

                                                     
                                                     
                                                     

/////////////////////////////////////////////////////////////////////////////////////        
//--------------------------DATA MEMORY STAGE--------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////



reg [XLEN-1:0] Instruction_MEM;
reg  [XLEN-1:0] pc_MEM, pcplus4_MEM;



wire[6:0] opcode_MEM, Func7_MEM;
reg[4:0] rs1_MEM, rs2_MEM, rd_MEM;
reg RegWrite_MEM, MemWrite_MEM, MemRead_MEM;
reg[2:0] Func3_MEM;
reg [1:0]WBSel_MEM;
reg[XLEN-1:0]Immediate_MEM;


reg[XLEN-1:0] GPR_rd_data1_MEM, GPR_rd_data2_MEM;

reg [XLEN-1:0] JUMP_ADDER_out_MEM;

reg[XLEN-1:0] Branch_in1_MEM, Branch_in2_MEM;
wire Branch_out_MEM;
reg [31:0]ALU_out_MEM; 
wire[XLEN-1:0] DM_data_out_MEM, DM_data_in_MEM, DM_addr_MEM;
wire[XLEN-1:0] Dcache_data_out;

wire dcache_stall_WR;


always@(posedge clk)
begin
    if (!stall_MEM)
        begin
       //pc and instruction data.
       Instruction_MEM <= Instruction_EX;
       pc_MEM <= pc_EX;
       pcplus4_MEM <= pcplus4_EX;
    
      // gpr signals
       rs1_MEM <= rs1_EX;
       rs2_MEM <= rs2_EX;
       rd_MEM <= rd_EX;
       
      //control signals
       RegWrite_MEM <= RegWrite_ID;
       MemWrite_MEM <= MemWrite_ID;
       MemRead_MEM <= MemRead_ID;
       WBSel_MEM  <= WBSel_EX;
      
       Func3_MEM <= Func3_EX;
       ALU_out_MEM <= ALU_out_EX ;
       end
   
end


assign DM_addr_MEM = ALU_out_MEM;
assign DM_data_in_MEM = GPR_rd_data2_MEM;

 

cache #(.ID(2)) D_cache_master_2(                     
                                    .rst(rst), .clk(clk),.read(MemRead_MEM),.write(MemWrite_MEM),.stall(dcache_stall_WR),
                                    .i_addr(DM_addr_MEM),.i_data(DM_data_in_MEM),.o_data(Dcache_data_out),

                                    ////AXI 
                                    
                                    /////read address channel

                                    .ARID(ARID_2),.ARADDR(ARADDR_2),.ARBURST(ARBURST_2),.ARCACHE(ARCACHE),
                                    .ARLEN(ARLEN),.ARREADY(ARREADY),.ARSIZE(ARSIZE_2),.ARVALID(ARVALID_2),
                                    
                                    /////read data channel

                                    .RDATA(RDATA),.RID(RID),.RLAST(RLAST),.RVALID(RVALID_2),.RRESP(RRESP),
                                    .RREADY(RREADY_2),

                                    /////write address channel

                                    .AWID(AWID_2),.AWADDR(AWADDR_2),.AWLEN(AWLEN_2),.AWBURST(AWBURST_2),.AWCACHE(AWCACHE),
                                    .AWVALID(AWVALID_2),.AWREADY(AWREADY),.AWSIZE(AWSIZE_2),

                                    /////write data channel

                                    .WID(WID_2),.WDATA(WDATA_2),.WLAST(WLAST_2),.WREADY(WREADY),.WVALID(WVALID_2),.WSTRB(WSTRB),

                                    ///write response channel
                                    
                                    .BID(BID),.BRESP(BRESP),.BVALID(BVALID),.BREADY(BREADY)
);

////////////////////////////////////////////////////////////////////////////////////
//--------------------------WRITE BACK STAGE--------------------------------------//
////////////////////////////////////////////////////////////////////////////////////



reg[4:0] rs1_WR, rs2_WR, rd_WR;
reg RegWrite_WR, MemWrite_WR, MemRead_WR;
reg[1:0] WBSel_WR;

reg [XLEN-1:0] Instruction_WR, ALU_out_WR, DM_data_out_WR ;
reg [XLEN-1:0] pc_WR,pcplus4_WR;


always@(posedge clk)
begin
    if (!stall_WR)
    begin
   //pc and instruction data.
       Instruction_WR <= Instruction_MEM;
       pc_WR <= pc_MEM;
       pcplus4_WR <= pcplus4_MEM;
    
      // gpr signals
       rs1_WR <= rs1_MEM;
       rs2_WR <= rs2_MEM;
       rd_WR <= rd_MEM;
    
      //control signals
       RegWrite_WR <= RegWrite_MEM;
       MemWrite_WR <= MemWrite_MEM;
       MemRead_WR <= MemRead_MEM;
       WBSel_WR  <= WBSel_MEM;
      
       
       ALU_out_WR <= ALU_out_MEM;
   end
//   DM_data_out_WR <= DM_data_out_MEM;
   
end

always@*
begin 
DM_data_out_WR = Dcache_data_out ;

end

             
Mux_4#(.WORD_WIDTH(32))  GPR_WriteData_Mux (.a0(ALU_out_WR), .a1(DM_data_out_WR), .a2(pcplus4_WR), .a3(),
                                           .select(WBSel_WR), 
                                           .mux_out(GPR_wr_data_WR) );





///////////////////////////////////////////////////////////////////////////////
//--------------------------hazard unit--------------------------------------//
///////////////////////////////////////////////////////////////////////////////




hazard_unit h1(
     PC_sel_EX,
     rs1_ID, rs2_ID, rd_ID,
     rs1_EX, rs2_EX, rd_EX,
     rs1_MEM, rs2_MEM, rd_MEM,
     rs1_WR, rs2_WR, rd_WR,
     RegWrite_ID, MemRead_ID,
     RegWrite_EX, MemRead_EX,
     RegWrite_MEM, MemRead_MEM,
     RegWrite_WR, MemRead_WR,
     Icache_stall_ID, dcache_stall_WR,
     ForwardAE, ForwardBE ,
     stall_IF, stall_ID, 
     flush_EX, flush_ID);
     
     
     
///////////////////////////////////////////////////////////////////////////////
//----------------------------AXI SLAVE--------------------------------------//
///////////////////////////////////////////////////////////////////////////////



///////////////axi controls///////////////////

//////Read Address Channel///////

assign ARID = (ARVALID_1)? ARID_1:((ARVALID_2)? ARID_2:3'hz)  ;
assign ARADDR = (ARVALID_1)? ARADDR_1:((ARVALID_2)? ARADDR_2:32'hz ) ;
assign ARLEN = (ARVALID_1)? ARLEN_1:((ARVALID_2)? ARLEN_2:32'hz ) ;
assign ARSIZE = (ARVALID_1)? ARSIZE_1:((ARVALID_2)? ARSIZE_2:32'hz ) ;
assign ARBURST = (ARVALID_1)? ARBURST_1:((ARVALID_2)? ARBURST_2:32'hz ) ;
assign ARVALID = (ARVALID_1)? ARVALID_1:((ARVALID_2)? ARVALID_2:32'hz ) ;

///////Read Data Channel///////

assign RVALID_1 = (RID == 2'b01)? RVALID:2'bz;
assign RVALID_2 = (RID == 2'b10)? RVALID:2'bz;

assign RREADY = (RID == 2'b01)? RREADY_1 :((RID == 2'b10) ? RREADY_2 : 1'bz);


////Write Address Channel////

assign AWID = (AWVALID_1)? AWID_1:((AWVALID_2)? AWID_2:3'hz)  ;
assign AWADDR = (AWVALID_1)? AWADDR_1:((AWVALID_2)? AWADDR_2:32'hz ) ;
assign AWLEN = (AWVALID_1)? AWLEN_1:((AWVALID_2)? AWLEN_2:32'hz ) ;
assign AWSIZE = (AWVALID_1)? AWSIZE_1:((AWVALID_2)? AWSIZE_2:32'hz ) ;
assign AWBURST = (AWVALID_1)? AWBURST_1:((AWVALID_2)? AWBURST_2:32'hz ) ;
assign AWVALID = (AWVALID_1)? AWVALID_1:((AWVALID_2)? AWVALID_2:32'hz ) ;


/////Write Data channel /////


assign WID = (WVALID_1)? WID_1:((WVALID_2)? WID_2:3'hz)  ;
assign WDATA = (WVALID_1)? WDATA_1:((WVALID_2)? WDATA_2:32'hz ) ;
assign WVALID = (WVALID_1)? WVALID_1:((WVALID_2)? WVALID_2:32'hz ) ;
assign WLAST = (WVALID_1)? WLAST_1:((WVALID_2)? WLAST_2:32'hz ) ;



////AXI





//wire [1:0] ARID,ARID_1,ARID_2;//hv to check when and how to seperate for icache and dcache
//wire [XLEN-1:0] ARADDR, ARADDR_1, ARADDR_2;
//wire [3:0] ARLEN, ARLEN_1, ARLEN_2;  //no.of beats
//wire [2:0] ARSIZE, ARSIZE_1, ARSIZE_2; //4bytes
//wire [1:0] ARBURST, ARBURST_1, ARBURST_2; //burst_type //0->FIXED//1->INCR//2->WRAP
//wire ARCACHE;
//wire ARVALID, ARVALID_1, ARVALID_2;
//wire ARREADY;///check if ARREADY is wire or output


///////read data channel

//wire [1:0] RID;
//wire [XLEN-1:0]RDATA;
//wire RRESP;
//wire RLAST;
//wire RVALID, RVALID_1,RVALID_2;
//wire RREADY, RREADY_1, RREADY_2;/// check RREADY


///////write address channel

//wire [1:0] AWID,AWID_1,AWID_2;
//wire [XLEN-1:0] AWADDR,AWADDR_1, AWADDR_2;
//wire [3:0] AWLEN,AWLEN_1,AWLEN_2;
//wire [2:0] AWSIZE,AWSIZE_1, AWSIZE_2;
//wire [1:0] AWBURST,AWBURST_1, AWBURST_2;
//wire AWCACHE;
//wire AWVALID, AWVALID_1, AWVALID_2;
//wire AWREADY;

///////write data channel

//wire [1:0] WID, WID_1, WID_2;
//wire [XLEN-1:0] WDATA, WDATA_1, WDATA_2;
//wire WSTRB;
//wire WLAST, WLAST_1,WLAST_2;
//wire WVALID,WVALID_1,WVALID_2;
//wire WREADY;



slave slave_1(
                                    
                                    .rst(rst), .clk(clk),.fill_random(fill_random),.fill_values(fill_values),
                                    
                                    
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

 
endmodule
///////////