/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (clk, rst, ALUOut, WriteData, Enable, Dump, MemToReg, MemWrite, MemOut, stall);

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
      output stall;
      
      wire err;
      wire [3:0] busy;
   
//////////////
// MODULES //
////////////

      // memory2c DMEM(.data_out(MemOut), .data_in(WriteData), .addr(ALUOut), .enable(Enable), .wr(MemWrite), .createdump(Dump), .clk(clk), .rst(rst));
      
      four_bank_mem DRAM(.clk(clk), .rst(rst), .createdump(Dump), .addr(ALUOut), .data_in(WriteData), .wr(MemWrite), .rd(MemToReg), .data_out(MemOut), .stall(stall), .busy(busy), .err(err));
   
endmodule
