/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (clk, rst, JBAdr, Dump, stall, instr, PCplus2, BrJmpTaken, mem_stall, mem_done, mem_stall_both);

//////////////
// SIGNALS //
////////////

      // clk/rst
      input clk, rst;

      // data inputs
      input [15:0] JBAdr; // from execute

      // control inputs
      input Dump, stall, BrJmpTaken;

      input mem_stall_both;

      // data outputs
      output [15:0] instr; // to decode
      output [15:0] PCplus2; // to execute and wb
      output mem_stall; // Stall from imem
      output mem_done; //Done from imem
      
      // wires
      wire [15:0] PC, newPC;
      wire [15:0] instr_fetch;
      wire dummy; // dummy wire for adder c_out (unused)


//////////////
// MODULES //
////////////

      // Memory Block
      /* Takes a PC address which can come from either the jump/branch or PC+2
         Instruction memory is read-only and always enabled */
      mem_system IMEM (.DataOut(instr_fetch), .Done(mem_done), .Stall(mem_stall), .CacheHit(), .err(),
                        .DataIn(16'h0000), .Addr(PC), .Rd(1'b1), .Wr(1'b0), .createdump(Dump), .clk(clk), .rst(rst));
      
      // Generates PC+2
      cla_16b ADD2(.sum(PCplus2), .c_out(dummy), .a(PC), .b(16'h0002), .c_in(1'b0));

      // Choose new PC
      assign newPC = (BrJmpTaken) ? (JBAdr) : ((stall) ? (PC) : (PCplus2));

      // Store new PC
      dff_en PC_REG [15:0] (.q(PC), .d(newPC), .clk(clk), .rst(rst), .en(~mem_stall_both));
      
      assign instr = (Dump) ? (16'h0000) : (instr_fetch);
   
endmodule
