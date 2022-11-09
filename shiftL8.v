/*
    CS/ECE 552 FALL '22
    Project Demo 1
    
    This module shifts a 16-bit number by 8 bits to the left, and it outputs the result. 
 */
module shiftL8 (out, in, sel);

  	output [15:0] out; 
    input  [15:0] in;
    input sel;
   
	assign out = (sel ? {in[7:0],8'h00} : in);
		
endmodule
