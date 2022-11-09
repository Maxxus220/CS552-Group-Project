/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
   
   // I/O signals
	wire [15:0] JBAdr;
	wire [15:0] instr; 
	wire [15:0] PCplus2;
	wire [15:0] RegData;
	wire [15:0] Reg1, Reg2;
	wire [15:0] JumpOffset;
	wire [7:0] instr_imm;
	wire [15:0] ALUOut; 
	wire [15:0] DataOut;
	wire [15:0] WriteData;
	wire [15:0] MemOut;

	// Control signals
	wire [4:0] Control;
	wire PCVal;
	wire [1:0] RegDst;
	wire RegWrite;
	wire ExtMode, IType, Reg1Rev, Reg1Shift, Zero1, Zero2, ALUSrc, Branch, Jump, CompCarry, ALUComp;
	wire [2:0] ALUOp, BrOp;
	wire MemWrite;
	//wire MemRead; keeping it here just in case
	wire MemtoReg, AdrLink;
	
	// control module
	control CONTROL(.clk(clk), .rst(rst), .Control(Control), .ALUControl(instr_imm[1:0]), .Enable(Enable), .Dump(Dump), .PCVal(PCVal), .RegDst(RegDst), .RegWrite(RegWrite), 
		.ExtMode(ExtMode), .IType(IType), .Reg1Rev(Reg1Rev), .Reg1Shift(Reg1Shift), .Zero1(Zero1), .Zero2(Zero2), 
		.ALUSrc(ALUSrc), .Branch(Branch), .Jump(Jump), .CompCarry(CompCarry), .ALUComp(ALUComp), 
   		.MemWrite(MemWrite), .MemtoReg(MemtoReg), .AdrLink(AdrLink), .ALUOp(ALUOp), .sign(sign), .BrOp(BrOp));
   
   // instantiations of fetch, decode, execute, mem and wb modules
   fetch FETCH(.clk(clk), .rst(rst), .JBAdr(JBAdr), 	// fetch data inputs
   		.PCVal(PCVal), .Enable(Enable), .Dump(Dump), 	// fetch control inputs
   		.instr(instr), .PCplus2(PCplus2));			  	// fetch outputs
   		
   decode DECODE(.clk(clk), .rst(rst), .instr(instr), .RegData(RegData),								// decode data inputs
   		 .RegDst(RegDst), .RegWrite(RegWrite), 															// decode control inputs
   		 .Reg1(Reg1), .Reg2(Reg2), .JumpOffset(JumpOffset), .instr_imm(instr_imm), .Control(Control));	// decode outputs (including the one and only control output)
   		 
   execute EXECUTE(.clk(clk), .rst(rst), .Reg1(Reg1), .Reg2(Reg2), .JumpOffset(JumpOffset), .PCplus2(PCplus2), .instr_imm(instr_imm), 	// execute data inputs
   		.ExtMode(ExtMode), .IType(IType), .Reg1Rev(Reg1Rev), .Reg1Shift(Reg1Shift), .Zero1(Zero1), .Zero2(Zero2), .ALUSrc(ALUSrc), 		// execute control inputs
   		.BrOp(BrOp), .Branch(Branch), .Jump(Jump), .CompCarry(CompCarry), .ALUComp(ALUComp), .ALUOp(ALUOp), .sign(sign),				// more execute control inputs
   		.ALUOut(ALUOut), .DataOut(DataOut), .JBAdr(JBAdr), .WriteData(WriteData)); 													// execute outputs
   		
   memory MEMORY(.clk(clk), .rst(rst), .ALUOut(ALUOut), .WriteData(WriteData),	// memory data inputs
   		.MemWrite(MemWrite), .Enable(Enable), .Dump(Dump), 						// memory control inputs
   		.MemOut(MemOut));														// memory outputs
   		
   wb WRITEBACK(.clk(clk), .rst(rst), .DataOut(DataOut), .MemOut(MemOut), .PCplus2(PCplus2), // wb data inputs
   		.MemtoReg(MemtoReg), .AdrLink(AdrLink), 											// wb control inputs
   		.RegData(RegData));																	// wb outputs
   				
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
