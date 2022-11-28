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
                           .enable               (enable_ctrl),
                           .clk                  (clk),
                           .rst                  (rst),
                           .createdump           (createdump),
                           .tag_in               (Addr[15:11]),
                           .index                (Addr[10:3]),
                           .offset               (Addr[2:0]),
                           .data_in              (),
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
                        .addr              (Addr),
                        .data_in           (),
                        .wr                (mem_wr_ctrl),
                        .rd                (mem_rd_ctrl));

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
                           .rd        (Rd),
                           .wr        (Wr),
                           .hit       (hit_c0),
                           .dirty     (dirty_c0),
                           .valid     (valid_c0),
                           .busy      (busy_m),
                           .offset    (Addr[2:0]),
                           .clk       (clk),
                           .rst       (rst))

   
endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
