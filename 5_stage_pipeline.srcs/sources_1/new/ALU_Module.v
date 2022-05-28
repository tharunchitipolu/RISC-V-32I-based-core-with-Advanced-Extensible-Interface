module ALU_Module(input [31:0]data_in1, data_in2,input [3:0] alu_select,
	        input en,
            output reg [31:0]data_out, output zero);

wire signed [31:0]s_op_a, s_op_b;
wire SLT,SGTE;

//Signed operands
assign s_op_a = data_in1;
assign s_op_b = data_in2;

assign SLT = s_op_a < s_op_b; //signed less than
assign SGTE = s_op_a >= s_op_b;//signed greater than


always @ *
begin
 if (en)
   begin
	case (alu_select)
	00: data_out <= data_in1 + data_in2; // ADD,ADDI,LW,SW,AUIPC,LUI
	01: data_out <= data_in1 - data_in2;//SUBTRACTION
	02: data_out <= data_in1 & data_in2;//AND,ANDI
	03: data_out <= data_in1 | data_in2;//OR,ORI
	07: data_out <= data_in1 ^ data_in2;//XOR,XORI
	08: data_out <= data_in1  << data_in2  ;  //SLLI,SLL (logical left shift)
	09: data_out <= data_in1  >> data_in2;   // SRLI,SRL (logical right sift)
	10: data_out <= data_in1  >>> data_in2 ; //SRAI,SRA (arithmetic shift right) 
	11: data_out <= (data_in1 != data_in2) ;  // BNE (not equals)
	12: data_out <= SLT ; //SLTI,SLT,BLT (signed less than)
	13: data_out <=  (data_in1 < data_in2) ;//BLTU,SLTU,SLTIU (unsigned less than)
	14: data_out <= SGTE; // BGE (signed greater than or equal to)
	//5: data_out <= data_in1 ; //JAL,JALR(passthrough)
    	default  data_out <= 32'bz;
  	endcase
end
end

	assign zero = (data_out==0);

endmodule
