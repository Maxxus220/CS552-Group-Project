module stallBlock_bench();

wire [15:0] fInst, dInst, eInst, mInst, outInst;
stallBlock STALLBLOCK(.inst_If(fInst), .inst_IfId(dInst), .inst_IdEx(eInst), .inst_ExMem(mInst), .inst_out(outInst));

initial begin
    $display("Stall Block Tests starting");
    $monitor("f: %h d: %h e: %h m: %h out: %h\n", fInst, dInst, eInst, mInst, outInst);
    fInst = 

end

endmodule