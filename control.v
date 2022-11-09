/*
    CS/ECE 552 FALL '22
    Project Demo 1
    
    This module takes in the opcode of the instruction and assigns control signals for each
    instruction type. ALUOp and BrOp are handled partially here, but will be sent back to execute
    for further processing before entering the ALU or handling branches
 */


//TODO: include signals for memory enable and dump
// for HALT: enable = 0, dump = 1
// for almost all other instructions: enable = 1, dump = 0;
module control(clk, rst, Control, ALUControl, Enable, Dump, PCVal, RegDst, RegWrite, ExtMode, IType, Reg1Rev, Reg1Shift, Zero1, 
	Zero2, ALUSrc, Branch, Jump, CompCarry, ALUComp, MemWrite, MemtoReg, AdrLink, ALUOp, sign, BrOp);

	//clock and reset
	input clk, rst;
	
	input [4:0] Control; // The opcode of this instruction
	input [1:0] ALUControl; // the function bits of this operation (used only for R-Type ALU operations that share an opcode)
	
	// control outputs
	output Enable, Dump, PCVal;
 	output [1:0] RegDst;
 	output RegWrite;
 	output ExtMode, IType, Reg1Rev, Reg1Shift, Zero1, Zero2, ALUSrc, Branch, Jump, CompCarry, ALUComp;
	output MemWrite, MemtoReg, AdrLink;
	output reg [2:0] ALUOp;
	output reg sign;
	output reg [2:0] BrOp;
	

	// MAIN CONTROL UNIT
	assign Enable = (rst ? 1'b1 : |Control); // equals 0 iff op = 00000
	assign Dump = (rst ? 1'b0 : ~Enable); // equals 1 when memory is disabled
	
	assign PCVal = ~Control[4] & Control[2]; // 0x1xx
	assign RegDst[0] = (~Control[4]) 		 // 0xxxx
						| (~Control[3] & ~Control[1]) // x0x0x
						| (~Control[3] & Control[2]); // x01xx
	assign RegDst[1] = (~Control[4] & ~Control[3]) 
						| (Control[3] & Control[2]) 
						| (Control[4] & Control[3] & Control[0]) 
						| (Control[4] & Control[3] & Control[1]);
	assign RegWrite = (Control[3] & ~Control[2]) 
					| (Control[4] & Control[0]) 
					| (Control[4] & Control[1]) 
					| (Control[4] & Control[2]) 
					| (~Control[3] & Control[2] & Control[1]);
	assign IType = (~Control[4] & Control[2]) 
					| (Control[4] & Control[3]) 
					| (~Control[3] & ~Control[2] & Control[1] & ~Control[0]);
	assign ExtMode = ~Control[1] | Control[2] | (~Control[3] & Control[0]);
	assign Reg1Rev = Control[4] & Control[3] & ~Control[2] & ~Control[1] & Control[0];
	assign Reg1Shift = Control[4] & ~Control[3] & ~Control[2] & Control[1] & ~Control[0];
	assign ALUSrc = ~Control[3] | (~Control[4] & ~Control[2]) 
				| (~Control[2] & ~Control[1] & ~Control[0]);
	assign Branch = ~Control[4] & Control[3] & Control[2];
	assign Jump = ~Control[0];			
	assign CompCarry = &Control; // 11111
	assign ALUComp = Control[4] & Control[3] & Control[2]; // 111xx
	assign MemWrite = (Control[4] & ~Control[3] & ~Control[2] & ~Control[1] & ~Control[0])
					| (Control[4] & ~Control[3] & ~Control[2] & Control[1] & Control[0]); 
	assign MemtoReg = Control[4] & ~Control[3] & ~Control[2] & ~Control[1] & Control[0];
	assign AdrLink = ~Control[4] & ~Control[3] & Control[2] & Control[1]; // 0011x
	assign Zero1 = Control[4] & Control[3] & ~Control[2] & ~Control[1] & ~Control[0];
	assign Zero2 = Reg1Rev | Branch;
	
	// ALU CONTROL UNIT
	always @* case (Control)
		5'h14, 5'h15, 5'h16, 5'h17: begin // ROLI, SLLI, RORI, SRLI
			ALUOp = {1'b0, Control[1], Control[0]};
			sign = 0;
		end
		5'h05, 5'h07, 5'h08, 5'h0c, 5'h0d, 5'h0e, 5'h0f, 
		5'h10, 5'h11, 5'h12, 5'h13, 5'h18, 5'h19: begin //ADD
			ALUOp = 3'b100;
			sign = 1'b1;
		end
		5'h1f: begin // SCO (uses unsigned addition)
			ALUOp = 3'b100;
			sign = 1'b0;
		end
		5'h09, 5'h1c, 5'h1d, 5'h1e: begin //SUB
			ALUOp = 3'b101;
			sign = 1'b1;
		end
		5'h0a: begin //XOR
			ALUOp = 3'b110;
			sign = 1'b0;
		end
		5'h0b: begin //ANDN
			ALUOp = 3'b111;
			sign = 1'b0;
		end
		5'h1a: begin
			ALUOp = {1'b0, ALUControl}; // R-TYPE ALU SHIFT
			sign = 1'b0;
		end	
		5'h1b: begin
			ALUOp = {1'b1, ALUControl}; // R-TYPE ALU NON-SHIFT
			sign = 1'b1;
		end	
		default: begin
			ALUOp = 3'b000; // result from this operation should not matter; RegWrite, MemWrite, Branch, and Jump == 0
			sign = 1'b0;
		end
	endcase
	
	// BRANCH CONTROL UNIT
	always @* case (Control) // 
		5'h0c, 5'h1c: begin // BEQZ, SEQ
			BrOp = 3'b000;
		end
		5'h0d: begin // BNEZ
			BrOp = 3'b001;
		end
		5'h0e: begin // BLTZ
			BrOp = 3'b010;
		end
		5'h1d: begin // SLT
			BrOp = 3'b011; 
		end
		5'h0f: begin // BGEZ,
			BrOp = 3'b100;
		end
		5'h1f: begin // SCO
			BrOp = 3'b101;
		end
		5'h1e: begin // SLE
			BrOp = 3'b110;
		end	
		default: begin
			BrOp = 3'b000; // result from this operation should not matter; Branch and ALUComp == 0
		end
	endcase
	
endmodule
