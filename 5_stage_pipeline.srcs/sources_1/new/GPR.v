`timescale 1ns / 1ps


module GPR(
    input clk, reset, wr_en, rd_en1, rd_en2,
    input [4:0]rd_addr1, rd_addr2, wr_addr,
    input [31:0]wr_data,
    output reg [31:0]rd_data1,rd_data2
     );
     
     reg[31:0]regfile[0:31];
     
     always@*
     begin
     if(reset)
        begin
        regfile[0] <= 32'b0;
        regfile[1] <= 32'b0;
        regfile[2] <= 32'b0;
        regfile[3] <= 32'b0;
        regfile[4] <= 32'b0;
        regfile[5] <= 32'b0;
        regfile[6] <= 32'b0;
        regfile[7] <= 32'b0;
        regfile[8] <= 32'b0;
        regfile[9] <= 32'b0;
        regfile[10] <= 32'b0;
        regfile[11] <= 32'b0;
        regfile[12] <= 32'b0;
        regfile[13] <= 32'b0;
        regfile[14] <= 32'b0;
        regfile[15] <= 32'b0;
        regfile[16] <= 32'b0;
        regfile[17] <= 32'b0;
        regfile[18] <= 32'b0;
        regfile[19] <= 32'b0;
        regfile[20] <= 32'b0;
        regfile[21] <= 32'b0;
        regfile[22] <= 32'b0;
        regfile[23] <= 32'b0;
        regfile[24] <= 32'b0;
        regfile[25] <= 32'b0;
        regfile[26] <= 32'b0;
        regfile[27] <= 32'b0;
        regfile[28] <= 32'b0;
        regfile[29] <= 32'b0;
        regfile[30] <= 32'b0;
        regfile[31] <= 32'b0;
        
        end
     end
     
    // --------Write operation----------
    
     always@(posedge clk)
     begin
     if(!reset)
     begin
        if(wr_en && (wr_addr != 5'b0))
        begin
            regfile[wr_addr] <= wr_data;
        end
     end
     end
     
     // --------read operation----------
     
     always@*
     begin
     if (reset || rd_addr1 == 5'b0)
     begin
        rd_data1 <= 32'b0; 
     end
     else if((rd_addr1 == wr_addr) && (wr_en) && (rd_en1))
     begin
        rd_data1 = wr_data;
     end
     
     else if( rd_en1) 
        rd_data1 <= regfile[rd_addr1];
     end
     
     
     always@*
     begin
     if (reset || (rd_addr2 == 5'b0))
     begin
        rd_data2 <= 32'b0; 
     end
     else if((rd_addr2 == wr_addr) && (wr_en) && (rd_en2))
     begin
        rd_data2 = wr_data;
     end
     
     else if( rd_en2) 
        rd_data2 <= regfile[rd_addr2];
     end
      
     

     
 endmodule    
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
