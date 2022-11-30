module cache_controller(
    rd, wr, hit, dirty, valid, busy, offset,                            // Inputs
    enable, comp, write, mem_wr, mem_rd, valid_in, cache_hit, done      // Outputs
    clk, rst);                                                          // Clk & Rst

////////////
// PORTS //
//////////
        input 
            rd,         // Load instruction
            wr,         // Store instruction
            hit,        // Cache tag matches
            dirty,      // Accessed line is dirty
            valid;      // Accessed line is valid

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
            done;       // Done signal (only positive for one cycle)

////////////
// WIRES //
//////////
        wire [3:0] cur_state;
        wire [3:0] next_state;

////////////
// STATE //
//////////
/*  
    Wait         = 0
    CompR        = 0
    CompW        = 0
    CompRRetry   = 1
    AccessW_0    = 2
    AccessW_1    = 3
    AccessW_2    = 4
    AccessW_3    = 5
    AccessW_4    = 6
    AccessW_5    = 7
    Cache+Direct = 8
    DirectMem    = 9
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

                //NOTE: Combined what used to be states 0 (WAIT), 1 (COMP_R), and 3 (COMP_W) to be one state (0) 
                //      (Otherwise cache wastes a cycle)
                //NOTE: Added additional read state since cache_hit is only if we succeed right away
                //TODO: Write whole cacheline instead of just one word for AccessW requires multiple states (I believe 6)
                // WAIT/COMP_R/COMP_W
                4'd0: begin
                    enable       = ((rd | wr) ? 1'b1 : 1'b0);
                    comp         = ((rd | wr) ? 1'b1 : 1'b0);
                    write        = (wr ? 1'b1 : 1'b0);
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b0;
                    done         = (rd ? (hit & valid) : 1'b0);
                    cache_hit    = ((rd | wr) ? (hit & valid) : 1'b0);


                    assign next_state = (rd ? ((hit & valid) ? 4'd0 : 4'd2) : // Read
                                        (wr ? ((hit & valid) ? 4'd8 : 4'd9) : // Write
                                        4'd0));                               // No mem operation (spin)
                end
                
                // COMP_R Retry
                /*
                    Needed so that we don't reset cache_hit
                    Otherwise it's the same as COMP_R
                    Should never really not be hit & valid
                */
                4'd1: begin
                    enable       = 1'b1;
                    comp         = 1'b1;
                    write        = 1'b0;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b0;
                    done         = (hit & valid);

                    assign next_state = ((hit & valid) ? 4'd0 : 4'd2);
                end

                // // COMP_R
                // 4'd1: begin
                //     enable       = 1'b1;
                //     comp         = 1'b1;
                //     write        = 1'b0;
                //     mem_wr       = 1'b0;
                //     mem_rd       = 1'b0;
                //     valid_in     = 1'b0;
                //     done         = (hit & valid);

                //     assign next_state = ((hit & valid) ? 4'd0 : 4'd2);
                // end

                // ACCESS_W_0
                4'd2: begin
                    enable       = 1'b1;
                    comp         = 1'b0;
                    write        = 1'b1;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b1;
                    valid_in     = 1'b1;
                    done         = 1'b0;

                    assign next_state = (|busy ? 4'd2 : 4'd1);
                end

                // ACCESS_W_1
                4'd3: begin
                    enable       = 1'b1;
                    comp         = 1'b0;
                    write        = 1'b1;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b1;
                    valid_in     = 1'b1;
                    done         = 1'b0;

                    assign next_state = (|busy ? 4'd2 : 4'd1);
                end

                // ACCESS_W_2
                4'd4: begin
                    enable       = 1'b1;
                    comp         = 1'b0;
                    write        = 1'b1;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b1;
                    valid_in     = 1'b1;
                    done         = 1'b0;

                    assign next_state = (|busy ? 4'd2 : 4'd1);
                end

                // ACCESS_W_3
                4'd5: begin
                    enable       = 1'b1;
                    comp         = 1'b0;
                    write        = 1'b1;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b1;
                    valid_in     = 1'b1;
                    done         = 1'b0;

                    assign next_state = (|busy ? 4'd2 : 4'd1);
                end

                // ACCESS_W_4
                4'd6: begin
                    enable       = 1'b1;
                    comp         = 1'b0;
                    write        = 1'b1;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b1;
                    valid_in     = 1'b1;
                    done         = 1'b0;

                    assign next_state = (|busy ? 4'd2 : 4'd1);
                end

                // ACCESS_W_5
                4'd7: begin
                    enable       = 1'b1;
                    comp         = 1'b0;
                    write        = 1'b1;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b1;
                    valid_in     = 1'b1;
                    done         = 1'b0;

                    assign next_state = (|busy ? 4'd2 : 4'd1);
                end


                // // COMP_W
                // 4'd3: begin
                //     enable       = 1'b1;
                //     comp         = 1'b1;
                //     write        = 1'b1;
                //     mem_wr       = 1'b0;
                //     mem_rd       = 1'b0;
                //     valid_in     = 1'b0;
                //     done         = 1'b0;

                //     assign next_state = ((hit & valid) ? 4'd4 : 4'd5);
                // end 

                // CACHE_+_DIRECT
                4'd8: begin
                    enable       = 1'b1;
                    comp         = 1'b1;
                    write        = 1'b1;
                    mem_wr       = 1'b1;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b0;
                    done         = ~(|busy);

                    assign next_state = (|busy ? 4'd8 : 4'd0);
                end

                // DIRECT_MEM
                4'd9: begin
                    enable       = 1'b0;
                    comp         = 1'b0;
                    write        = 1'b0;
                    mem_wr       = 1'b1;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b0;
                    done         = ~(|busy);

                    assign next_state = (|busy ? 4'd9 : 4'd0);
                end

                default: begin
                    // TODO: Throw error
                end
            endcase
        end

endmodule