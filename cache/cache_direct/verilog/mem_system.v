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
c0    = cache zero
m     = main mem
ctrl  = controller
Format: <wire_name>_<c0/m/ctrl>
*/

wire 
   // Cache Zero
   tag_out_c0,
   hit_c0,
   dirty_c0,
   valid_c0,
   err_c0,

   //Main Memory
   data_out_m,
   stall_m,
   busy_m,
   err_m,

   //Controller
   enable_ctrl,
   comp_ctrl,
   write_ctrl,
   mem_wr_ctrl,
   mem_rd_ctrl,
   valid_in_ctrl;


//////////////
// MODULES //
////////////

      /* data_mem = 1, inst_mem = 0 *
      * needed for cache parameter */
      parameter memtype = 0;
      cache #(0 + memtype) c0(// Outputs
                           .tag_out              (tag_out_c0),
                           .data_out             (DataOut),
                           .hit                  (hit_c0),
                           .dirty                (dirty_c0),
                           .valid                (valid_c0),
                           .err                  (err_c0),
                           // Inputs
                           .enable               (),
                           .clk                  (clk),
                           .rst                  (rst),
                           .createdump           (),
                           .tag_in               (),
                           .index                (),
                           .offset               (),
                           .data_in              (),
                           .comp                 (),
                           .write                (),
                           .valid_in             ());

      four_bank_mem mem(// Outputs
                        .data_out          (data_out_m),
                        .stall             (stall_m),
                        .busy              (busy_m),
                        .err               (err_m),
                        // Inputs
                        .clk               (clk),
                        .rst               (rst),
                        .createdump        (),
                        .addr              (),
                        .data_in           (),
                        .wr                (),
                        .rd                ());

      // your code here
      cache_controller ctrl(//Outputs
                           .enable    (enable_ctrl),
                           .comp      (comp_ctrl),
                           .write     (write_ctrl),
                           .mem_wr    (mem_wr_ctrl),
                           .mem_rd    (mem_rd_ctrl),
                           .valid_in  (valid_in_ctrl),
                           .done      (Done),
                           //Inputs
                           .rd        (),
                           .wr        (),
                           .hit       (),
                           .dirty     (),
                           .valid     (),
                           .busy      (),
                           .offset    (),
                           .clk       (clk),
                           .rst       (rst))

   
endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
