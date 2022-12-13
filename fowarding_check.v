module forwarding_check(
    input clk,
	input rst,
    input [15:0] inst1,
	input [15:0] inst2,
    output src, // Which register matched [0: rs | 1: rt]
	output forward
);
////////////
// WIRES //
//////////

        reg [2:0]
        src1,
        src2,
        dest;

        wire
        match1,
        match2;


////////////////////////
// CHECK FOR MATCHES //
//////////////////////

        regCheck DS1(.clk(clk), .rst(rst), .match(match1), .reg1(dest), .reg2(src1));
        regCheck DS2(.clk(clk), .rst(rst), .match(match2), .reg1(dest), .reg2(src2));


////////////////////
// FORWARD LOGIC //
//////////////////

        assign forward = match1 | match2;
        // Need to make sure only match2 is up since immediates set src1 and src2 to the same value
        assign src = match2 & ~match1;


///////////////////////////
// SRC & DEST DETECTION //
/////////////////////////

        always @* begin
                // Find the source registers
                casex(inst1[15:11])
                    // R - Format
                    // Shifts and arithmetic
                    5'b11010, 5'b11011: begin
                        src1 = inst1[10:8];
                        src2 = inst1[7:5];
                    end			
                    // Sets
                    5'b11100, 5'b11101, 5'b11110, 5'b11111: begin
                        src1 = inst1[10:8];
                        src2 = inst1[7:5];
                    end
                    // BTR
                    5'b11001: begin
                        src1 = inst1[10:8];
                        src2 = inst1[7:5];			     
                    end
                    // I - Format - 1
                    // Immediate arrithmetic
                    5'b01000, 5'b01001, 5'b01010, 5'b01011: begin
                        src1 = inst1[10:8];	
                        src2 = inst1[10:8];		
                    end
                    // Immediate shifts
                    5'b10100, 5'b10101, 5'b10110, 5'b10111: begin
                        src1 = inst1[10:8];
                        src2 = inst1[10:8];				
                    end
                    // Store
                    5'b10000: begin
                        src1 = inst1[10:8];
                        src2 = inst1[7:5];				
                    end
                    // Load
                    5'b10001: begin
                        src1 = inst1[10:8];
                        src2 = inst1[10:8];				
                    end
                    // STU
                    5'b10011: begin
                        src1 = inst1[10:8];
                        src2 = inst1[7:5];				
                    end
                    // I - Format - 2
                    // SLBI
                    5'b10010: begin
                        src1 = inst1[10:8];
                        src2 = inst1[10:8];				
                    end
                    // JR & JALR
                    5'b00101, 5'b00111: begin
                        src1 = inst1[10:8];
                        src2 = inst1[10:8];			
                    end
                    // Branch
                    5'b01100, 5'b01101, 5'b01110, 5'b01111: begin
                        src1 = inst1[10:8];
                        src2 = inst1[10:8];				
                    end
                    // J - Format & Other
                    default: begin
                        // Hardcode
                        src1 = 3'bzzz;
                        src2 = 3'bzzz;
                    end
                endcase
            end
            always @* begin
                // Find the destination register
                casex(inst2[15:11])
                    // R - Format
                    // Shifts and arithmetic
                    5'b11010, 5'b11011: begin
                        dest = inst2[4:2];
                    end			
                    // Sets
                    5'b11100, 5'b11101, 5'b11110, 5'b11111: begin
                        dest = inst2[4:2];
                    end
                    // BTR
                    5'b11001: begin
                        dest = inst2[4:2];			     
                    end
                    // I - Format - 1
                    // Immediate arrithmetic
                    5'b01000, 5'b01001, 5'b01010, 5'b01011: begin
                        dest = inst2[7:5];	
                    end
                    // Immediate shifts
                    5'b10100, 5'b10101, 5'b10110, 5'b10111: begin
                        dest = inst2[7:5];				
                    end
                    // Load
                    5'b10001: begin
                        dest = inst2[7:5];			
                    end
                    // STU
                    5'b10011: begin
                        dest = inst2[10:8];			
                    end
                    // I - Format - 2
                    // LBI
                    5'b11000: begin
                        dest = inst2[10:8];			
                    end
                    // SLBI
                    5'b10010: begin
                        dest = inst2[10:8];			
                    end
                    // JAL & JALR
                    5'b00110, 5'b00111: begin
                        dest = 3'b111;			
                    end
                    // J - Format, Branch and Others
                    default: begin
                        // Hardcode
                        dest = 3'bzzz;
                    end
                endcase
            end
endmodule