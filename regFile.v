/*
   CS/ECE 552, Fall '22
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module regFile (
                // Outputs
                read1Data, read2Data, err,
                // Inputs
                clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                );

   	input        clk, rst;
   	input [2:0]  read1RegSel;
   	input [2:0]  read2RegSel;
   	input [2:0]  writeRegSel;
   	input [15:0] writeData;
   	input        writeEn;

   	output [15:0] read1Data;
   	output [15:0] read2Data;
   	output        err;

   	/* YOUR CODE HERE */
   	
   	wire [7:0] [15:0] RegIn, RegOut; // 16-bit I/O for 8 registers
   	wire [7:0] [15:0] MidWrite, PreRegIn; // intermediate write signals
   	wire [7:0] WriteSel; // decoded version of writeRegSel
   	
   	// detect error (i figured this logic is unique enough that it does not need to have lower hierarchy)
   	assign err = ((^writeData === 1'bX) ? 1'b1 	// check if input is bad
   	: ((writeEn === 1'bX) ? 1'b1 : 1'b0)); 			// ...or if enable is bad
   	
   	
   	
   				 
   	// Assign the readData to the correct registers
   	mux16_8 READ1(.out(read1Data), .in0(RegOut[0]), .in1(RegOut[1]), .in2(RegOut[2]), .in3(RegOut[3]),
   				 .in4(RegOut[4]), .in5(RegOut[5]), .in6(RegOut[6]), .in7(RegOut[7]), .sel(read1RegSel));
   	mux16_8 READ2(.out(read2Data), .in0(RegOut[0]), .in1(RegOut[1]), .in2(RegOut[2]), .in3(RegOut[3]),
   				 .in4(RegOut[4]), .in5(RegOut[5]), .in6(RegOut[6]), .in7(RegOut[7]), .sel(read2RegSel));
   				 
    // Write to the correct register
    dec8 DECODE (.out0(WriteSel[0]), .out1(WriteSel[1]), .out2(WriteSel[2]), .out3(WriteSel[3]), 
    			.out4(WriteSel[4]), .out5(WriteSel[5]), .out6(WriteSel[6]), .out7(WriteSel[7]), .in(writeRegSel));
    mux16_2 WRITE_SEL [7:0] (.out(MidWrite), .in0(RegOut), .in1(writeData), .sel(WriteSel));
    mux16_2 WRITE_SEL_EN [7:0] (.out(PreRegIn), .in0(RegOut), .in1(MidWrite), .sel(writeEn));
    mux16_2 RESET [7:0] (.out(RegIn), .in0(PreRegIn), .in1(16'b0000), .sel(rst));
   			
   	// 8 registers with 16 registers each
	reg16 REG [7:0] (.readData(RegOut), .writeData(RegIn), .clk(clk), .rst(rst));
	
	
endmodule
