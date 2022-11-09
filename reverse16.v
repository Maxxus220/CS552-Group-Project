/*
    CS/ECE 552 FALL '22
    Project Demo 1
    
    This module takes a 16-bit input and outputs a 16-bit signal with the bits reversed.
    in[0] becomes out[15], in[1] becomes out[14], etc.
*/

module reverse16 (out, in, sel);
	output [15:0] out;
	input [15:0] in;
	input sel;
	
	// if only I could use a for loop :/
	assign out[0] = (sel ? in[15] : in[0]);
	assign out[1] = (sel ? in[14] : in[1]);
	assign out[2] = (sel ? in[13] : in[2]);
	assign out[3] = (sel ? in[12] : in[3]);
	assign out[4] = (sel ? in[11] : in[4]);
	assign out[5] = (sel ? in[10] : in[5]);
	assign out[6] = (sel ? in[9] : in[6]);
	assign out[7] = (sel ? in[8] : in[7]);
	assign out[8] = (sel ? in[7] : in[8]);
	assign out[9] = (sel ? in[6] : in[9]);
	assign out[10] = (sel ? in[5] : in[10]);
	assign out[11] = (sel ? in[4] : in[11]);
	assign out[12] = (sel ? in[3] : in[12]);
	assign out[13] = (sel ? in[2] : in[13]);
	assign out[14] = (sel ? in[1] : in[14]);
	assign out[15] = (sel ? in[0] : in[15]);
		
endmodule
