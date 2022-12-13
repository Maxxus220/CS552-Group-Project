module stallBlock(
	input clk,
	input rst,
    input [15:0]  inst_If,
    input [15:0]  inst_IfId,
    input [15:0]  inst_IdEx,
    input [15:0]  inst_ExMem,
    output [15:0] inst_out,
    output stall
);
    // Logic signals for stall decisions
    wire stall_IFID, stall_IdEx, stall_ExMem;
	// assign each to be checked
	stallCheck checkIfId(.clk(clk), .rst(rst), .inst1(inst_If), .inst2(inst_IfId), .stall(stall_IFID));
	//stallCheck checkIdEx(.clk(clk), .rst(rst), .inst1(inst_If), .inst2(inst_IdEx), .stall(stall_IdEx));
	stallCheck checkExMem(.clk(clk), .rst(rst), .inst1(inst_If), .inst2(inst_ExMem), .stall(stall_ExMem));
	// Decide whether to stall
	assign stall = (((inst_IfId[15:11] == 5'd17) ? stall_IFID : 1'b0) /*| stall_IdEx*/ | stall_ExMem);
	// Decide whether to propogate a halt
	assign halt = (~(|inst_IfId[15:11])) | (~(|inst_IdEx[15:11])) | (~(|inst_ExMem[15:11]));
	// Assign the instruction value based on fetch or the halt/stall logic
	assign inst_out = (halt) ? (16'h0000) : ((stall ? (16'h0800) : (inst_If)));
	
endmodule

