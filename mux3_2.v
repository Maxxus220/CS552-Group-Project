/*
   CS/ECE 552, Fall '22
   Project Demo 1
  
   This module creates a mux with 2 3-bit data inputs.
   It also has a 1-bit data select and a single data output.
*/
module mux3_2 (
                // Outputs
                out,
                // Inputs
                in0, in1, sel
                );
	input [2:0] in0;
	input [2:0] in1;
	input sel;
	output [2:0] out;
	
   	assign out = (sel ? in1 : in0);
   	
endmodule
