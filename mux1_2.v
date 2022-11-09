/*
   CS/ECE 552, Fall '22
   Homework #3, Problem #1
  
   This module creates a mux with 2 1-bit data inputs.
   It also has a 1-bit data select and a single data output.
*/
module mux1_2 (
                // Outputs
                out,
                // Inputs
                in0, in1, sel
                );
	input in0;
	input in1;
	input sel;
	output out;
	
   	assign out = (sel ? in1 : in0);
   	
endmodule
