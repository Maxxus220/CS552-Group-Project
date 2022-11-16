/*
   CS/ECE 552 Spring '20
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode (clk, rst, instr, instr_wb, RegData, RegDst, RegWrite, Reg1, Reg2, JumpOffset, Instr_Imm, Control);

//////////////
// SIGNALS //
////////////

		// clk/rst
		input clk, rst;

		// data inputs
		input [15:0] instr; // from fetch
		input [15:0] instr_wb;
		input [15:0] RegData; // from wb

		// control inputs
		input [1:0] RegDst;
		input RegWrite;

		// data outputs
		output [15:0] Reg1, Reg2; // to execute
		output [15:0] JumpOffset; // to execute
		output [7:0] Instr_Imm; // to execute
		output [4:0] Control; // to control

		// wires
		wire err;
		wire [2:0] WriteAdr;


//////////////
// MODULES //
////////////

		assign Control = instr[15:11];
		assign Instr_Imm = instr[7:0]; // these signals are passed to control block and exec block as is

		extend11_16 JMP_OFF(.out(JumpOffset), .in(instr[10:0]), .sel(1'b1)); // this block will never do zero-extension
		mux3_4 MUX_RegDST(.out(WriteAdr), .in0(instr_wb[10:8]), .in1(instr_wb[7:5]), .in2(instr_wb[4:2]), .in3(3'h7), .sel(RegDst)); // select write register

		// register file with bypass logic
		// technically we don't need bypass logic for a single-cycle datapath, but it won't hurt to have it for later
		regFile REG_FILE(.read1Data(Reg1), .read2Data(Reg2), .err(err), .clk(clk), .rst(rst), 
			.read1RegSel(instr[10:8]), .read2RegSel(instr[7:5]), .writeRegSel(WriteAdr), .writeData(RegData), .writeEn(RegWrite));
			
endmodule
