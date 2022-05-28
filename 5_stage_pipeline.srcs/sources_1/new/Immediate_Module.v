`timescale 1ns / 1ps

module Immediate_Module(input [31:0] instruction,
                     input [2:0] Imm_op,
                     output reg [31:0] Immediate );
                     
reg [11:0] imm_12;
reg [19:0] imm_20;
always@* 
    begin
    if (Imm_op == 3'b001)//I
        begin
        imm_12 = instruction[31:20];
        Immediate = {{20{imm_12[11]}}, imm_12};
        end
    else if(Imm_op == 3'b010)//S
        begin
        imm_12 = {instruction[31:25],instruction[11:7]};
        Immediate = {{20{imm_12[11]}}, imm_12};
        end
    else if(Imm_op == 3'b011)//B
        begin
        imm_12 = {instruction[31],instruction[7],instruction[30:25],instruction[11:8]};
        Immediate = {{19{imm_12[11]}}, imm_12,1'b0};
        end
    else if(Imm_op == 3'b100)//U
        begin
        imm_20 = {instruction[31:12]};
        Immediate = {imm_20, 12'b0};
         
         end
    else if(Imm_op == 3'b101)//J
        begin
        imm_20 = {instruction[31],instruction[19:12],instruction[20],instruction[30:21]};
        Immediate = {{11{imm_20[19]}} ,imm_20 , 1'b0 };
    end
    end
endmodule     
