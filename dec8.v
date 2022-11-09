/*
   CS/ECE 552, Fall '22
   Homework #3, Problem #1
  
   This module creates a 3:8 decoder.
*/
module dec8 (
                // Outputs
                out0, out1, out2, out3, out4, out5, out6, out7,
                // Inputs
                in
                );
                
	input [2:0] in;
	output out0;
	output out1;
	output out2;
	output out3;
	output out4;
	output out5;
	output out6;
	output out7;
	
   	assign out0 = (in == 0 ? 1'b1 : 1'b0);
   	assign out1 = (in == 1 ? 1'b1 : 1'b0);
   	assign out2 = (in == 2 ? 1'b1 : 1'b0);
   	assign out3 = (in == 3 ? 1'b1 : 1'b0);
   	assign out4 = (in == 4 ? 1'b1 : 1'b0);
   	assign out5 = (in == 5 ? 1'b1 : 1'b0);
   	assign out6 = (in == 6 ? 1'b1 : 1'b0);
   	assign out7 = (in == 7 ? 1'b1 : 1'b0);
   	
endmodule
