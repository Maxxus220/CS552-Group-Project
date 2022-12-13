/*
Implements bypass from EX->EX (previous ex should be usable in next)
and MEM->EX (output of memory stage should be usable in next ex stage)

NOTE: If both ex->ex and mem->ex are detected take ex->ex
NOTE: Only one of the forwarding signals can be high or neither
*/

module forwarding_controller(
    input clk,
    input rst,
    input [15:0] ex_inst,
    input [15:0] mem_inst,
    input [15:0] wb_inst,

    output forward_rt,
    output forward_rs,
    output forward_rs_enabled,
    output forward_rt_enabled
);

////////////
// WIRES //
//////////

        wire
        mem_ex_matchRs,
        wb_ex_matchRs;

        wire
        mem_ex_matchRt,
        wb_ex_matchRt;


////////////////////////
// FORWARDING CHECKS //
//////////////////////

        forwarding_check MEM_EX(.clk(clk), .rst(rst), .inst1(ex_inst), .inst2(mem_inst), .matchRs(mem_ex_matchRs), .matchRt(mem_ex_matchRt));
        forwarding_check WB_EX(.clk(clk), .rst(rst), .inst1(ex_inst), .inst2(wb_inst), .matchRs(wb_ex_matchRs), .matchRt(wb_ex_matchRt));


///////////////////////
// FORWARDING LOGIC //
/////////////////////

        // If src's match forward earliest allowed
        // If src's are different forward both
        wire mem_is_forwarding_rs;
        wire mem_is_forwarding_rt;

        wire wb_is_forwarding_rs;
        wire wb_is_forwarding_rt;

        assign mem_is_forwarding_rs = (mem_ex_matchRs & (mem_inst[15:11] != 5'd17));
        assign mem_is_forwarding_rt = (mem_ex_matchRt & (mem_inst[15:11] != 5'd17));

        assign wb_is_forwarding_rs = (wb_ex_matchRs);
        assign wb_is_forwarding_rt = (wb_ex_matchRt);

        // If both are forwarding rs, rs will be forwarded from mem
        assign forward_rs = (mem_is_forwarding_rs & wb_is_forwarding_rs) ? 1'b0 : (mem_is_forwarding_rs ? 1'b0 : 1'b1);
        // If both are forwarding rt, rt will be forwarded from mem
        assign forward_rt = (mem_is_forwarding_rt & wb_is_forwarding_rt) ? 1'b0 : (mem_is_forwarding_rt ? 1'b0 : 1'b1);

        // If either forwards the register enable
        assign forward_rs_enabled = mem_is_forwarding_rs | wb_is_forwarding_rs;
        assign forward_rt_enabled = mem_is_forwarding_rt | wb_is_forwarding_rt;



endmodule