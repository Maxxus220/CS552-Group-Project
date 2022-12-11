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

    output forward_rt,   // 0: forwards to rs  |  1: forwards to rt 
    output mem_ex_forward, // forward from ex->ex
    output wb_ex_forward // forward from mem->ex
);

////////////
// WIRES //
//////////

        wire
        mem_ex_check,
        wb_ex_check;

        wire
        mem_ex_src,
        wb_ex_src;


////////////////////////
// FORWARDING CHECKS //
//////////////////////

        forwarding_check MEM_EX(.clk(clk), .rst(rst), .inst1(ex_inst), .inst2(mem_inst), .forward(mem_ex_check), .src(mem_ex_src));
        forwarding_check WB_EX(.clk(clk), .rst(rst), .inst1(ex_inst), .inst2(wb_inst), .forward(wb_ex_check), .src(wb_ex_src));


///////////////////////
// FORWARDING LOGIC //
/////////////////////
        assign mem_ex_forward = mem_ex_check;
        assign wb_ex_forward = (mem_ex_check ? 1'b0 : wb_ex_check);
        assign forward_rt = (mem_ex_check ? mem_ex_src : wb_ex_src);



endmodule