/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (clk, rst, ALUOut, WriteData, Enable, Dump, MemWrite, MemOut);

    // clk/rst
   input clk, rst;
   // data inputs
   input [15:0] ALUOut, WriteData; // from execute
   // control inputs
   input Enable, Dump, MemWrite;
   // data outputs
   output [15:0] MemOut; // to wb
   
   memory2c DMEM(.data_out(MemOut), .data_in(WriteData), .addr(ALUOut), .enable(Enable), .wr(MemWrite), .createdump(Dump), .clk(clk), .rst(rst));
   
endmodule
