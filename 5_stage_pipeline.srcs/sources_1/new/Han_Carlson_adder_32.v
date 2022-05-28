module Han_Carlson_adder_32#(parameter N = 32)(input [N-1:0]A,B,
                                                input Cin, 
                                                output [N-1:0] P,G,
                                                output [N-1:0] Sum,Cout);

genvar i;
genvar j;


assign P = A^B;
assign G = A&B;


////////////////////////////layer 1
wire [N-1:0] G1, P1;

generate 
    for (i = 31; i > 0 ; i = i-2)
        begin
        Comb Layer_1(.GP_2({G[i],P[i]}), .GP_1({G[i-1],P[i-1]}),
                     .GP_out({G1[i],P1[i]}));
        assign G1[i-1] = G[i-1];
        assign P1[i-1] = P[i-1];
        end
endgenerate  

///////////////////////////layer 2

wire [N-1:0] G2,P2;

generate
    for(i = 31;i > 0;i = i-4)
        begin
        ////////generate combinational blocks
        Comb Layer_2(.GP_2({G1[i],P1[i]}), .GP_1({G1[i-2],P1[i-2]}),
                             .GP_out({G2[i],P2[i]}));
           
                
        assign  G2[i-1:i-3] = G1[i-1:i-3];
        assign  P2[i-1:i-3] = P1[i-1:i-3];  
                      
       

        end
endgenerate

//////////////////////////layer 3

wire [N-1:0] G3,P3;

generate
    for(i = 31;i > 6;i = i-4)
        begin
        ////////generate combinational blocks
        Comb Layer_3(.GP_2({G2[i],P2[i]}), .GP_1({G2[i-4],P2[i-4]}),
                             .GP_out({G3[i],P3[i]}));
            
                
        assign  G3[i-1:i-3] = G2[i-1:i-3];
        assign  P3[i-1:i-3] = P2[i-1:i-3];  
                      
          

        end

endgenerate
        assign  G3[3:0] = G2[3:0];
        assign  P3[3:0] = P2[3:0];

//////////////////////////layer 4

wire [N-1:0] G4,P4;

generate
   for(i = 31;i > 10;i = i-4)
        begin
        ////////generate combinational blocks
        Comb Layer_4(.GP_2({G3[i],P3[i]}), .GP_1({G3[i-8],P3[i-8]}),
                             .GP_out({G4[i],P4[i]}));
        

                
            assign  G4[i-1:i-3] = G3[i-1:i-3];
            assign  P4[i-1:i-3] = P3[i-1:i-3]; 

        end
        
       assign  G4[7:0] = G3[7:0];
       assign  P4[7:0] = P3[7:0];
endgenerate                    


//////////////////////////layer 5

wire [N-1:0] G5,P5;

generate
   for(i = 31;i > 18;i = i-4)
        begin
        ////////generate combinational blocks
        Comb Layer_4(.GP_2({G4[i],P4[i]}), .GP_1({G4[i-16],P4[i-16]}),
                             .GP_out({G5[i],P5[i]}));
        

                
            assign  G5[i-1:i-3] = G4[i-1:i-3];
            assign  P5[i-1:i-3] = P4[i-1:i-3]; 

        end
        
       assign  G5[15:0] = G4[15:0];
       assign  P5[15:0] = P4[15:0];
endgenerate  


//////////////////////////layer 6

wire [N-1:0] G6,P6;

generate
    assign  G6[31:30] = G5[31:30];
    assign  P6[31:30] = P5[31:30];
    for(i = 29;i >= 5;i = i-4)
        begin
        ////////generate combinational blocks
            
            
            Comb Layer_7(.GP_2({G5[i],P5[i]}), .GP_1({G5[i-2],P5[i-2]}),
                             .GP_out({G6[i],P6[i]}));
            
            assign  G6[i-1:i-3] = G5[i-1:i-3];
            assign  P6[i-1:i-3] = P5[i-1:i-3]; 
          

        end
        
    assign  G6[1:0] = G5[1:0];
    assign  P6[1:0] = P5[1:0];
endgenerate


//////////////////////////layer 7

wire [N-1:0] G7,P7;

generate
    assign  G7[31] = G6[31];
    assign  P7[31] = P6[31];
    for(i = 30;i > 0;i = i-2)
        begin
        ////////generate combinational blocks
            
            
            Comb Layer_8(.GP_2({G6[i],P6[i]}), .GP_1({G6[i-1],P6[i-1]}),
                             .GP_out({G7[i],P7[i]}));
            
            assign  G7[i-1] = G6[i-1];
            assign  P7[i-1] = P6[i-1]; 
          

        end
        
    assign  G7[0] = G6[0];
    assign  P7[0] = P6[0];
endgenerate



/////////////////////////////////Final Adders

wire [N-1:0] cin;
wire [N:0] G_final;
wire [N:0] P_final;


assign G_final = {G7, 1'b0};
assign P_final = {P7, 1'b1};
generate
    for(i = 0; i < 32; i = i + 1)
        begin
        assign cin[i] = G_final[i]|P_final[i]&Cin  ;      
        assign Sum[i] = cin[i]^P[i];
        end
endgenerate

endmodule



module FA(input A , B, Cin,
        output Cout, Sum
         );
    
    assign Sum = A^B^Cin;
    assign Cout = A&B|B&Cin|A&Cin;
    
endmodule

////////////////////////////////////////////////////////////////////////////////////

module Comb(input [1:0] GP_2, GP_1, 
            output [1:0] GP_out);
//1->G,0->P
assign GP_out[1] = GP_2[1]|(GP_2[0]&GP_1[1]);
assign GP_out[0] = GP_2[0]&GP_1[0];

endmodule