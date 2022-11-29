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
        wire [2:0] cur_state;
        wire [2:0] next_state;

////////////
// STATE //
//////////
/*  
    Wait         = 0
    CompR        = 0
    CompW        = 0
    CompRRetry   = 1
    AccessW      = 2
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

    Runs @* since state dff is bound to posedge of clk
    and assigns need to be continuous
*/
        always @(*) begin
            case (cur_state)

                //TODO: Believe states 0, 1, and 3 need to be one state (Otherwise cache wastes a cycle)
                //TODO: Also need additional read state since cache_hit is only if we succeed right away
                // WAIT/COMP_R/COMP_W
                3'd0: begin
                    enable       = ((rd | wr) ? 1'b1 : 1'b0);
                    comp         = ((rd | wr) ? 1'b1 : 1'b0);
                    write        = (wr ? 1'b1 : 1'b0);
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b0;
                    done         = (rd ? (hit & valid) : 1'b0);
                    cache_hit    = ((rd | wr) ? (hit & valid) : 1'b0);


                    assign next_state = (rd ? ((hit & valid) ? 3'd0 : 3'd2) : // Read
                                        (wr ? ((hit & valid) ? 3'd4 : 3'd5) : // Write
                                        3'd0));                               // No mem operation (spin)
                end
                
                // COMP_R Retry
                /*
                    Needed so that we don't reset cache_hit
                    Otherwise it's the same as COMP_R
                    Should never really not be hit & valid
                */
                3'd1: begin
                    enable       = 1'b1;
                    comp         = 1'b1;
                    write        = 1'b0;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b0;
                    done         = (hit & valid);

                    assign next_state = ((hit & valid) ? 0 : 2);
                end

                // // COMP_R
                // 3'd1: begin
                //     enable       = 1'b1;
                //     comp         = 1'b1;
                //     write        = 1'b0;
                //     mem_wr       = 1'b0;
                //     mem_rd       = 1'b0;
                //     valid_in     = 1'b0;
                //     done         = (hit & valid);

                //     assign next_state = ((hit & valid) ? 0 : 2);
                // end

                // ACCESS_W
                3'd2: begin
                    enable       = 1'b1;
                    comp         = 1'b0;
                    write        = 1'b1;
                    mem_wr       = 1'b0;
                    mem_rd       = 1'b1;
                    valid_in     = 1'b1;
                    done         = 1'b0;

                    assign next_state = (|busy ? 2 : 1);
                end

                // // COMP_W
                // 3'd3: begin
                //     enable       = 1'b1;
                //     comp         = 1'b1;
                //     write        = 1'b1;
                //     mem_wr       = 1'b0;
                //     mem_rd       = 1'b0;
                //     valid_in     = 1'b0;
                //     done         = 1'b0;

                //     assign next_state = ((hit & valid) ? 4 : 5);
                // end 

                // CACHE_+_DIRECT
                3'd4: begin
                    enable       = 1'b1;
                    comp         = 1'b1;
                    write        = 1'b1;
                    mem_wr       = 1'b1;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b0;
                    done         = ~(|busy);

                    assign next_state = (|busy ? 3'd4 : 3'd0);
                end

                // DIRECT_MEM
                3'd5: begin
                    enable       = 1'b0;
                    comp         = 1'b0;
                    write        = 1'b0;
                    mem_wr       = 1'b1;
                    mem_rd       = 1'b0;
                    valid_in     = 1'b0;
                    done         = ~(|busy);

                    assign next_state = (|busy ? 3'd5 : 3'd0);
                end

                default: begin
                    // TODO: Throw error
                end
            endcase
        end

endmodule