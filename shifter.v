/*
    CS/ECE 552 FALL '22
    Project Demo 1
    
    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, rotate right, or shift right logical based
    on the 'Oper' value that is passed in.  It uses these
    shifts to shift the value any number of bits.
    
    This module was lifted from HW2, but the arithmetic shift right is not used in WISC22.
    Its functionality has been replaced with rotate right, which the WISC22 does support.
 */
module shifter (In, ShAmt, Oper, Out);

  	 // declare constant for size of inputs, outputs, and # bits to shift
	parameter OPERAND_WIDTH = 16;
    parameter SHAMT_WIDTH   =  4;
    parameter NUM_OPERATIONS = 2;

    input  [OPERAND_WIDTH -1:0] In   ; // Input operand
    input  [SHAMT_WIDTH   -1:0] ShAmt; // Amount to shift/rotate
    input  [NUM_OPERATIONS-1:0] Oper ; // Operation type
    output reg [OPERAND_WIDTH -1:0] Out  ; // Result of shift/rotate

	/* YOUR CODE HERE */
   
	reg [OPERAND_WIDTH - 1:0] Mid1, Mid2, Mid4; // outputs from 1, 2, and 4 bit shifter
   
	always @* case (Oper)
		2'b00: begin // rotate left
			Mid1 = (ShAmt[0] == 1 ? {In[14:0],In[15]} : In); // 1 bit left rotate
			Mid2 = (ShAmt[1] == 1 ? {Mid1[13:0],Mid1[15:14]} : Mid1); // 2 bit left rotate
			Mid4 = (ShAmt[2] == 1 ? {Mid2[11:0],Mid2[15:12]} : Mid2); // 4 bit left rotate
			Out  = (ShAmt[3] == 1 ? {Mid4[7:0],Mid4[15:8]} : Mid4); // 8 bit left rotate
		end
		2'b01: begin // shift left
			Mid1 = (ShAmt[0] == 1 ? {In[14:0],1'b0} : In); // 1 bit
			Mid2 = (ShAmt[1] == 1 ? {Mid1[13:0],2'b00} : Mid1); // 2 bit
			Mid4 = (ShAmt[2] == 1 ? {Mid2[11:0],4'h0} : Mid2); // 4 bit
			Out  = (ShAmt[3] == 1 ? {Mid4[7:0],8'h00} : Mid4); // 8 bit
		end
		2'b10: begin // rotate right
			Mid1 = (ShAmt[0] == 1 ? {In[0],In[15:1]} : In); // 1 bit
			Mid2 = (ShAmt[1] == 1 ? {Mid1[1:0],Mid1[15:2]} : Mid1); // 2 bit
			Mid4 = (ShAmt[2] == 1 ? {Mid2[3:0],Mid2[15:4]} : Mid2); // 4 bit 
			Out  = (ShAmt[3] == 1 ? {Mid4[7:0],Mid4[15:8]} : Mid4); // 8 bit
		end
		2'b11: begin // logical shift right
			Mid1 = (ShAmt[0] == 1 ? {1'b0,In[15:1]} : In); // 1 bit
			Mid2 = (ShAmt[1] == 1 ? {2'b00,Mid1[15:2]} : Mid1); // 2 bit
			Mid4 = (ShAmt[2] == 1 ? {4'h0,Mid2[15:4]} : Mid2); // 4 bit 
			Out  = (ShAmt[3] == 1 ? {8'h00,Mid4[15:8]} : Mid4); // 8 bit
		end
		default: begin // ERROR: do not shift
			Out = In;
		end		
	endcase
endmodule
