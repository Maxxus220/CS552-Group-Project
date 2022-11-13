module stallBlock(
    input [15:0]  inst_If,
    input [15:0]  inst_IfId,
    input [15:0]  inst_IdEx,
    input [15:0]  inst_ExMem,
    output [15:0] inst_out
);
    // Logic signals for stall decisions
    wire stall_IFID, stall_IdEx, stall_ExMem;
	// assign each to be checked
	stallCheck checkIfId(.inst1(inst_If), .inst2(inst_IfId), .stall(stall_IFID));
	stallCheck checkIdEx(.inst1(inst_If), .inst2(inst_IdEx), .stall(stall_IdEx));
	stallCheck checkExMem(.inst1(inst_If), .inst2(inst_ExMem), .stall(stall_ExMem));
	// Decide whether to stall
	assign inst_out = (stall_IFID | stall_IdEx | stall_ExMem) ? (15'h0800) : (inst_If);
endmodule
// Helper module for checking whther a stall should occur
module stallCheck(
    input [15:0] inst1,
	input [15:0] inst2,
	output stall
);
    // Logic signals necessary to generate stall signal
    reg [2:0] dest, src1, src2, 
	wire match1, match2;
	// obtain the matching for each RAW potential
	regCheck rdrs(.match(match1), .reg1(dest), .reg2(src1)); 
	regCheck rdrs(.match(match2), .reg1(dest), .reg2(src2));
	// Dictate whether a stall should occur
	assign stall = rdrsMatch | rdrtMatch;
	
    always begin
	    // Find the source registers
	    case(inst1[15:11])
		    // R - Format
			// Shifts and arithmetic
			5'b11010, 5'b11011: begin
				src1 = inst[10:8];
				src2 = inst[7:5];
			end			
			// Sets
			5'b11100, 5'b11101, 5'b11110, 5'b11111: begin
				src1 = inst[10:8];
				src2 = inst[7:5];
			end
			// BTR
			5'b11001: begin
				src1 = inst[10:8];
				src2 = inst[7:5];			     
			end
			// I - Format - 1
			// Immediate arrithmetic
			5'b01000, 5'b01001, 5'b01010, 5'b01011: begin
				src1 = inst[10:8];	
				src2 = inst[10:8];		
			end
			// Immediate shifts
			5'b10100, 5'b10101, 5'b10110, 5'b10111: begin
				src1 = inst[10:8];
				src2 = inst[10:8];				
			end
			// Store
			5'b10000: begin
				src1 = inst[10:8];
				src2 = inst[10:8];				
			end
			// Load
			5'100001: begin
				src1 = inst[10:8];
				src2 = inst[10:8];				
			end
			// STU
			5'b10011: begin
				src1 = inst[10:8];
				src2 = inst[10:8];				
			end
			// I - Format - 2
			// SLBI
			5'b10010: begin
				src1 = inst[10:8];
				src2 = inst[10:8];				
			end
			// JR & JALR
			5'b00101, 5'b00111: begin
				src1 = inst[10:8];
				src2 = inst[10:8];				
			end
			// Branch
			5'b01100, 5'b01101, 5'b01110, 5'b01111: begin
				src1 = inst[10:8];
				src2 = inst[10:8];				
			end
			// J - Format & Other
		    default: begin
			    // Hardcode
			    src1 = 3'zzz;
				src2 = 3'zzz;
			end
		endcase
		// Find the destination register
		casex(inst2[15:11])
		    // R - Format
			// Shifts and arithmetic
			5'b11010, 5'b11011: begin
				dest = inst[4:2];
			end			
			// Sets
			5'b11100, 5'b11101, 5'b11110, 5'b11111: begin
				dest = inst[4:2];
			end
			// BTR
			5'b11001: begin
				dest = inst[4:2];			     
			end
			// I - Format - 1
			// Immediate arrithmetic
			5'b01000, 5'b01001, 5'b01010, 5'b01011: begin
				dest = inst[7:5];	
			end
			// Immediate shifts
			5'b10100, 5'b10101, 5'b10110, 5'b10111: begin
				dest = inst[7:5];				
			end
			// Load
			5'100001: begin
				dest = inst[7:5];			
			end
			// STU
			5'b10011: begin
				dest = inst[10:8];			
			end
			// I - Format - 2
			// LBI
			5'b11000: begin
				dest = inst[10:8];			
			end
			// SLBI
			5'b10010: begin
				dest = inst[10:8];			
			end
			// JAL & JALR
			5'b00101, 5'b00111: begin
				dest = 3'b111;			
			end
			// J - Format, Branch and Others
		    default: begin
			    // Hardcode
			    dest = 3'zzz;
			end
		endcase
	end
endmodule
// Helper module for checking if registers match 
module regCheck(
    input [2:0] reg1,
	input [2:0] reg2,
	output match
);
    assign match = (~(reg1[2] ^ reg2[2])) & (~(reg1[1] ^ reg2[1])) & (~(reg1[0] ^ reg2[0]));
endmodule