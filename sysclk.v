module sysclk(imem_done, dmem_done, sysclk, clk, rst);

reg imem_finished, dmem_finished;

input imem_done, dmem_done, clk, rst;
output sysclk;
assign sysclk = imem_finished & dmem_finished;


reg [1:0] state = 2'd0;

always @(posedge rst) begin
    state = 2'd0;
end

always @(posedge clk) begin
    case(state)
        // Reset
        2'd0: begin
            imem_finished = 1'd0;
            dmem_finished = 1'd0;
            state = (!(imem_done | dmem_done) ? 2'd0 : (imem_done ? 2'd1 : 2'd2));
        end

        // Imem Done
        2'd1: begin
            imem_finished = 1'd1;
            dmem_finished = 1'd0;
            state = (dmem_done ? 2'd3 : 2'd1);
        end

        // Dmem Done
        2'd2: begin
            imem_finished = 1'd0;
            dmem_finished = 1'd1;
            state = (dmem_done ? 2'd3 : 2'd2);
        end

        // Both Done
        2'd3: begin
            imem_finished = 1'd1;
            dmem_finished = 1'd1;
            state = 2'd0;

        end
    endcase
end


endmodule