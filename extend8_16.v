/*
   CS/ECE 552, Fall '22
   Project Demo 1
  
   This module creates a signal extender with an 8-bit input and 16-bit output.
   It also has a select input to switch between zero-extension and sign-extension.
*/
module extend8_16 (
                // Outputs
                out,
                // Inputs
                in, sel
                );
	input [7:0] in;
	input sel; // 0 = zero extension, 1 = sign extension
	output [15:0] out;
	
	wire MSB;
	
	assign MSB = (in[7] & sel); // will always be 0 during zero ext, or in[7] during sign ext
   	assign out = {{8{MSB}},in[7:0]}; 
   	
endmodule
