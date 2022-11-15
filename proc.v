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
   

   //////////////////
   // I/O SIGNALS //
   ////////////////
   /* Instantiations of intermediary wires */

	wire [15:0] JBAdr;
	wire [15:0] instr_FETCH, instr_DECODE, instr_EXECUTE, instr_MEMORY, instr_WB;
	wire [15:0] instr_DECODE_temp, instr_EXECUTE_temp, instr_MEMORY_temp, instr_WB_temp;
	wire [15:0] instr_IN; // Choice between normal instr and stall (nop)
	wire [15:0] PCplus2_FETCH, PCplus2_DECODE, PCplus2_EXECUTE, PCplus2_MEMORY, PCplus2_WB;
	wire [15:0] RegData_WB;
	wire [15:0] Reg1_DECODE, Reg2_DECODE, Reg1_EXECUTE, Reg2_EXECUTE;
	wire [15:0] JumpOffset_DECODE, JumpOffset_EXECUTE;
	wire [7:0]  instr_imm_DECODE, instr_imm_EXECUTE;
	wire [15:0] ALUOut_EXECUTE, ALUOut_MEMORY; 
	wire [15:0] DataOut_EXECUTE, DataOut_MEMORY, DataOut_WB;
	wire [15:0] WriteData_EXECUTE, WriteData_MEMORY;
	wire [15:0] MemOut_MEMORY, MemOut_WB;

	//////////////////////
	// CONTROL SIGNALS //
	////////////////////
	/* Instatiations of control wires */

	wire [4:0]  Control;
	wire [26:0] ControlSignals_DECODE, ControlSignals_EXECUTE, ControlSignals_MEMORY, ControlSignals_WB;

	wire Stall;
	wire Halt;
	wire BrJmpTaken;

	wire [15:0] fill, fillplus1, newfill;
	wire dummy;

	cla_16b FILL(.sum(fillplus1), .c_out(dummy), .a(fill), .b(16'h0001), .c_in(1'b0));
	assign newfill = (fill == 16'h0004 ? fill : fillplus1);
	dff WAIT [15:0] (.q(fill), .d(newfill), .clk(clk), .rst(rst));
	
	
	//////////////////////////////
	// CONTROL SIGNAL PIPELINE //
	////////////////////////////
	/* Contains Control Block which generates control signals and latches for control signals */

	// Control Block
	control CONTROL(.clk(clk), .rst(rst), .Control(Control), .ALUControl(instr_imm_DECODE[1:0]), .ControlSignals(ControlSignals_DECODE));

	// Decode/Execute
	dff DX_FF [26:0] (.q({ControlSignals_EXECUTE}), .d({ControlSignals_DECODE}), .clk(clk), .rst(rst | BrJmpTaken));
	// Execute/Memory
	dff XM_FF [26:0] (.q({ControlSignals_MEMORY}), .d({ControlSignals_EXECUTE}), .clk(clk), .rst(rst));
	// Memory/Write-Back
	dff MW_FF [26:0] (.q({ControlSignals_WB}), .d({ControlSignals_MEMORY}), .clk(clk), .rst(rst));
	

	///////////////////////////
	// DATA SIGNAL PIPELINE //
	/////////////////////////
	/* Contains latches for data signals */

	// Fetch/Decode	
	dff FD_FF [31:0] (.q({PCplus2_DECODE,instr_DECODE_temp}), .d({PCplus2_FETCH,instr_IN}), .clk(clk), .rst(rst | BrJmpTaken));
	// Decode/Execute
   	dff DX_DATA_FF [71:0] (.q({instr_imm_EXECUTE,JumpOffset_EXECUTE,PCplus2_EXECUTE,Reg2_EXECUTE,Reg1_EXECUTE}), 
   						   .d({instr_imm_DECODE,JumpOffset_DECODE,PCplus2_DECODE,Reg2_DECODE,Reg1_DECODE}), 
   						   .clk(clk), .rst(rst | BrJmpTaken));
   	// Execute/Memory
   	dff XM_DATA_FF [63:0] (.q({PCplus2_MEMORY,DataOut_MEMORY,WriteData_MEMORY,ALUOut_MEMORY}), 
   						   .d({PCplus2_EXECUTE,DataOut_EXECUTE,WriteData_EXECUTE,ALUOut_EXECUTE}), 
   						   .clk(clk), .rst(rst));   		
   	// Memory/Writeback	
   	dff MW_DATA_FF [47:0] (.q({PCplus2_WB,MemOut_WB,DataOut_WB}), 
   						   .d({PCplus2_MEMORY,MemOut_MEMORY,DataOut_MEMORY}), 
   						   .clk(clk), .rst(rst));


   	////////////////////////////
   	// INSTRUCTION PIPELINE  //
   	//////////////////////////
	/* Contains "latches" for instructions */

   	// Fetch/Decode
   	dff FD_Inst [15:0] (.q(instr_DECODE), .d((rst | BrJmpTaken) ? (16'h0800) : (instr_IN)), .clk(clk), .rst(1'b0));
   	// Decode/Execute
   	dff DX_Inst [15:0] (.q(instr_EXECUTE), .d((rst | BrJmpTaken) ? (16'h0800) : (instr_DECODE)), .clk(clk), .rst(1'b0));   	
   	// Execute/Memory
   	dff XM_Inst [15:0] (.q(instr_MEMORY), .d((rst) ? (16'h0800) : (instr_EXECUTE)), .clk(clk), .rst(1'b0));   	
   	// Memory/Writeback
   	dff MW_Inst [15:0] (.q(instr_WB), .d((rst) ? (16'h0800) : (instr_MEMORY)), .clk(clk), .rst(1'b0));
   	

	//////////////////////////////////
	// STAGE MODULE INSTANTIATIONS //
	////////////////////////////////
	/* Instantiation of the 5 stages of the pipeline */
	
	// Stall Block Module 
	/* Checks for dependencies and inserts NOPs as needed
	   Produces a stall command as well */
	stallBlock STALL(.clk(clk), .rst(rst), .inst_If(instr_FETCH), .inst_IfId(instr_DECODE), .inst_IdEx(instr_EXECUTE), 
	                 .inst_ExMem(instr_MEMORY), .inst_out(instr_IN), .stall(Stall));
   
    // Fetch
	fetch FETCH(.clk(clk), .rst(rst), .JBAdr(JBAdr), 																						// fetch data inputs
   		.PCVal(ControlSignals_EXECUTE[20]), .Enable(ControlSignals_DECODE[7]), .Dump(Dump_FETCH), .stall(Stall), .BrJmpTaken(BrJmpTaken),	// fetch control inputs
   		.instr(instr_FETCH), .PCplus2(PCplus2_FETCH)); 																						// fetch outputs
   	
   	// Decode
	decode DECODE(.clk(clk), .rst(rst), .instr(instr_DECODE), .instr_wb(instr_WB), .RegData(RegData_WB),	// decode data inputs
   		 .RegDst(ControlSignals_WB[3:2]), .RegWrite(ControlSignals_WB[1]), 									// decode control inputs
   		 .Reg1(Reg1_DECODE), .Reg2(Reg2_DECODE), 															// ^^^^^^^^^^^^^^^^^^^^^
   		 .JumpOffset(JumpOffset_DECODE), .instr_imm(instr_imm_DECODE), .Control(Control));					// decode outputs
   		    	
   	// Execute
	execute EXECUTE(.clk(clk), .rst(rst), .Reg1(Reg1_EXECUTE), .Reg2(Reg2_EXECUTE), .JumpOffset(JumpOffset_EXECUTE), 
		.PCplus2(PCplus2_EXECUTE), .instr_imm(instr_imm_EXECUTE), 																								// execute data inputs
   		.ExtMode(ControlSignals_EXECUTE[19]), .IType(ControlSignals_EXECUTE[18]), .Reg1Rev(ControlSignals_EXECUTE[17]), 
   		.Reg1Shift(ControlSignals_EXECUTE[16]), .Zero1(ControlSignals_EXECUTE[15]), .Zero2(ControlSignals_EXECUTE[14]), 
   		.ALUSrc(ControlSignals_EXECUTE[13]), .BrOp(ControlSignals_EXECUTE[23:21]), .Branch(ControlSignals_EXECUTE[12]), .JumpType(ControlSignals_EXECUTE[11]), 
   		.CompCarry(ControlSignals_EXECUTE[10]), .ALUComp(ControlSignals_EXECUTE[9]), .ALUOp(ControlSignals_EXECUTE[26:24]), 
   		.sign(ControlSignals_EXECUTE[8]), .PCVal(ControlSignals_EXECUTE[20]),																					// execute control inputs
   		.ALUOut(ALUOut_EXECUTE), .DataOut(DataOut_EXECUTE), .JBAdr(JBAdr), .WriteData(WriteData_EXECUTE), .BrJmpTaken(BrJmpTaken)); 							// execute outputs (JBAdr ties directly to fetch)
   		
   	// Memory
	memory MEMORY(.clk(clk), .rst(rst), .ALUOut(ALUOut_MEMORY), .WriteData(WriteData_MEMORY),						// memory data inputs
   		.MemWrite(ControlSignals_MEMORY[5]), .Enable(ControlSignals_MEMORY[7]), .Dump(ControlSignals_MEMORY[6]), 	// memory control inputs
   		.MemOut(MemOut_MEMORY)); // memory outputs	
   		
   	// Writeback
	wb WRITEBACK(.clk(clk), .rst(rst), .DataOut(DataOut_WB), .MemOut(MemOut_WB), .PCplus2(PCplus2_WB), 	// wb data inputs
   		.MemtoReg(ControlSignals_WB[4]), .AdrLink(ControlSignals_WB[0]), 								// wb control inputs
   		.RegData(RegData_WB));																			// wb outputs
   		
   	assign Halt = ~(|instr_WB[15:11]);
   	
   	dff WF_CTRL_FF (.q(Dump_FETCH), .d(Halt), .clk(clk), .rst(rst));		


   				
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
