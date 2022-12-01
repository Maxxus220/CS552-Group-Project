module cache_controller(
    rd, wr, hit, dirty, valid, busy, offset, stall_in,                     // Inputs
    enable, comp, write, mem_wr, mem_rd, valid_in, cache_hit, done,     // Outputs
    word_m, word_c, stall_out,                                              // ^^^^^^^
    clk, rst);                                                          // Clk & Rst

////////////
// PORTS //
//////////
        input 
            rd,         // Load instruction
            wr,         // Store instruction
            hit,        // Cache tag matches
            dirty,      // Accessed line is dirty
            valid,      // Accessed line is valid
            stall_in;      // Stall from mem

        input [3:0] 
            busy;       // Busy status of four main mem banks

        input [2:0] 
            offset;     // Last 3 bits of cache access addr

        input 
            clk,        // Clock signal
            rst;        // Reset signal

        output reg
            enable,     // Enable for cache
            comp,       // Comp signal for cache
            write,      // Write signal for cache
            mem_wr,     // Write for main mem (Serves as direct_wr as well from our diagram)
            mem_rd,     // Read for main mem
            valid_in,   // Value to set for valid when writing to cache
            cache_hit,  // Whether cache_hit achieved without accessing main mem
            stall_out,      // Whether to stall
            done;       // Done signal (only positive for one cycle)

        output reg [1:0] 
            word_m,     // Bits [2:1] of addr for accessing Four Bank Mem by word
            word_c;     // Bits [2:1] of addr for accessing Cache by word

/////////////////
// STATE REGS //
///////////////
        wire [3:0] cur_state;
        reg  [3:0] next_state;

////////////
// STATE //
//////////
/*  
    Wait         = 0
    CompR        = 1
    CompRRetry   = 2
    CompW        = 3
    CompWRetry   = 4
    AccessR      = 5
    MemWrite     = 6
    AccessR_0    = 7
    AccessR_1    = 8
    AccessR_2    = 9
    AccessR_3    = 10
    AccessR_4    = 11
    AccessR_5    = 12
    MemWait      = 13
*/
        dff STATE [3:0] (.q(cur_state), .d(next_state), .clk(clk), .rst(rst));

////////////////////
// STATE MACHINE //
//////////////////
/*
    Each state should begin with its outputs
    then continue with transition logic
    to set next_state

    Runs @* since state dff is bound to posedge of clk
    and assigns need to be continuous
*/
        always @(*) begin
            case (cur_state)

                // WAIT
                4'd0: begin
                    enable       = 1'b0;
                    comp         = 1'b0;
                    write        = 1'b0;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b0;
                    done         = 1'b0;
                    cache_hit    = 1'b0;
                    word_m       = offset[2:1];
                    word_c       = offset[2:1];
                    stall_out    = rd | wr;

                    next_state = (rd ? 4'd1 : (wr ? 4'd3 : 4'd0));
                end
                
                // COMP_R
                4'd1: begin
                    enable       = 1'b1;
                    comp         = 1'b1;
                    write        = 1'b0;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b1;
                    done         = (hit & valid);
                    cache_hit    = (hit & valid);
                    word_m       = offset[2:1];
                    word_c       = offset[2:1];
                    stall_out    = !(hit & valid);

                    next_state = ((hit & valid) ? 4'd0 : 4'd5);
                end

                // COMP_R_RETRY
                4'd2: begin
                    enable       = 1'b1;
                    comp         = 1'b1;
                    write        = 1'b0;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b1;
                    done         = (hit & valid);
                    word_m       = offset[2:1];
                    word_c       = offset[2:1];
                    stall_out    = !(hit & valid);

                    next_state = 4'd0;
                end

                // COMP_W
                4'd3: begin
                    enable       = 1'b1;
                    comp         = 1'b1;
                    write        = 1'b1;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b1;
                    done         = (hit & valid);
                    cache_hit    = (hit & valid);
                    word_m       = offset[2:1];
                    word_c       = offset[2:1];
                    stall_out    = !(hit & valid);

                    next_state = ((hit & valid) ? 4'd0 : 4'd5);
                end

                // COMP_W_RETRY
                4'd4: begin
                    enable       = 1'b1;
                    comp         = 1'b1;
                    write        = 1'b1;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b1;
                    done         = (hit & valid);
                    word_m       = offset[2:1];
                    word_c       = offset[2:1];
                    stall_out    = !(hit & valid);

                    next_state = 4'd0;
                end

                // ACCESS_R
                4'd5: begin
                    enable       = 1'b1;
                    comp         = 1'b0;
                    write        = 1'b0;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b0;
                    done         = 1'b0;
                    word_m       = offset[2:1];
                    word_c       = offset[2:1];
                    stall_out    = 1'b1;

                    next_state = ((dirty & valid) ? 4'd6 : 4'd7);
                end

                // MEM_WRITE
                4'd6: begin
                    enable       = 1'b1;
                    comp         = 1'b0;
                    write        = 1'b0;
                    mem_wr       = 1'b1;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b0;
                    done         = 1'b0;
                    word_m       = offset[2:1];
                    word_c       = offset[2:1];
                    stall_out    = 1'b1;

                    next_state = 4'd13;
                end

                // ACCESS_W_0
                4'd7: begin
                    enable       = 1'b0;
                    comp         = 1'b0;
                    write        = 1'b0;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b1;
                    valid_in     = 1'b0;
                    done         = 1'b0;
                    word_m       = 2'b00;
                    word_c       = offset[2:1];
                    stall_out    = 1'b1;

                    next_state = 4'd8;
                end

                // ACCESS_W_1
                4'd8: begin
                    enable       = 1'b0;
                    comp         = 1'b0;
                    write        = 1'b0;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b1;
                    valid_in     = 1'b0;
                    done         = 1'b0;
                    word_m       = 2'b01;
                    word_c       = offset[2:1];
                    stall_out    = 1'b1;

                    next_state = 4'd9;
                end

                // ACCESS_W_2
                4'd9: begin
                    enable       = 1'b1;
                    comp         = 1'b0;
                    write        = 1'b1;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b1;
                    valid_in     = 1'b1;
                    done         = 1'b0;
                    word_m       = 2'b10;
                    word_c       = 2'b00;
                    stall_out    = 1'b1;

                    next_state = 4'd10;
                end

                // ACCESS_W_3
                4'd10: begin
                    enable       = 1'b1;
                    comp         = 1'b0;
                    write        = 1'b1;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b1;
                    valid_in     = 1'b1;
                    done         = 1'b0;
                    word_m       = 2'b11;
                    word_c       = 2'b01;
                    stall_out    = 1'b1;

                    next_state = 4'd11;
                end

                // ACCESS_W_4
                4'd11: begin
                    enable       = 1'b1;
                    comp         = 1'b0;
                    write        = 1'b1;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b1;
                    done         = 1'b0;
                    word_m       = offset[2:1];
                    word_c       = 2'b10;
                    stall_out    = 1'b1;

                    next_state = 4'd12;
                end

                // ACCESS_W_5
                4'd12: begin
                    enable       = 1'b1;
                    comp         = 1'b0;
                    write        = 1'b1;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b1;
                    done         = 1'b0;
                    word_m       = offset[2:1];
                    word_c       = 2'b11;
                    stall_out    = 1'b1;

                    next_state = (rd ? 4'd2 : 4'd4);
                end

                // MEM_WAIT
                4'd13: begin
                    enable       = 1'b0;
                    comp         = 1'b0;
                    write        = 1'b0;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b0;
                    done         = 1'b0;
                    word_m       = offset[2:1];
                    word_c       = offset[2:1];
                    stall_out    = 1'b1;

                    next_state = (|busy ? 4'd13 : 4'd7);
                end

                default: begin
                    // TODO: Throw error
                end
            endcase
        end

endmodule
