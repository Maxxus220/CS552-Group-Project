/*
    CS/ECE 552 FALL'22
    Homework #2, Problem 1
    
    a 4-bit CLA module
*/
module cla_4b(sum, c_out, a, b, c_in);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    output [N-1:0] sum;
    output         c_out;
    input [N-1:0] a, b;
    input          c_in;

    // various wires
    wire [N-1:0] g, g_n, p, carryouts, nandouts; // carryouts is an array of dummy wires
    wire [N-2:0] carryins; 
    
    // calculate g[n] and p[n]
    nand2 NANDG [N-1:0] (.out(g_n), .in1(a), .in2(b));
    not1 NOTG [N-1:0] (.out(g), .in1(g_n));
    xor2 XORP [N-1:0] (.out(p), .in1(a), .in2(b));
    
    // calculate all carry ins, as well as the master g signal
    nand2 ANDN0 (.out(nandouts[0]), .in1(c_in), .in2(p[0]));
    nand2 ORN0 (.out(carryins[0]), .in1(nandouts[0]), .in2(g_n[0]));
    nand2 ANDN1 (.out(nandouts[1]), .in1(carryins[0]), .in2(p[1]));
    nand2 ORN1 (.out(carryins[1]), .in1(nandouts[1]), .in2(g_n[1]));
    nand2 ANDN2 (.out(nandouts[2]), .in1(carryins[1]), .in2(p[2]));
    nand2 ORN2 (.out(carryins[2]), .in1(nandouts[2]), .in2(g_n[2]));
	nand2 ANDN3 (.out(nandouts[3]), .in1(carryins[2]), .in2(p[3]));
    nand2 ORN3 (.out(c_out), .in1(nandouts[3]), .in2(g_n[3]));
    
    // use fullAdder_1b to calculate s values
    fullAdder_1b BIT0 [N-1:0] (.s(sum), .c_out(carryouts), .a(a), .b(b), .c_in({carryins, c_in}));
    
endmodule
