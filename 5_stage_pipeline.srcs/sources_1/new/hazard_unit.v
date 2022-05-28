`timescale 1ns / 1ps

module hazard_unit(
    input PC_sel_EX,
    input [4:0] rs1_ID, rs2_ID, rd_ID,
    input [4:0] rs1_EX, rs2_EX, rd_EX,
    input [4:0] rs1_MEM, rs2_MEM, rd_MEM,
    input [4:0] rs1_WR, rs2_WR, rd_WR,
    input RegWrite_ID, MemRead_ID,
    input RegWrite_EX, MemRead_EX,
    input RegWrite_MEM, MemRead_MEM,
    input RegWrite_WR, MemRead_WR,
    input Icache_stall, Dcache_stall,
    input master_en,
    
    output reg [1:0] ForwardAE, ForwardBE ,
    output reg stall_IF, stall_ID, stall_EX, stall_MEM, stall_WR,
    output reg flush_EX, flush_ID
    
    
    );
    
    //forwardAE
    always @*
    begin
        if (((rs1_EX == rd_MEM)&RegWrite_MEM)&(rs1_EX != 4'b0))
            ForwardAE = 01;
        else if (((rs1_EX == rd_WR)&RegWrite_WR)&(rs1_EX != 4'b0))
            ForwardAE = 10;
        else
            ForwardAE = 00;
    end


    //forwardBE
    always @*
        begin
            if (((rs2_EX == rd_MEM)&&RegWrite_MEM)&&(rs2_EX != 4'b0))
                ForwardBE = 01;
            else if (((rs2_EX == rd_WR)&&RegWrite_WR)&&(rs2_EX != 4'b0))
                ForwardBE = 10;
            else
                ForwardBE = 00;
        end
    

    //stalls and flushes
    reg lwstall;
    always @*
        begin
            if (MemRead_EX&&((rs1_ID == rd_EX)||((rs2_ID == rd_EX))))
                lwstall = 1'b1;
            else
                lwstall = 1'b0;
        
        
        //////stall
        stall_WR = Dcache_stall||(!master_en);        
        stall_MEM = stall_WR;   
        stall_EX = stall_MEM;       
        stall_ID = lwstall||Icache_stall||stall_EX;
        stall_IF = lwstall||stall_ID;
        
        
        
        //////flush
        flush_EX = lwstall||PC_sel_EX;
        flush_ID = PC_sel_EX;
        end 
endmodule


