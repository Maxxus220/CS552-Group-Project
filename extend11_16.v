/*
   CS/ECE 552, Fall '22
   Project Demo 1
  
   This module creates a signal extender with an 11-bit input and 16-bit output.
   It also has a select input to switch between zero-extension and sign-extension.
*/
module extend11_16 (
                // Outputs
                out,
                // Inputs
                in, sel
                );
	input [10:0] in;
	input sel; // 0 = zero extension, 1 = sign extension
	output [15:0] out;
	
	wire MSB;
	
	assign MSB = (in[10] & sel); // will always be 0 during zero ext, or in[10] during sign ext
   	assign out = {{5{MSB}},in[10:0]}; 
   	
endmodule
