/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (clk, rst, Reg1, Reg2, JumpOffset, PCplus2, Instr_Imm, ExtMode, IType, Reg1Rev, Reg1Shift, 
				Zero1, Zero2, ALUSrc, BrOp, Branch, JumpType, CompCarry, ALUComp, ALUOp, sign, PCVal, ALUOut, DataOut, JBAdr, WriteData, BrJmpTaken);

	// clk/rst
	input clk, rst;
	// data inputs (all from decode)
	input [15:0] Reg1, Reg2; // from decode
	input [15:0] JumpOffset; // from decode
	input [15:0] PCplus2; // from fetch
	input [7:0] Instr_Imm; // from decode
	// control inputs
	input ExtMode, IType, Reg1Rev, Reg1Shift, Zero1, Zero2, ALUSrc, Branch, JumpType, CompCarry, ALUComp;
	input [2:0] ALUOp, BrOp;  
	input sign;
	input PCVal;
	// data outputs
	output [15:0] ALUOut; // to memory
	output [15:0] DataOut; // to wb
	output [15:0] JBAdr; // to fetch
	output [15:0] WriteData; // to memory
	output BrJmpTaken;

	assign WriteData = Reg2;

	// immediate calculation
	wire [15:0] Imm8, Imm5, Imm;
	extend8_16 EXT8(.out(Imm8), .in(Instr_Imm), .sel(ExtMode));
	extend5_16 EXT5(.out(Imm5), .in(Instr_Imm[4:0]), .sel(ExtMode));
	mux16_2 MUX_IType(.out(Imm), .in0(Imm5), .in1(Imm8), .sel(IType));

	// ALU operation

	wire [15:0] Reg1R, Reg1S, Reg2I, ALUIn1, ALUIn2;
	reg [2:0] Oper;
	reg Cin, invA, invB;
	wire zero, carry; 
	
	// jump and branch
	wire [15:0] PC2OffJ, PC2OffB, JumpAdr, BranchAdr;
	reg BrOpOut;
	wire BrEn; 

	// CompCarry out (for SEQ/SLT/SLE/SCO)
	wire [15:0] RawComp; 
	
	// ALU Control Unit that assigns ALU control inputs based on ALUOp
	always @* case (ALUOp)
		3'b000, 3'b001, 3'b010, 3'b011: begin // Rotate/Shift
			Oper = ALUOp;
			Cin = 1'b0;
			invA = 1'b0;
			invB = 1'b0;
		end	
		3'b100:begin // Add (technically this is the same case as above; separated for clarity)
			Oper = 3'b100;
			Cin = 1'b0;
			invA = 1'b0;
			invB = 1'b0;
		end
		3'b101:begin // Subtract (IMPORTANT: ALUIn2 - ALUIn1)
			Oper = 3'b100;
			Cin = 1'b1;
			invA = 1'b1;
			invB = 1'b0;
		end
		3'b110:begin // XOR
			Oper = 3'b111;
			Cin = 1'b0;
			invA = 1'b0;
			invB = 1'b0;
		end
		3'b111:begin // ANDN (IMPORTANT: ALUIn2 is ALWAYS inverted)
			Oper = 3'b101;
			Cin = 1'b0;
			invA = 1'b0;
			invB = 1'b1;
		end
	endcase	

	// prepare ALU inputs
	reverse16 REV(.out(Reg1R), .in(Reg1), .sel(Reg1Rev)); // reverse Reg1
	shiftL8 SL8(.out(Reg1S), .in(Reg1R), .sel(Reg1Shift));  // shift Reg1 to the left by 8 (should never shift a reversed signal)
	mux16_2 MUX_ALUSrc(.out(Reg2I), .in0(Reg2), .in1(Imm), .sel(ALUSrc)); // select between Reg2 and the Immediate
	mux16_2 MUX_Zero1(.out(ALUIn1), .in0(Reg1S), .in1(16'h0000), .sel(Zero1)); // select between Reg1 and 0
	mux16_2 MUX_Zero2(.out(ALUIn2), .in0(Reg2I), .in1(16'h0000), .sel(Zero2)); // select between Reg2 (or the immediate) and 0

	// the alu itself
	alu ALU (.InA(ALUIn1), .InB(ALUIn2), .Cin(Cin), .Oper(Oper), .invA(invA), .invB(invB), .sign(sign), .Out(ALUOut), .Zero(zero), .Ofl(carry));

	// branch Control Unit that assigns branch conditions based on BrOp
	always @* case (BrOp)
		3'b000: begin // BEQZ, SEQ
			BrOpOut = zero;
		end
		3'b001: begin // BNEZ
			BrOpOut = ~zero;
		end
		3'b010: begin // BLTZ
			BrOpOut = ~zero & ALUOut[15];
		end
		3'b011: begin // SLT
			BrOpOut = (carry ? ~zero & ALUOut[15] : ~zero & ~ALUOut[15]);
		end	
		3'b100:begin // BGEZ 
			BrOpOut = ~ALUOut[15];
		end
		3'b101:begin // SCO
			BrOpOut = carry;
		end
		3'b110:begin // SLE
			BrOpOut = (carry ? ALUOut[15] : ~ALUOut[15]); 
		end	
		default: begin // ERROR; don't branch
			BrOpOut = 1'b0;
		end
	endcase	

	// calculate jump and branch addresses
	wire dummy1, dummy2; // dummy wires for CLA c_out (unused)
	cla_16b JUMPADDER(.sum(PC2OffJ), .c_out(dummy), .a(PCplus2), .b(JumpOffset), .c_in(1'b0));
	cla_16b BRANCHADDER(.sum(PC2OffB), .c_out(dummy), .a(PCplus2), .b(Imm), .c_in(1'b0));
	assign BrEn = Branch & BrOpOut;
	
	// select appropriate branch or jump address
	mux16_2 MUX_BrEn(.out(BranchAdr), .in0(PCplus2), .in1(PC2OffB), .sel(BrEn)); // determine if branch is taken
	mux16_2 MUX_Jump(.out(JumpAdr), .in0(ALUOut), .in1(PC2OffJ), .sel(JumpType));
	mux16_2 MUX_Branch(.out(JBAdr), .in0(JumpAdr), .in1(BranchAdr), .sel(Branch));

	// select between ALUOut or branch comparison (including carry bit)
	assign RawComp = {15'h0000, BrOpOut}; // extend RawComp to 16 bits before selecting between it and ALUOut
	mux16_2 MUX_ALUComp(.out(DataOut), .in0(ALUOut), .in1(RawComp), .sel(ALUComp));
	assign BrJmpTaken = BrEn | (PCVal & ~Branch);
   
endmodule
