/*
    CS/ECE 552 FALL '22
    Project Demo 1

    A multi-bit ALU module (defaults to 16-bit). It is designed to choose
    the correct operation to perform on 2 multi-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the multi-bit result
    of the operation, as well as drive the output signals Zero and Overflow
    (OFL).
    
    This module has been lifted from HW2 without adjustment.
*/
module alu (InA, InB, Cin, Oper, invA, invB, sign, Out, Zero, Ofl);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 3;
       
    input  [OPERAND_WIDTH -1:0] InA ; // Input operand A
    input  [OPERAND_WIDTH -1:0] InB ; // Input operand B
    input                       Cin ; // Carry in
    input  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input                       invA; // Signal to invert A
    input                       invB; // Signal to invert B
    input                       sign; // Signal for signed operation
    output reg [OPERAND_WIDTH -1:0] Out ; // Result of computation
    output                      Ofl ; // Signal if overflow occured
    output reg                  Zero; // Signal if Out is 0

    /* YOUR CODE HERE */
    
    wire [OPERAND_WIDTH -1:0] A, B, A_n, B_n, shift_out, cla_out, and_n, or_n, and_out, or_out, xor_out; // main I/O wires
    wire Cout, ofl_med, ofl_out, ofl_med_n, xor_out_n, s_n; // overflow flag wires
    wire shift_red, cla_red, cla_rn, and_red, or_red, xor_red; // reduction wires
    wire shift_z, cla_z, and_z, or_z, xor_z; // zero flag wires
    
    // generate inverted input signals 
    not1 NOTA [OPERAND_WIDTH -1:0] (.out(A_n), .in1(InA));
    not1 NOTB [OPERAND_WIDTH -1:0] (.out(B_n), .in1(InB));
    
    // determine if one or both inputs will be inverted
    assign A = (invA ? A_n : InA);
    assign B = (invB ? B_n : InB);
    
    // generate outputs
    shifter SHIFT(.In(A), .ShAmt(B[3:0]), .Oper(Oper[NUM_OPERATIONS - 2:0]), .Out(shift_out));
    cla_16b CLA(.sum(cla_out), .c_out(Cout), .a(A), .b(B), .c_in(Cin));
    
    nand2 ANDAB0 [OPERAND_WIDTH -1:0] (.out(and_n), .in1(A), .in2(B));
    not1  ANDAB1 [OPERAND_WIDTH -1:0] (.out(and_out), .in1(and_n));
    
    nor2 ORAB0 [OPERAND_WIDTH -1:0] (.out(or_n), .in1(A), .in2(B));
    not1 ORAB1 [OPERAND_WIDTH -1:0] (.out(or_out), .in1(or_n));
    
    xor2 XORAB [OPERAND_WIDTH -1:0] (.out(xor_out), .in1(A), .in2(B));
    
    // generate reductions (used for Zero flag)
    
    assign shift_red = |shift_out;
    assign cla_red = |cla_out;
    assign and_red = |and_out;
    assign or_red = |or_out;
    assign xor_red = |xor_out;
    
    nor2 CLAZ(.out(cla_z), .in1(cla_red), .in2(Cout)); 
    
    not1 SHIFTZ(.out(shift_z), .in1(shift_red));
    not1 ANDZ(.out(and_z), .in1(and_red));
    not1 ORZ(.out(or_z), .in1(or_red));
    not1 XORZ(.out(xor_z), .in1(xor_red));
    
    // calculate overflow flag
    
    not1  OFL0(.out(s_n), .in1(cla_out[OPERAND_WIDTH -1]));
    nand2 OFL1(.out(ofl_med_a), .in1(s_n), .in2(and_out[OPERAND_WIDTH -1]));
    nand2 OFL2(.out(ofl_med_n), .in1(cla_out[OPERAND_WIDTH -1]), .in2(or_n[OPERAND_WIDTH -1]));
    nand2 OFL3(.out(ofl_out), .in1(ofl_med_a), .in2(ofl_med_n));
    
    assign Ofl = (Oper == 3'b100 ? (sign ? ofl_out : Cout) : 1'b0);
    
    // choose final output signal and zero flag
    always @* case (Oper)
		3'b000, 3'b001, 3'b010, 3'b011: begin // shifter
			Out = shift_out;
			Zero = shift_z;
		end
		3'b100: begin // CLA
			Out = cla_out;
			Zero = ~(|Out);
		end	
		3'b101: begin // AND
			Out = and_out;
			Zero = and_z;
		end	
		3'b110: begin // OR
			Out = or_out;
			Zero = or_z;
		end	
		3'b111: begin // XOR
			Out = xor_out;
			Zero = xor_z;
		end	
		default: begin // ERROR
			Out = 16'h0000;
			Zero = 1'b0; // perhaps WISC-F22 can check for this descrepancy to see if there is a hardware error?
		end
    endcase
endmodule
