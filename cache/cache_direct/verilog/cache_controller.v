module cache_controller(
    rd, wr, hit, dirty, valid, busy, offset,                 // Inputs
    enable, comp, write, mem_wr, mem_rd, valid_in, done      // Outputs
    clk, rst);                                               // Clk & Rst

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

        output 
            enable,     // Enable for cache
            comp,       // Comp signal for cache
            write,      // Write signal for cache
            mem_wr,     // Write for main mem (Serves as direct_wr as well from our diagram)
            mem_rd,     // Read for main mem
            valid_in,   // Value to set for valid when writing to cache
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
                3'd0: begin
                    assign enable       = 1'b0;
                    assign comp         = 1'b0;
                    assign write        = 1'b0;
                    assign mem_wr       = 1'b0;
                    assign mem_rd       = 1'b0;
                    assign valid_in     = 1'b0;
                    assign done         = 1'b0;

                    assign next_state = ((rd | wr) ? (rd ? 1 : 3) : (0));
                end
                
                // COMP_R
                3'd1: begin
                    assign enable       = 1'b1;
                    assign comp         = 1'b1;
                    assign write        = 1'b0;
                    assign mem_wr       = 1'b0;
                    assign mem_rd       = 1'b0;
                    assign valid_in     = 1'b0;
                    assign done         = (hit & valid);

                    assign next_state = ((hit & valid) ? 0 : 2);
                end

                // ACCESS_W
                3'd2: begin
                    assign enable       = 1'b1;
                    assign comp         = 1'b0;
                    assign write        = 1'b1;
                    assign mem_wr       = 1'b0;
                    assign mem_rd       = 1'b1;
                    assign valid_in     = 1'b1;
                    assign done         = 1'b0;

                    assign next_state = (|busy ? 2 : 1);
                end

                // COMP_W
                3'd3: begin
                    assign enable       = 1'b1;
                    assign comp         = 1'b1;
                    assign write        = 1'b1;
                    assign mem_wr       = 1'b0;
                    assign mem_rd       = 1'b0;
                    assign valid_in     = 1'b0;
                    assign done         = 1'b0;

                    assign next_state = ((hit & valid) ? 4 : 5);
                end 

                // CACHE_+_DIRECT
                3'd4: begin
                    assign enable       = 1'b1;
                    assign comp         = 1'b1;
                    assign write        = 1'b1;
                    assign mem_wr       = 1'b1;
                    assign mem_rd       = 1'b0;
                    assign valid_in     = 1'b0;
                    assign done         = ~(|busy);

                    assign next_state = (|busy ? 4 : 0);
                end

                // DIRECT_MEM
                3'd5: begin
                    assign enable       = 1'b0;
                    assign comp         = 1'b0;
                    assign write        = 1'b0;
                    assign mem_wr       = 1'b1;
                    assign mem_rd       = 1'b0;
                    assign valid_in     = 1'b0;
                    assign done         = ~(|busy);

                    assign next_state = (|busy ? 5 : 0);
                end

                default: begin
                    // TODO
                end
            endcase
        end

endmodule