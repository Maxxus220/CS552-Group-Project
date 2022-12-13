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
c1    = cache one
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

      // Cache One
      wire [4:0]    tag_out_c1;
      wire [15:0]   data_out_c1;
      wire          hit_c1;
      wire          dirty_c1;
      wire          valid_c1;
      wire          err_c1;

      // Main Memory
      wire [15:0]   data_out_m;
      wire          stall_m;
      wire [3:0]    busy_m;
      wire          err_m;
      wire [4:0] 	  tag_m;


      // Controller
      wire         enable_c0_ctrl;
      wire         enable_c1_ctrl;
      wire         comp_ctrl;
      wire         write_ctrl;
      wire         mem_wr_ctrl;
      wire         mem_rd_ctrl;
      wire         valid_in_ctrl;
      wire         done_ctrl;  
      wire         target_ctrl;
      wire [1:0]   word_c_ctrl;
      wire [1:0]   word_m_ctrl;
      wire         cache_hit_ctrl;
      wire         stall_ctrl;

      // Data-In Mux Wires
      wire [15:0] data_in_c;

      // Main Mem Addr Concat Wire
      wire [15:0] addr_m;

      // Cache Offset Wire
      wire [2:0] offset_c;


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
                              .enable               (enable_c0_ctrl),
                              .clk                  (clk),
                              .rst                  (rst),
                              .createdump           (createdump),
                              .tag_in               (Addr[15:11]),
                              .index                (Addr[10:3]),
                              .offset               (offset_c),
                              .data_in              (data_in_c),
                              .comp                 (comp_ctrl),
                              .write                (write_ctrl),
                              .valid_in             (valid_in_ctrl));

      cache #(2 + memtype) c1(// Outputs
                              .tag_out              (tag_out_c1),
                              .data_out             (data_out_c1),
                              .hit                  (hit_c1),
                              .dirty                (dirty_c1),
                              .valid                (valid_c1),
                              .err                  (err_c1),
                              // Inputs
                              .enable               (enable_c1_ctrl),
                              .clk                  (clk),
                              .rst                  (rst),
                              .createdump           (createdump),
                              .tag_in               (Addr[15:11]),
                              .index                (Addr[10:3]),
                              .offset               (offset_c),
                              .data_in              (data_in_c),
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
                        .data_in           ((target_ctrl ? data_out_c1 : data_out_c0)),
                        .wr                (mem_wr_ctrl),
                        .rd                (mem_rd_ctrl));

      cache_controller ctrl(//Outputs
                           .enable_c0 (enable_c0_ctrl),
                           .enable_c1 (enable_c1_ctrl),
                           .comp      (comp_ctrl),
                           .write     (write_ctrl),
                           .mem_wr    (mem_wr_ctrl),
                           .mem_rd    (mem_rd_ctrl),
                           .valid_in  (valid_in_ctrl),
                           .done      (done_ctrl),
                           .word_c    (word_c_ctrl),
                           .word_m    (word_m_ctrl),
                           .cache_hit (cache_hit_ctrl),
                           .stall_out (stall_ctrl),
                           .target    (target_ctrl),
                           //Inputs
                           .rd        (Rd),
                           .wr        (Wr),
                           .hit_c0    (hit_c0),
                           .hit_c1    (hit_c1),
                           .dirty_c0  (dirty_c0),
                           .dirty_c1  (dirty_c1),
                           .valid_c0  (valid_c0),
                           .valid_c1  (valid_c1),
                           .busy      (busy_m),
                           .offset    (Addr[2:0]),
                           .stall_in  (stall_m),
                           .clk       (clk),
                           .rst       (rst));


////////////
// MUXES //
//////////

      // Data-In Cache Mux
      assign data_in_c = (~comp_ctrl ? data_out_m : DataIn);

      // Memory Tag Mux
      assign tag_m = (mem_wr_ctrl ? (target_ctrl ? tag_out_c1 : tag_out_c0) : Addr[15:11]);


//////////////////
// ADDR CONCAT //
////////////////

      // Cache Offset Concat
      assign offset_c = {word_c_ctrl, Addr[0]};

      // Main Memory Addr Concat
      assign addr_m = {tag_m, Addr[10:3], word_m_ctrl, Addr[0]};


/////////////
// OUTPUT //
///////////

      assign DataOut = rst ? 16'd0 : ((hit_c1 & valid_c1) ? data_out_c1 : data_out_c0);
      assign Done = rst ? 1'b0 : done_ctrl;
      assign Stall = rst ? 1'b0 : stall_ctrl;
      assign CacheHit = rst ? 1'b0 : cache_hit_ctrl;
      assign err = err_c0 | err_m | err_c1;
   
endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
