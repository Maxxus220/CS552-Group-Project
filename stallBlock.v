module stallBlock(
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
	stallCheck checkIfId(.inst1(inst_If), .inst2(inst_IfId), .stall(stall_IFID));
	stallCheck checkIdEx(.inst1(inst_If), .inst2(inst_IdEx), .stall(stall_IdEx));
	stallCheck checkExMem(.inst1(inst_If), .inst2(inst_ExMem), .stall(stall_ExMem));
	// Decide whether to stall
	assign inst_out = (stall_IFID | stall_IdEx | stall_ExMem) ? (15'h0800) : (inst_If);
	assign stall = stall_IFID | stall_IdEx | stall_ExMem;
endmodule
