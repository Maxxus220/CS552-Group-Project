// Helper module for checking if registers match 
module regCheck(
	input clk,
	input rst,
    input [2:0] reg1,
	input [2:0] reg2,
	output match
);
    assign match = (rst ? 1'b0 
    : ((reg1 === 3'bzzz | reg2 === 3'bzzz) ? 1'b0
    : (~(reg1[2] ^ reg2[2])) & (~(reg1[1] ^ reg2[1])) & (~(reg1[0] ^ reg2[0]))));
endmodule
