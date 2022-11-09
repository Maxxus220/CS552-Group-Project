/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 1
    
    a 16-bit CLA module
*/
module cla_16b(sum, c_out, a, b, c_in);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    output [N-1:0] sum;
    output         c_out;
    input [N-1: 0] a, b;
    input          c_in;

    // run 4 instances of 4-bit CLA
    // note that 
    wire [2:0] carries;
    
	cla_4b CLA0(.sum(sum[3:0]), .c_out(carries[0]), .a(a[3:0]), .b(b[3:0]), .c_in(c_in));
	cla_4b CLA1(.sum(sum[7:4]), .c_out(carries[1]), .a(a[7:4]), .b(b[7:4]), .c_in(carries[0]));
	cla_4b CLA2(.sum(sum[11:8]), .c_out(carries[2]), .a(a[11:8]), .b(b[11:8]), .c_in(carries[1]));
	cla_4b CLA3(.sum(sum[15:12]), .c_out(c_out), .a(a[15:12]), .b(b[15:12]), .c_in(carries[2]));

endmodule
