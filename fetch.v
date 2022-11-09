/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (clk, rst, JBAdr, Enable, Dump, PCVal, instr, PCplus2);

   // clk/rst
   input clk, rst;
   // data inputs
   input [15:0] JBAdr; // from execute
   // control inputs
   input Enable, Dump, PCVal;
   // data outputs
   output [15:0] instr; // to decode
   output [15:0] PCplus2; // to execute and wb
   
   wire [15:0] PC;
   wire [15:0] NewPC; // final input to PC after all branches/jumps have been considered
   wire dummy; // dummy wire for adder c_out (unused)
   
   cla_16b ADD2(.sum(PCplus2), .c_out(dummy), .a(PC), .b(16'h0002), .c_in(1'b0));
   // Instruction memory is read-only and always enabled
   // TODO: tie enable signal to something else to do NOPs
   memory2c IMEM (.data_out(instr), .data_in(16'h0000), .addr(PC), .enable(Enable), .wr(1'b0), .createdump(Dump), .clk(clk), .rst(rst));
   mux16_2 MUX_PCVal(.out(NewPC), .in0(PCplus2), .in1(JBAdr), .sel(PCVal));
   reg16 PC_REG(.readData(PC), .writeData(NewPC), .clk(clk), .rst(rst)); 
   
endmodule
