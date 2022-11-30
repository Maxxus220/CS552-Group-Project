/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );

////////////
// PORTS //
//////////

      input [15:0] Addr;
      input [15:0] DataIn;
      input        Rd;
      input        Wr;
      input        createdump;
      input        clk;
      input        rst;
      
      output [15:0] DataOut;
      output Done;
      output Stall;
      output CacheHit;
      output err;


////////////
// WIRES //
//////////
/*
Format: <wire_name>_<c0/m/ctrl>

c0    = cache zero
m     = main mem
ctrl  = controller
*/

      // Cache Zero
      wire [4:0]    tag_out_c0;
      wire [15:0]   data_out_c0;
      wire          hit_c0;
      wire          dirty_c0;
      wire          valid_c0;
      wire          err_c0;

      // Main Memory
      wire [15:0]   data_out_m;
      wire          stall_m;
      wire [3:0]    busy_m;
      wire          err_m;

      // Controller
      wire         enable_ctrl;
      wire         comp_ctrl;
      wire         write_ctrl;
      wire         mem_wr_ctrl;
      wire         mem_rd_ctrl;
      wire         valid_in_ctrl;
      wire         done_ctrl;  
      wire [1:0]   word_c_ctrl;
      wire [1:0]   word_m_ctrl;
      wire         cache_hit_ctrl;

      // Data-In Mux Wires
      wire [15:0] data_in_c0;
      wire [15:0] data_in_m;

      // Main Mem Addr Concat Wire
      wire [15:0] addr_m;

      // Cache Zero Offset Wire
      wire [2:0] offset_c0;


//////////////
// MODULES //
////////////

      /* data_mem = 1, inst_mem = 0 *
      * needed for cache parameter */
      parameter memtype = 0;
      cache #(0 + memtype) c0(// Outputs
                              .tag_out              (tag_out_c0),
                              .data_out             (data_out_c0),
                              .hit                  (hit_c0),
                              .dirty                (dirty_c0),
                              .valid                (valid_c0),
                              .err                  (err_c0),
                              // Inputs
                              .enable               (enable_ctrl),
                              .clk                  (clk),
                              .rst                  (rst),
                              .createdump           (createdump),
                              .tag_in               (Addr[15:11]),
                              .index                (Addr[10:3]),
                              .offset               (offset_c0),
                              .data_in              (data_in_c0),
                              .comp                 (comp_ctrl),
                              .write                (write_ctrl),
                              .valid_in             (valid_in_ctrl));

      four_bank_mem mem(// Outputs
                        .data_out          (data_out_m),
                        .stall             (stall_m),
                        .busy              (busy_m),
                        .err               (err_m),
                        // Inputs
                        .clk               (clk),
                        .rst               (rst),
                        .createdump        (createdump),
                        .addr              (addr_m),
                        .data_in           (data_in_m),
                        .wr                (mem_wr_ctrl),
                        .rd                (mem_rd_ctrl));

      cache_controller ctrl(//Outputs
                           .enable    (enable_ctrl),
                           .comp      (comp_ctrl),
                           .write     (write_ctrl),
                           .mem_wr    (mem_wr_ctrl),
                           .mem_rd    (mem_rd_ctrl),
                           .valid_in  (valid_in_ctrl),
                           .done      (done_ctrl),
                           .word_c    (word_c_ctrl),
                           .word_m    (word_m_ctrl),
                           .cache_hit (cache_hit_ctrl),
                           //Inputs
                           .rd        (Rd),
                           .wr        (Wr),
                           .hit       (hit_c0),
                           .dirty     (dirty_c0),
                           .valid     (valid_c0),
                           .busy      (busy_m),
                           .offset    (Addr[2:0]),
                           .stall     (stall_m),
                           .clk       (clk),
                           .rst       (rst));


////////////////////
// DATA IN MUXES //
//////////////////

      // Data-In Cache Zero Mux
      assign data_in_c0 = (~comp_ctrl ? data_out_m : DataIn);

      // Data-In Main Memory Mux
      assign data_in_m = (mem_wr_ctrl ? DataIn : data_out_c0);


//////////////////
// ADDR CONCAT //
////////////////

      // Cache Zero Offset Concat
      assign offset_c0 = {word_c_ctrl, Addr[0]};

      // Main Memory Addr Concat
      assign addr_m = {Addr[15:3], word_m_ctrl, Addr[0]};


/////////////
// OUTPUT //
///////////

      assign DataOut = data_out_c0;
      assign Done = done_ctrl;
      assign Stall = ~done_ctrl;
      assign CacheHit = cache_hit_ctrl;
      assign err = err_c0 | err_m;
   
endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
