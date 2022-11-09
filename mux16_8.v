/*
   CS/ECE 552, Fall '22
   Homework #3, Problem #1
  
   This module creates a mux with 8 16-bit data inputs.
   It also has a 3-bit data select and a single data output.
*/
module mux16_8 (
                // Outputs
                out,
                // Inputs
                in0, in1, in2, in3, in4, in5, in6, in7, sel
                );
                
	input [15:0] in0;
	input [15:0] in1;
	input [15:0] in2;
	input [15:0] in3;
	input [15:0] in4;
	input [15:0] in5;
	input [15:0] in6;
	input [15:0] in7;
	input [2:0] sel;
	output [15:0] out;
	
	wire [15:0] out03, out47;
   	
   	mux16_4 OUT03 (.out(out03), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .sel(sel[1:0]));
   	mux16_4 OUT47 (.out(out47), .in0(in4), .in1(in5), .in2(in6), .in3(in7), .sel(sel[1:0]));
   	mux16_2 OUT (.out(out), .in0(out03), .in1(out47), .sel(sel[2]));
   	
endmodule
