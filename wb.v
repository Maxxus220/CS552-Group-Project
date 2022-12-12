/*
   CS/ECE 552 Spring '20
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb (sysclk, rst, DataOut, MemOut, PCplus2, MemtoReg, AdrLink, RegData);

//////////////
// SIGNALS //
////////////

      // sysclk/rst
      input sysclk, rst;

      // data inputs
      input [15:0] DataOut; // from execute 
      input [15:0] MemOut; // from memory
      input [15:0] PCplus2; // from fetch

      // control inputs
      input MemtoReg, AdrLink;

      // data outputs
      output [15:0] RegData; // to decode
      
      wire [15:0] RegIn;
   

//////////////
// MODULES //
////////////

      mux16_2 MUX_MemtoReg(.out(RegIn), .in0(DataOut), .in1(MemOut), .sel(MemtoReg));
      mux16_2 MUX_AdrLink(.out(RegData), .in0(RegIn), .in1(PCplus2), .sel(AdrLink));
   
endmodule
