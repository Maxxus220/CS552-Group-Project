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
		wire [15:0] Instr_FETCH, Instr_DECODE, Instr_EXECUTE, Instr_MEMORY, Instr_WB;
		wire [15:0] Instr_DECODE_temp, Instr_EXECUTE_temp, Instr_MEMORY_temp, Instr_WB_temp;
		wire [15:0] Instr_IN; // Choice between normal instr and stall (nop)
		wire [15:0] PCplus2_FETCH, PCplus2_DECODE, PCplus2_EXECUTE, PCplus2_MEMORY, PCplus2_WB;
		wire [15:0] RegData_WB;
		wire [15:0] Reg1_DECODE, Reg2_DECODE, Reg1_EXECUTE, Reg2_EXECUTE;
		wire [15:0] JumpOffset_DECODE, JumpOffset_EXECUTE;
		wire [7:0]  Instr_Imm_DECODE, Instr_Imm_EXECUTE;
		wire [15:0] ALUOut_EXECUTE, ALUOut_MEMORY; 
		wire [15:0] DataOut_EXECUTE, DataOut_MEMORY, DataOut_WB;
		wire [15:0] WriteData_EXECUTE, WriteData_MEMORY;
		wire [15:0] MemOut_MEMORY, MemOut_WB;
		wire MemDone_FETCH, MemStall_FETCH;

//////////////////////
// CONTROL SIGNALS //
////////////////////
/* Instatiations of control wires */

		wire [4:0]  Control;
		wire [26:0] ControlSignals_DECODE, ControlSignals_EXECUTE, ControlSignals_MEMORY, ControlSignals_WB;

		wire fetch_stall, mem_stall;
		wire sysclk1, sysclk2, sysclk;
		wire Halt;
		wire BrJmpTaken;
	

//////////////////////////////
// CONTROL SIGNAL PIPELINE //
////////////////////////////
/* Contains Control Block which generates control signals and latches for control signals */

		// Control Block
		control CONTROL(.clk(sysclk), .rst(rst), .Control(Control), .ALUControl(Instr_Imm_DECODE[1:0]), .ControlSignals(ControlSignals_DECODE));

		// Decode/Execute
		dff DX_FF [26:0] (.q({ControlSignals_EXECUTE}), .d({ControlSignals_DECODE}), .clk(sysclk), .rst(rst | BrJmpTaken));
		// Execute/Memory
		dff XM_FF [26:0] (.q({ControlSignals_MEMORY}), .d({ControlSignals_EXECUTE}), .clk(sysclk), .rst(rst));
		// Memory/Write-Back
		dff MW_FF [26:0] (.q({ControlSignals_WB}), .d({ControlSignals_MEMORY}), .clk(sysclk), .rst(rst));
	

///////////////////////////
// DATA SIGNAL PIPELINE //
/////////////////////////
/* Contains latches for data signals */

		// Fetch/Decode	
		dff FD_FF [31:0] (.q({PCplus2_DECODE,Instr_DECODE_temp}), .d({PCplus2_FETCH,Instr_IN}), .clk(sysclk), .rst(rst | BrJmpTaken));
		// Decode/Execute
		dff DX_DATA_FF [71:0] (.q({Instr_Imm_EXECUTE,JumpOffset_EXECUTE,PCplus2_EXECUTE,Reg2_EXECUTE,Reg1_EXECUTE}), 
							.d({Instr_Imm_DECODE,JumpOffset_DECODE,PCplus2_DECODE,Reg2_DECODE,Reg1_DECODE}), 
							.clk(sysclk), .rst(rst | BrJmpTaken));
		// Execute/Memory
		dff XM_DATA_FF [63:0] (.q({PCplus2_MEMORY,DataOut_MEMORY,WriteData_MEMORY,ALUOut_MEMORY}), 
							.d({PCplus2_EXECUTE,DataOut_EXECUTE,WriteData_EXECUTE,ALUOut_EXECUTE}), 
							.clk(sysclk), .rst(rst));   		
		// Memory/Writeback	
		dff MW_DATA_FF [47:0] (.q({PCplus2_WB,MemOut_WB,DataOut_WB}), 
							.d({PCplus2_MEMORY,MemOut_MEMORY,DataOut_MEMORY}), 
							.clk(sysclk), .rst(rst));


////////////////////////////
// INSTRUCTION PIPELINE  //
//////////////////////////
/* Contains "latches" for instructions */

		// Fetch/Decode
		dff FD_Inst [15:0] (.q(Instr_DECODE), .d((rst | BrJmpTaken) ? (16'h0800) : (Instr_IN)), .clk(sysclk), .rst(1'b0));
		// Decode/Execute
		dff DX_Inst [15:0] (.q(Instr_EXECUTE), .d((rst | BrJmpTaken) ? (16'h0800) : (Instr_DECODE)), .clk(sysclk), .rst(1'b0));   	
		// Execute/Memory
		dff XM_Inst [15:0] (.q(Instr_MEMORY), .d((rst) ? (16'h0800) : (Instr_EXECUTE)), .clk(sysclk), .rst(1'b0));   	
		// Memory/Writeback
		dff MW_Inst [15:0] (.q(Instr_WB), .d((rst) ? (16'h0800) : (Instr_MEMORY)), .clk(sysclk), .rst(1'b0));
   	

//////////////////////////////////
// STAGE MODULE INSTANTIATIONS //
////////////////////////////////
/* Instantiation of the 5 stages of the pipeline */
	
		// Stall Block Module 
		/* Checks for dependencies and inserts NOPs as needed
		Produces a stall command as well */
		stallBlock STALL(
			.clk(sysclk), .rst(rst), 
			.inst_If(Instr_FETCH), .inst_IfId(Instr_DECODE), .inst_IdEx(Instr_EXECUTE), 
			.inst_ExMem(Instr_MEMORY), .inst_out(Instr_IN), .stall(Stall)
		);
	
		// Fetch
		fetch FETCH(
			.clk(clk), .rst(rst), .sysclk(sysclk),
			.JBAdr(JBAdr), 																					// fetch data inputs
			.Enable(ControlSignals_DECODE[7]), .Dump(Halt), .stall(Stall), .BrJmpTaken(BrJmpTaken),			// fetch control inputs
			.instr(Instr_FETCH), .PCplus2(PCplus2_FETCH),													// fetch outputs
			.mem_stall(MemStall_FETCH), .mem_done(MemDone_FETCH)											// ^^^^^^^^^^^^^
		); 													
		
		// Decode
		decode DECODE(
			.sysclk(sysclk), .rst(rst), 
			.instr(Instr_DECODE), .instr_wb(Instr_WB), .RegData(RegData_WB),								// decode data inputs
			.RegDst(ControlSignals_WB[3:2]), .RegWrite(ControlSignals_WB[1]), 								// decode control inputs
			.Reg1(Reg1_DECODE), .Reg2(Reg2_DECODE), 														// decode outputs
			.JumpOffset(JumpOffset_DECODE), .Instr_Imm(Instr_Imm_DECODE), .Control(Control)					// ^^^^^^^^^^^^^^
		);					
					
		// Execute
		execute EXECUTE(
			.sysclk(sysclk), .rst(rst), 
			.Reg1(Reg1_EXECUTE), .Reg2(Reg2_EXECUTE), .JumpOffset(JumpOffset_EXECUTE), 						// execute data inputs
			.PCplus2(PCplus2_EXECUTE), .Instr_Imm(Instr_Imm_EXECUTE), 										// ^^^^^^^^^^^^^^^^^^^
			.ExtMode(ControlSignals_EXECUTE[19]), .IType(ControlSignals_EXECUTE[18]),						// execute control inputs 
			.Reg1Rev(ControlSignals_EXECUTE[17]), .Reg1Shift(ControlSignals_EXECUTE[16]), 					// ^^^^^^^^^^^^^^^^^^^^^^
			.Zero1(ControlSignals_EXECUTE[15]), .Zero2(ControlSignals_EXECUTE[14]), 						// ^^^^^^^^^^^^^^^^^^^^^^
			.ALUSrc(ControlSignals_EXECUTE[13]), .BrOp(ControlSignals_EXECUTE[23:21]), 						// ^^^^^^^^^^^^^^^^^^^^^^
			.Branch(ControlSignals_EXECUTE[12]), .JumpType(ControlSignals_EXECUTE[11]), 					// ^^^^^^^^^^^^^^^^^^^^^^
			.CompCarry(ControlSignals_EXECUTE[10]), .ALUComp(ControlSignals_EXECUTE[9]), 					// ^^^^^^^^^^^^^^^^^^^^^^
			.ALUOp(ControlSignals_EXECUTE[26:24]), .sign(ControlSignals_EXECUTE[8]), 						// ^^^^^^^^^^^^^^^^^^^^^^
			.BrOrJmp(ControlSignals_EXECUTE[20]),															// ^^^^^^^^^^^^^^^^^^^^^^
			.ALUOut(ALUOut_EXECUTE), .DataOut(DataOut_EXECUTE), .JBAdr(JBAdr), 								// execute outputs (JBAdr ties directly to fetch)
			.WriteData(WriteData_EXECUTE), .BrJmpTaken(BrJmpTaken)											// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		); 							
			
		// Memory
		memory MEMORY(
			.clk(clk), .sysclk(sysclk), .rst(rst), .ALUOut(ALUOut_MEMORY), .WriteData(WriteData_MEMORY),					// memory data inputs
			.MemToReg(ControlSignals_MEMORY[4]), .MemWrite(ControlSignals_MEMORY[5]), 						// memory control inputs
			.Enable(ControlSignals_MEMORY[7]), .Dump(ControlSignals_MEMORY[6]), 							// ^^^^^^^^^^^^^^^^^^^^^
			.MemOut(MemOut_MEMORY), .stall(mem_stall)														// memory outputs	
		); 																									
			
		// Writeback
		wb WRITEBACK(
			.sysclk(sysclk), .rst(rst), .DataOut(DataOut_WB), .MemOut(MemOut_WB), .PCplus2(PCplus2_WB), 		// wb data inputs
			.MemtoReg(ControlSignals_WB[4]), .AdrLink(ControlSignals_WB[0]), 								// wb control inputs
			.RegData(RegData_WB)																			// wb outputs
		);																			
		
		// Assign whether the program should propogate halts
		dff WF_CTRL_FF (.q(Halt), .d((~(|Instr_WB[15:11]))), .clk(sysclk), .rst(rst));
		
		// Assign the system clock signal
		// Utilize memWrite and MemToReg to determine memory operations
		assign sysclk = (rst ? clk : (MemDone_FETCH));

   				
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
