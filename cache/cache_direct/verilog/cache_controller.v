module cache_controller(
    rd, wr, hit, dirty, valid, busy, offset,                // Inputs
    enable, comp, write, mem_wr, mem_rd, valid_in, done     // Outputs
    clk, rst);                                              // Clk & Rst

////////////
// PORTS //
//////////
        input rd, wr, hit, dirty, valid;
        input [3:0] busy;
        input [2:0] offset;

        input clk, rst;

        output enable, comp, write, mem_wr, mem_rd, valid_in, done;

////////////
// WIRES //
//////////
        wire [2:0] cur_state;
        wire [2:0] next_state;

////////////
// STATE //
//////////
/*  
Wait         = 0
CompR        = 1
AccessW      = 2
CompW        = 3
Cache+Direct = 4
DirectMem    = 5
*/
        dff STATE [2:0] (.q(cur_state), .d(next_state), .clk(clk), .rst(rst));

////////////////////
// STATE MACHINE //
//////////////////
/*
Each state should begin with its outputs
then continue with transition logic
to set next_state
*/
        always @(posedge clk) begin
            case (cur_state)

                // WAIT
                0: begin
                    assign enable = 1'b0;
                    assign comp = 1'b0;
                    assign write = 1'b0;
                    assign mem_wr = 1'b0;
                    assign mem_rd = 1'b0;
                    assign valid_in = 1'b0;
                    assign done = 1'b0;

                    assign next_state = ((rd | wr) ? (rd ? 1 : 3) : (0));
                end
                
                // COMP_R
                1: begin
                    assign enable = 1'b0;
                    assign comp = 1'b0;
                    assign write = 1'b0;
                    assign mem_wr = 1'b0;
                    assign mem_rd = 1'b0;
                    assign valid_in = 1'b0;
                    assign done = 1'b0;


                end

                // ACCESS_W
                2: begin
                    assign enable = 1'b0;
                    assign comp = 1'b0;
                    assign write = 1'b0;
                    assign mem_wr = 1'b0;
                    assign mem_rd = 1'b0;
                    assign valid_in = 1'b0;
                    assign done = 1'b0;


                end

                // COMP_W
                3: begin
                    assign enable = 1'b0;
                    assign comp = 1'b0;
                    assign write = 1'b0;
                    assign mem_wr = 1'b0;
                    assign mem_rd = 1'b0;
                    assign valid_in = 1'b0;
                    assign done = 1'b0;


                end 

                // CACHE_+_DIRECT
                4: begin
                    assign enable = 1'b0;
                    assign comp = 1'b0;
                    assign write = 1'b0;
                    assign mem_wr = 1'b0;
                    assign mem_rd = 1'b0;
                    assign valid_in = 1'b0;
                    assign done = 1'b0;


                end

                // DIRECT_MEM
                5: begin
                    assign enable = 1'b0;
                    assign comp = 1'b0;
                    assign write = 1'b0;
                    assign mem_wr = 1'b0;
                    assign mem_rd = 1'b0;
                    assign valid_in = 1'b0;
                    assign done = 1'b0;

                    
                end

                default: 
            endcase
        end

endmodule