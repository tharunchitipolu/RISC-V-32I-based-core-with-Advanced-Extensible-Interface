`timescale 1ns / 1ps

module Encoder_8(input [7:0] En_in,
                output [2:0] En_out);
                
assign En_out = (En_in[7] == 1'b1 ) ? 3'b111:
                (En_in[6] == 1'b1 ) ? 3'b110:
                (En_in[5] == 1'b1 ) ? 3'b101:
                (En_in[4] == 1'b1) ? 3'b100:
                (En_in[3] == 1'b1) ? 3'b011:
                (En_in[2] == 1'b1) ? 3'b010:
                (En_in[1] == 1'b1) ? 3'b001:
                (En_in[0] == 1'b1) ? 3'b000: 3'bxxx;
endmodule

module Control_Unit(input [6:0] opcode,
                    output RegWrite, MemWrite, MemRead, JUMP_Op1Sel, Op2Sel, Branch,Jump,
                    output [1:0] ALUop,WBSel,
                    output [2:0] Immop

    );
    
 wire [3:0] i;
 wire [7:0] j;
demux_4 demux65(
            .din(1'b1),
            .A(opcode[6:5]),
            .Y(i));
demux_8 demux42(
            .d(1'b1),
            .sel(opcode[4:2]),
            .z(j));
            
 wire Load = i[0]&j[0];
 wire Store = i[1]&j[0];
 assign Branch = i[3]&j[0];
 
 wire JAL = i[3]*j[3];
 wire JALR = i[3]*j[1];
 
 wire LUI = i[1]*j[5];
 wire AUIPC = i[0]*j[5];
 
 wire R = i[1]*j[4];     
 wire RI = i[0]*j[4]; 
 
 assign RegWrite = ~(Store|Branch);
 assign MemRead = Load;
 assign MemWrite = Store;
 assign JUMP_Op1Sel = JALR|AUIPC;
 assign Op2Sel= ~R;
 assign Jump = JAL|JALR|AUIPC;
 assign WBSel = {Jump,Load};
 
 ////ImmediateType
 wire Imm_R = R;
 wire Imm_I = RI|Load|JALR;
 wire Imm_S = Store;
 wire Imm_B = Branch;
 wire Imm_U = LUI|AUIPC;
 wire Imm_J = JAL;
 
 
  ////my convention of ALUop
 assign ALUop[1] = ~(R|RI);//try to change this...maybe imm_J| Imm_U
 assign ALUop[0] = (RI|Jump|LUI);
 
 
 wire [7:0] Imm_type;
 
 assign Imm_type = {Imm_J, 2'b0 , Imm_U, 1'b0, Imm_I, Imm_B, Imm_S };
 
 
 
 Encoder_8 Imm_en(.En_in(Imm_type),
                .En_out(Immop));

 

endmodule


module Mux_4#(parameter WORD_WIDTH = 32)(input [WORD_WIDTH-1:0]a0,a1,a2,a3, input [1:0]select,
	     output reg [WORD_WIDTH-1:0]mux_out);

always @*
begin
	case(select)
	0: mux_out = a0;
	1: mux_out = a1;
	2: mux_out = a2;
	3: mux_out = a3;
	default: mux_out = 32'bz;
	endcase 
end

endmodule


module demux_4(output [3:0] Y, input [1:0] A, input din);
assign Y[0] = din & (~A[0]) & (~A[1]);
assign Y[1] = din & (~A[1]) & A[0];
assign Y[2] = din & A[1] & (~A[0]);
assign Y[3] = din & A[1] & A[0];
endmodule



module demux_8(d, sel, z);
input d;
input [2:0] sel;
output [7:0] z;
reg [7:0]z;
always@*
begin
case(sel)   
    3'b000: begin z=8'b00000001; end
    3'b001: begin z=8'b00000010; end
    3'b010: begin z=8'b00000100; end
    3'b011: begin z=8'b00001000; end
    3'b100: begin z=8'b00010000; end
    3'b101: begin z=8'b00100000; end
    3'b110: begin z=8'b01000000; end
    3'b111: begin z=8'b10000000; end
endcase
end

endmodule