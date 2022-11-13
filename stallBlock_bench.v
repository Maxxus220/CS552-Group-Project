module stallBlock_bench();

reg [15:0] fInst;
reg [15:0] dInst;
reg [15:0] eInst; 
reg [15:0] mInst; 
reg [15:0] outInst;
stallBlock STALLBLOCK(.inst_If(fInst), .inst_IfId(dInst), .inst_IdEx(eInst), .inst_ExMem(mInst), .inst_out(outInst));

initial begin
    $display("Stall Block Tests starting");
    $monitor("f: %h d: %h e: %h m: %h out: %h\n", fInst, dInst, eInst, mInst, outInst);
    fInst = 16'hda2c;
    dInst = 16'hdb28;
    eInst = 16'h0800;
    mInst = 16'h0800;

end

endmodule