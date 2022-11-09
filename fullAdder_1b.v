/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 1
    
    a 1-bit full adder
*/
module fullAdder_1b(s, c_out, a, b, c_in);
    output s;
    output c_out;
    input  a, b;
    input  c_in;

    // YOUR CODE HERE
    wire ab, ac, bc;
    
    xor3 XOR_S(.out(s), .in1(a), .in2(b), .in3(c_in));
    
    nand2 NAND_AB(.out(ab), .in1(a), .in2(b));
	nand2 NAND_ACIN(.out(ac), .in1(a), .in2(c_in));
	nand2 NAND_BCIN(.out(bc), .in1(b), .in2(c_in));
	nand3 NOR_COUT(.out(c_out), .in1(ab), .in2(ac), .in3(bc));

endmodule
