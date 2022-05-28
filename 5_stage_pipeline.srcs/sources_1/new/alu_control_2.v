`timescale 1ns / 1ps

module alu_control_2(input [31:0] instruction,
                   input [1:0] alu_op,
                   output [3:0] ALU_select );
 wire [2:0] Func3 = instruction[14:12];
 wire [6:0] Func7 = instruction[31:25];
   
 wire [3:0] alu_select0 = {Func7[5],Func3};
 wire [3:0] alu_select1 = {(~Func3[1]&Func3[0])&Func7[5],Func3};
 
 Mux_4#(.WORD_WIDTH(4)) GPR_WriteData_Mux (.a0(alu_select0), .a1(alu_select1), .a2(4'b0), .a3(4'b0),
                                           .select(alu_op), 
                                           .mux_out(ALU_select) );     
 
             
                   
endmodule