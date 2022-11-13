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
	
	wire [15:0] instr_FETCH, instr_DECODE, instr_EXECUTE, instr_MEMORY;
	wire [15:0] instr_IN; // instruction that enters the fetch block after considering stalls
	wire [15:0] PCplus2_FETCH, PCplus2_DECODE, PCplus2_EXECUTE, PCplus2_MEMORY, PCplus2_WB;
	wire [15:0] RegData_DECODE, RegData_EXECUTE;
	wire [15:0] Reg1_DECODE, Reg2_DECODE, Reg1_EXECUTE, Reg2_EXECUTE;
	wire [15:0] JumpOffset_DECODE, JumpOffset_EXECUTE;
	wire [7:0]  instr_imm_DECODE, instr_imm_EXECUTE;
	wire [15:0] ALUOut_EXECUTE, ALUOut_MEMORY; 
	wire [15:0] DataOut_EXECUTE, DataOut_MEMORY, DataOut_WB;
	wire [15:0] WriteData_EXECUTE, WriteData_MEMORY;
	wire [15:0] MemOut_MEMORY, MemOut_WB;

	// Control signals
	wire [4:0]  Control;
	wire [26:0] ControlSignals_DECODE, ControlSignals_EXECUTE; 
	wire [7:0]  ControlSignals_MEMORY; 
	wire [4:0]  ControlSignals_WB;
	
	wire stall;
	
	// stall block module - checks for dependencies and inserts NOPs as needed
	stallBlock(.inst_If(instr_FETCH), .inst_IfId(instr_DECODE), .inst_IdEx(instr_EXECUTE), .inst_ExMem(instr_MEMORY), 
		.inst_out(instr_IN), .stall(stall));
	
	// control module
	control CONTROL(.clk(clk), .rst(rst), .Control(Control), .ALUControl(instr_imm[1:0]), .ControlSignals(ControlSignals_DECODE));
   
    // fetch module
	fetch FETCH(.clk(clk), .rst(rst), .JBAdr(JBAdr), 	// fetch data inputs
   		.PCVal(ControlSignals_EXECUTE[6]), .Enable(Enable), .Dump(Dump), .stall(stall), 	// fetch control inputs
   		.instr(instr_FETCH), .PCplus2(PCplus2_FETCH));	// fetch outputs
   		
   	// fetch-decode flip flop	
	dff FD_FF [31:0] (.q({PCplus2_DECODE,instr_DECODE}), .d({PCplus2_FETCH,instr_FETCH}), .clk(clk), .rst(rst));
   	
   	// decode module
	decode DECODE(.clk(clk), .rst(rst), .instr(instr), .RegData(RegData),					// decode data inputs
   		 .RegDst(ControlSignals_WB[2:1]), .RegWrite(ControlSignals_WB[3]), 												// decode control inputs
   		 .Reg1(Reg1_DECODE), .Reg2(Reg2_DECODE), 
   		 .JumpOffset(JumpOffset_DECODE), .instr_imm(instr_imm_DECODE), .Control(Control));	// decode outputs
   		 
   	// decode-execute data flip flop
   	dff DX_DATA_FF [87:0] (.q({instr_EXECUTE,instr_imm_EXECUTE,JumpOffset_EXECUTE,PCplus2_EXECUTE,Reg2_EXECUTE,Reg1_EXECUTE}), 
   						   .d({instr_DECODE,instr_imm_DECODE,JumpOffset_DECODE,PCplus2_DECODE,Reg2_DECODE,Reg1_DECODE}), 
   						   .clk(clk), .rst(rst));
   	
   	// decode-execute control flip flop
   	dff DX_CTRL_FF [26:0] (.q(ControlSignals_EXECUTE), .d(ControlSignals_DECODE), .clk(clk), .rst(rst));
   	
   	// execute module
	execute EXECUTE(.clk(clk), .rst(rst), .Reg1(Reg1_EXECUTE), .Reg2(Reg2_EXECUTE), .JumpOffset(JumpOffset_EXECUTE), 
		.PCplus2(PCplus2_EXECUTE), .instr_imm(instr_imm_EXECUTE), 																	// execute data inputs
   		.ExtMode(ControlSignals_EXECUTE[7]), .IType(ControlSignals_EXECUTE[8])), .Reg1Rev(ControlSignals_EXECUTE[9])), 
   		.Reg1Shift(ControlSignals_EXECUTE[10])), .Zero1(ControlSignals_EXECUTE[11])), .Zero2(ControlSignals_EXECUTE[12])), 
   		.ALUSrc(ControlSignals_EXECUTE[13])), .BrOp(ControlSignals_EXECUTE[5:3])), .Branch(ControlSignals_EXECUTE[14])), .Jump(ControlSignals_EXECUTE[15])), 
   		.CompCarry(ControlSignals_EXECUTE[16])), .ALUComp(ControlSignals_EXECUTE[17])), .ALUOp(ControlSignals_EXECUTE[2:0])), .sign(ControlSignals_EXECUTE[18])),	// execute control inputs
   		.ALUOut(ALUOut_EXECUTE), .DataOut(DataOut_EXECUTE), .JBAdr(JBAdr), .WriteData(WriteData_EXECUTE)); 							// execute outputs (JBAdr ties directly to fetch)
   		
   	// execute-memory data flip flop
   	dff XM_DATA_FF [79:0] (.q({instr_MEMORY,PCplus2_MEMORY,DataOut_MEMORY,WriteData_MEMORY,ALUOut_MEMORY}), 
   						   .d({instr_EXECUTE,PCplus2_EXECUTE,DataOut_EXECUTE,WriteData_EXECUTE,ALUOut_EXECUTE}), 
   						   .clk(clk), .rst(rst));
   	
   	// execute-memory control flip flop
   	dff XM_CTRL_FF [7:0] (.q(ControlSignals_MEMORY), .d(ControlSignals_EXECUTE[26:19]), .clk(clk), .rst(rst));
   		
   	// memory module
	memory MEMORY(.clk(clk), .rst(rst), .ALUOut(ALUOut_MEMORY), .WriteData(WriteData_MEMORY),	// memory data inputs
   		.MemWrite(ControlSignals_MEMORY[2]), .Enable(ControlSignals_MEMORY[0]), .Dump(ControlSignals_MEMORY[1]), 										// memory control inputs
   		.MemOut(MemOut_MEMORY));																// memory outputs
   		
   	// memory-writeback data flip flop	
   	dff MW_DATA_FF [47:0] (.q({PCplus2_WB,MemOut_WB,DataOut_WB}), 
   						   .d({PCplus2_MEMORY,MemOut_MEMORY,DataOut_MEMORY}), 
   						   .clk(clk), .rst(rst));
   	
   	// memory-writeback control flip flop	
   	dff MW_CTRL_FF [4:0] (.q(ControlSignals_WB), .d(ControlSignals_MEMORY[7:3]), .clk(clk), .rst(rst));
   	
   	// writeback module
	wb WRITEBACK(.clk(clk), .rst(rst), .DataOut(DataOut_WB), .MemOut(MemOut_WB), .PCplus2(PCplus2_WB), 	// wb data inputs
   		.MemtoReg(ControlSignals_WB[0]), .AdrLink(ControlSignals_WB[4]), 														// wb control inputs
   		.RegData(RegData));																				// wb outputs
   				
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
