/*
   CS/ECE 552, Fall '22
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, a reset, and a clock input.  All register state changes occur 
   on the rising edge of the clock. 
*/
module reg16 (
                // Outputs
                readData,
                // Inputs
                writeData, clk, rst 
                );
                
    input        clk, rst;
   	input [15:0] writeData;

   	output [15:0] readData;
                
	dff FF [15:0] (.q(readData), .d(writeData), .clk(clk), .rst(rst));
	
endmodule	
