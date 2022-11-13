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
	regCheck rdrs1(.match(match1), .reg1(dest), .reg2(src1)); 
	regCheck rdrs2(.match(match2), .reg1(dest), .reg2(src2));
	// Dictate whether a stall should occur
	assign stall = rdrsMatch | rdrtMatch;
	
    always begin
	    // Find the source registers
	    casex(inst1[15:11])
		    // R - Format
			// Shifts and arithmetic
			5'b1101x: begin
				src1 = inst[10:8];
				src2 = inst[7:5];
			end			
			// Sets
			5'b111xx: begin
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
			5'b010xx: begin
				src1 = inst[10:8];	
				src2 = inst[10:8];		
			end
			// Immediate shifts
			5'b101xx: begin
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
			5'b001x1: begin
				src1 = inst[10:8];
				src2 = inst[10:8];				
			end
			// Branch
			5'b011xx: begin
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
			5'b1101x: begin
				dest = inst[4:2];
			end			
			// Sets
			5'b111xx: begin
				dest = inst[4:2];
			end
			// BTR
			5'b11001: begin
				dest = inst[4:2];			     
			end
			// I - Format - 1
			// Immediate arrithmetic
			5'b010xx: begin
				dest = inst[7:5];	
			end
			// Immediate shifts
			5'b101xx: begin
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
			5'b0011x: begin
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
