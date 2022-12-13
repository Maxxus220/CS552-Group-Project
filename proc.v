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

//////////////////////
// CONTROL SIGNALS //
////////////////////
/* Instatiations of control wires */

		wire [4:0]  Control;
		wire [26:0] ControlSignals_DECODE, ControlSignals_EXECUTE, ControlSignals_MEMORY, ControlSignals_WB;

		wire Halt;
		wire BrJmpTaken;
		wire Stall;
		wire HaltInPipeline;
		assign HaltInPipeline = (
								(Instr_DECODE[15:11] == 5'd0) |
								(Instr_EXECUTE[15:11] == 5'd0) |
								(Instr_MEMORY[15:11] == 5'd0) |
								(Instr_WB[15:11] == 5'd0)
								) ? 1'b1 : 1'b0;

		wire MemStall_FETCH, MemStall_MEM;
		wire MemStall_BOTH;
		assign MemStall_BOTH = MemStall_FETCH | MemStall_MEM;


/////////////////////////
// FORWARDING SIGNALS //
///////////////////////

		wire [15:0] ForwardRS;
		wire [15:0] ForwardRT;
		wire [15:0] ForwardOut_MEM, ForwardOut_WB;
		wire Rs_FORWARD, Rt_FORWARD;
		wire Rs_Enabled_FORWARD, Rt_Enabled_FORWARD;
	

//////////////////////////////
// CONTROL SIGNAL PIPELINE //
////////////////////////////
/* Contains Control Block which generates control signals and latches for control signals */

		// Control Block
		control CONTROL(.clk(clk), .rst(rst), .Control(Control), .ALUControl(Instr_Imm_DECODE[1:0]), .ControlSignals(ControlSignals_DECODE));

		// Decode/Execute
		dff_en DX_FF [26:0] (.q({ControlSignals_EXECUTE}), .d({ControlSignals_DECODE}), .clk(clk), .rst(rst | (BrJmpTaken & ~MemStall_BOTH)), .en(~MemStall_BOTH));
		// Execute/Memory
		dff_en XM_FF [26:0] (.q({ControlSignals_MEMORY}), .d({ControlSignals_EXECUTE}), .clk(clk), .rst(rst), .en(~MemStall_BOTH));
		// Memory/Write-Back
		dff_en MW_FF [26:0] (.q({ControlSignals_WB}), .d({ControlSignals_MEMORY}), .clk(clk), .rst(rst), .en(~MemStall_BOTH));
	

///////////////////////////
// DATA SIGNAL PIPELINE //
/////////////////////////
/* Contains latches for data signals */

		// Fetch/Decode	
		dff_en FD_FF [15:0] (.q({PCplus2_DECODE}), .d({PCplus2_FETCH}), .clk(clk), .rst(rst | (BrJmpTaken & ~MemStall_BOTH)), .en(~MemStall_BOTH));
		// Decode/Execute
		dff_en DX_DATA_FF [71:0] (.q({Instr_Imm_EXECUTE,JumpOffset_EXECUTE,PCplus2_EXECUTE,Reg2_EXECUTE,Reg1_EXECUTE}), 
							.d({Instr_Imm_DECODE,JumpOffset_DECODE,PCplus2_DECODE,Reg2_DECODE,Reg1_DECODE}), 
							.clk(clk), .rst(rst | (BrJmpTaken & ~MemStall_BOTH)), .en(~MemStall_BOTH));
		// Execute/Memory
		dff_en XM_DATA_FF [63:0] (.q({PCplus2_MEMORY,DataOut_MEMORY,WriteData_MEMORY,ALUOut_MEMORY}), 
							.d({PCplus2_EXECUTE,DataOut_EXECUTE,WriteData_EXECUTE,ALUOut_EXECUTE}), 
							.clk(clk), .rst(rst), .en(~MemStall_BOTH));   		
		// Memory/Writeback	
		dff_en MW_DATA_FF [47:0] (.q({PCplus2_WB,MemOut_WB,DataOut_WB}), 
							.d({PCplus2_MEMORY,MemOut_MEMORY,DataOut_MEMORY}), 
							.clk(clk), .rst(rst), .en(~MemStall_BOTH));


////////////////////////////
// INSTRUCTION PIPELINE  //
//////////////////////////
/* Contains "latches" for instructions */

		// Fetch/Decode
		dff_en FD_Inst [15:0] (.q(Instr_DECODE), .d((rst | BrJmpTaken) ? (16'h0800) : (Instr_IN)), .clk(clk), .rst(1'b0), .en(~MemStall_BOTH));
		// Decode/Execute
		dff_en DX_Inst [15:0] (.q(Instr_EXECUTE), .d((rst | BrJmpTaken) ? (16'h0800) : (Instr_DECODE)), .clk(clk), .rst(1'b0), .en(~MemStall_BOTH));   	
		// Execute/Memory
		dff_en XM_Inst [15:0] (.q(Instr_MEMORY), .d((rst) ? (16'h0800) : (Instr_EXECUTE)), .clk(clk), .rst(1'b0), .en(~MemStall_BOTH));   	
		// Memory/Writeback
		dff_en MW_Inst [15:0] (.q(Instr_WB), .d((rst) ? (16'h0800) : (Instr_MEMORY)), .clk(clk), .rst(1'b0), .en(~MemStall_BOTH));
   	

//////////////////////////////////
// STAGE MODULE INSTANTIATIONS //
////////////////////////////////
/* Instantiation of the 5 stages of the pipeline */
	
		// Stall Block Module 
		/* Checks for dependencies and inserts NOPs as needed
		Produces a stall command as well */
		stallBlock STALL(
			.clk(clk), .rst(rst), 
			.inst_If(Instr_FETCH), .inst_IfId(Instr_DECODE), .inst_IdEx(Instr_EXECUTE), 
			.inst_ExMem(Instr_MEMORY), .inst_out(Instr_IN), .stall(Stall)
		);
	
		// Fetch
		fetch FETCH(
			.clk(clk), .rst(rst),
			.JBAdr(JBAdr), 																					// fetch data inputs
			.Dump(Halt), .stall(Stall), .BrJmpTaken(BrJmpTaken), .HaltInPipeline(HaltInPipeline),			// fetch control inputs
			.instr(Instr_FETCH), .PCplus2(PCplus2_FETCH),													// fetch outputs
			.mem_stall(MemStall_FETCH), .mem_done(MemDone_FETCH), .mem_stall_both(MemStall_BOTH)											// ^^^^^^^^^^^^^
		); 													
		
		// Decode
		decode DECODE(
			.clk(clk), .rst(rst), 
			.instr(Instr_DECODE), .instr_wb(Instr_WB), .RegData(RegData_WB),								// decode data inputs
			.RegDst(ControlSignals_WB[3:2]), .RegWrite(ControlSignals_WB[1]), 								// decode control inputs
			.Reg1(Reg1_DECODE), .Reg2(Reg2_DECODE), 														// decode outputs
			.JumpOffset(JumpOffset_DECODE), .Instr_Imm(Instr_Imm_DECODE), .Control(Control)					// ^^^^^^^^^^^^^^
		);					
					
		// Execute
		execute EXECUTE(
			.clk(clk), .rst(rst), 
			.Reg1(ForwardRS), .Reg2(ForwardRT), .JumpOffset(JumpOffset_EXECUTE), 						// execute data inputs
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
			.clk(clk), .rst(rst), .ALUOut(ALUOut_MEMORY), .WriteData(WriteData_MEMORY),					// memory data inputs
			.MemToReg(ControlSignals_MEMORY[4]), .MemWrite(ControlSignals_MEMORY[5]), 					// memory control inputs
			.Enable(ControlSignals_MEMORY[7]), .Dump(ControlSignals_MEMORY[6]), 						// ^^^^^^^^^^^^^^^^^^^^^
			.MemOut(MemOut_MEMORY), .EXDataOut(DataOut_MEMORY), .mem_stall(MemStall_MEM), 
			.forward_out(ForwardOut_MEM)																// memory outputs	
		); 																									
			
		// Writeback
		wb WRITEBACK(
			.clk(clk), .rst(rst), .DataOut(DataOut_WB), .MemOut(MemOut_WB), .PCplus2(PCplus2_WB), 	// wb data inputs
			.MemtoReg(ControlSignals_WB[4]), .AdrLink(ControlSignals_WB[0]), 						// wb control inputs
			.RegData(RegData_WB), .forward_out(ForwardOut_WB)										// wb outputs
		);																			
		
		// Assign whether the program should propogate halts
		dff_en WF_CTRL_FF (.q(Halt), .d((~(|Instr_WB[15:11]))), .clk(clk), .rst(rst), .en(~MemStall_BOTH));


/////////////////
// FORWARDING //
///////////////

		forwarding_controller FORWARD(
			.clk(clk),
			.rst(rst),
			.ex_inst(Instr_EXECUTE),
			.mem_inst(Instr_MEMORY),
			.wb_inst(Instr_WB),

			// rt and rs tell us where to forward from (0 means forward that reg from mem | 1 means forward that reg from wb)
			.forward_rt(Rt_FORWARD),
			.forward_rs(Rs_FORWARD),   
			// the corresponding enabled signals tell us whether we should forward in the first place
			.forward_rt_enabled(Rt_Enabled_FORWARD), 
			.forward_rs_enabled(Rs_Enabled_FORWARD) 
		);

		// Values that are passed into the execute stage
		// If forwarding occurs for that register the forwarded value is passed instead of the default
		assign ForwardRS = (Rs_Enabled_FORWARD ? (Rs_FORWARD ? ForwardOut_WB : ForwardOut_MEM) : Reg1_EXECUTE);
		assign ForwardRT = (Rt_Enabled_FORWARD ? (Rt_FORWARD ? ForwardOut_WB : ForwardOut_MEM) : Reg2_EXECUTE);

   				
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
