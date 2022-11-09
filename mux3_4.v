/*
   CS/ECE 552, Fall '22
   Project Demo 1
  
   This module creates a mux with 4 3-bit data inputs.
   It also has a 2-bit data select and a single data output.
*/
module mux3_4 (
                // Outputs
                out,
                // Inputs
                in0, in1, in2, in3, sel
                );
	input [2:0] in0;
	input [2:0] in1;
	input [2:0] in2;
	input [2:0] in3;
	input [1:0] sel;
	output [2:0] out;
	
	wire [2:0] out01, out23;
   	
   	mux3_2 OUT01 (.out(out01), .in0(in0), .in1(in1), .sel(sel[0]));
   	mux3_2 OUT23 (.out(out23), .in0(in2), .in1(in3), .sel(sel[0]));
   	mux3_2 OUT (.out(out), .in0(out01), .in1(out23), .sel(sel[1]));
   	
endmodule
