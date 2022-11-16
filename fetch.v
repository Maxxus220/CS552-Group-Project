/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (clk, rst, JBAdr, Enable, Dump, stall, instr, PCplus2, BrJmpTaken);

   // clk/rst
   input clk, rst;
   // data inputs
   input [15:0] JBAdr; // from execute
   //input BrEn;
   // control inputs
   input Enable, Dump, stall, BrJmpTaken;
   // data outputs
   output [15:0] instr; // to decode
   output [15:0] PCplus2; // to execute and wb
   
   wire [15:0] PC, newPC;
   wire [15:0] instr_fetch;
   wire dummy; // dummy wire for adder c_out (unused)
   
   
   // Memory Block
   // takes and address of PC which can come from either the jump address or the PC+2
   // Instruction memory is read-only and always enabled
   memory2c IMEM (.data_out(instr_fetch), .data_in(16'h0000), .addr(PC), .enable(1'b1), .wr(1'b0), .createdump(Dump), .clk(clk), .rst(rst));
   
   // PC storage
   // Devlop PCplus2 signal
   cla_16b ADD2(.sum(PCplus2), .c_out(dummy), .a(PC), .b(16'h0002), .c_in(1'b0));
   // Develop what the new PC value should be
   assign newPC = (BrJmpTaken) ? (JBAdr) : ((stall) ? (PC) : (PCplus2));
   // Store  new PC value
   reg16 PC_REG(.readData(PC), .writeData(newPC), .clk(clk), .rst(rst));
   
   assign instr = (Dump) ? (16'h0000) : (instr_fetch);
   
endmodule
