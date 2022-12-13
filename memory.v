/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (clk, rst, ALUOut, WriteData, Enable, Dump, MemToReg, MemWrite, MemOut, mem_stall, forward_out);

//////////////
// SIGNALS //
////////////

      // clk/rst
      input clk, rst;

      // data inputs
      input [15:0] ALUOut, WriteData; // from execute

      // control inputs
      input MemToReg, Enable, Dump, MemWrite;

      // data outputs
      output [15:0] MemOut; // to wb
      output mem_stall;
      output [15:0] forward_out;
      
      wire err;
      wire [3:0] busy;
   
//////////////
// MODULES //
////////////

      //memory2c DMEM(.data_out(MemOut), .data_in(WriteData), .addr(ALUOut), .enable(Enable), .wr(MemWrite), .createdump(Dump), .clk(clk), .rst(rst));

      mem_system IMEM (.DataOut(MemOut), .Done(), .Stall(mem_stall), .CacheHit(), .err(),
                        .DataIn(WriteData), .Addr(ALUOut), .Rd(Enable & ~MemWrite), .Wr(Enable & MemWrite), .createdump(Dump), .clk(clk), .rst(rst));
      
      assign forward_out = MemToReg ? MemOut : ALUOut;
      
   
endmodule
