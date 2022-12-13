// D-flipflop wrapper with enable

module dff_en (q, d, en, clk, rst);

    output         q;
    input          d;
	input		   en;
    input          clk;
    input          rst;

	wire temp;
	assign temp = (en ? d : q);
    dff FF(.q(q), .d(temp), .clk(clk), .rst(rst));

endmodule