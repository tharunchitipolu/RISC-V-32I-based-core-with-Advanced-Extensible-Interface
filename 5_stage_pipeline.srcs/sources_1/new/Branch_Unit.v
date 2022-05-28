`timescale 1ns / 1ps

module Branch_Unit(input [31:0]A, B,
                   input [2:0] Func3,
                   output reg branch_out);
                   
wire signed [31:0]s_op_a, s_op_b, SLT,SGTE;

//Signed operands
assign s_op_a = A;
assign s_op_b = B;

assign SLT = s_op_a < s_op_b; //signed less than
assign SGTE = s_op_a > s_op_b;//signed greater than

always@*
    begin
    
       
        case(Func3)
            00: branch_out <= (A == B) ? 1:0; // equal check
            01: branch_out <= (A == B) ? 0:1; // not equal check
			02: branch_out <= SLT  ; // signed less than check
            03: branch_out <= SGTE  ;// signed greater than check
            04: branch_out <= (A < B) ? 1:0;			// unsigned less than check
            05: branch_out <= (A > B) ? 1:0;// unsigned greater than check
          default branch_out <= 1'bz;
       endcase
       end
   
endmodule