/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (clk, sysclk, rst, ALUOut, WriteData, Enable, Dump, MemToReg, MemWrite, MemOut, stall, mem_stall, mem_done);

//////////////
// SIGNALS //
////////////

      // clk/rst
      input clk, rst, sysclk;

      // data inputs
      input [15:0] ALUOut, WriteData; // from execute

      // control inputs
      input MemToReg, Enable, Dump, MemWrite;

      // data outputs
      output [15:0] MemOut; // to wb
      output stall;
      output mem_stall, mem_done;
      
      wire err;
      wire [3:0] busy;
   
//////////////
// MODULES //
////////////

      //mem_system DMEM(.data_out(MemOut), .data_in(WriteData), .addr(ALUOut), .enable(Enable), .wr(MemWrite), .createdump(Dump), .clk(sysclk), .rst(rst));

      mem_system DMEM(.DataOut(MemOut), .Done(mem_done), .Stall(mem_stall), .CacheHit(), .err(),
                        .DataIn(WriteData), .Addr(ALUOut), .Rd(Enable & ~MemWrite), .Wr(Enable & MemWrite), .createdump(Dump), .clk(clk), .rst(rst));
      //four_bank_mem DRAM(.clk(sysclk), .rst(rst), .createdump(Dump), .addr(ALUOut), .data_in(WriteData), .wr(MemWrite), .rd(MemToReg), .data_out(MemOut), .stall(stall), .busy(busy), .err(err));
   
endmodule
