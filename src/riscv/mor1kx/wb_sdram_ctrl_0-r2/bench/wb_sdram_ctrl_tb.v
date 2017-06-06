/*
 * Copyright (c) 2013, Olof Kindgren <olof.kindgren@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and non-source forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in non-source form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 * THIS WORK IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * WORK, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module wb_sdram_ctrl_tb;

   localparam MEMORY_SIZE_WORDS = 4096;
   
   localparam WB_PORTS = 3;

   localparam BA_WIDTH = 2;

   vlog_tb_utils vlog_tb_utils0();

   reg wbm_rst = 1'b1;
   
   reg wb_clk = 1'b1;
   reg wb_rst = 1'b1;
   
   reg sdram_clk = 1'b1;
   reg sdram_rst = 1'b1;
   
   initial #1800000 wbm_rst <= 1'b0;

   initial #200000 wb_rst <= 1'b0;
   always #10000 wb_clk <= !wb_clk;

   initial #100000 sdram_rst <= 1'b0;
   always #5000 sdram_clk <= !sdram_clk;

   assign #1 sdram_clk_d = sdram_clk;
   
   wire [BA_WIDTH-1:0] ba;
   wire [12:0] 	       a;
   wire 	       cs_n;
   wire 	       ras;
   wire 	       cas;
   wire 	       we;
   wire [15:0] 	       dq_o;
   wire [1:0] 	       dqm;
   wire [15:0] 	       dq_i;
   wire 	       dq_oe;
   wire 	       cke;

   wire [15:0] 	       dq;
   
   wire [WB_PORTS*32-1:0] wb_adr;
   wire [WB_PORTS-1:0] 	  wb_stb;
   wire [WB_PORTS-1:0] 	  wb_cyc;
   wire [WB_PORTS*3-1:0]  wb_cti;
   wire [WB_PORTS*2-1:0]  wb_bte;
   wire [WB_PORTS-1:0] 	  wb_we;
   wire [WB_PORTS*4-1:0]  wb_sel;
   wire [WB_PORTS*32-1:0] wb_dat;
   wire [WB_PORTS*32-1:0] wb_rdt;
   wire [WB_PORTS-1:0] 	  wb_ack;
   
   wire [31:0] 	 slave_writes;
   wire [31:0] 	 slave_reads;
   wire [WB_PORTS-1:0] done_int;

   genvar 	 i;
   
   integer 	 TRANSACTIONS;
   integer 	 SUBTRANSACTIONS;
   integer 	 SEED;

   generate
      for(i=0;i<WB_PORTS;i=i+1) begin : masters
	 wb_bfm_transactor
	    #(.MEM_HIGH (MEMORY_SIZE_WORDS*(i+1)-1),
	      .MEM_LOW  (MEMORY_SIZE_WORDS*i),
	      .AUTORUN  (0),
	      .VERBOSE  (0))
	 bfm
	    (.wb_clk_i (wb_clk),
	     .wb_rst_i (wbm_rst),
	     .wb_adr_o (wb_adr[i*32+:32]),
	     .wb_dat_o (wb_dat[i*32+:32]),
	     .wb_sel_o (wb_sel[i*4+:4]),
	     .wb_we_o  (wb_we[i] ), 
	     .wb_cyc_o (wb_cyc[i]),
	     .wb_stb_o (wb_stb[i]),
	     .wb_cti_o (wb_cti[i*3+:3]),
	     .wb_bte_o (wb_bte[i*2+:2]),
	     .wb_dat_i (wb_rdt[i*32+:32]),
	     .wb_ack_i (wb_ack[i]),
	     .wb_err_i (1'b0),
	     .wb_rty_i (1'b0),
	     //Test Control
	     .done(done_int[i]));

	 initial begin
	    //Grab CLI parameters
	    if($value$plusargs("transactions=%d", TRANSACTIONS))
	      bfm.set_transactions(TRANSACTIONS);
	    if($value$plusargs("subtransactions=%d", SUBTRANSACTIONS))
	      bfm.set_subtransactions(SUBTRANSACTIONS);
	    if($value$plusargs("seed=%d", SEED))
	      bfm.SEED = SEED;

	    bfm.display_settings;
	    bfm.run;
	    bfm.display_stats;
	 end
      end // block: slaves
   endgenerate
   
   assign done = &done_int;
   
   always @(done) begin
      if(done === 1) begin
	 $display("All tests passed!");
	 $finish;
	 
      end
   end

wb_sdram_ctrl
  #(.TECHNOLOGY	("GENERIC"),
    .CLK_FREQ_MHZ	(100),	// sdram_clk freq in MHZ
    .POWERUP_DELAY	(0),	// power up delay in us
    .BURST_LENGTH	(8),	// 0), 1), 2), 4 or 8 (0 = full page)
    .WB_PORTS	(WB_PORTS),	// Number of wishbone ports
    .BUF_WIDTH	(3),	// Buffer size = 2^BUF_WIDTH
    .ROW_WIDTH	(13),	// Row width
    .COL_WIDTH	(9),	// Column width
    .BA_WIDTH	(BA_WIDTH),	// Ba width
    .tCAC		(2),	// CAS Latency
    .tRAC		(5),	// RAS Latency
    .tRP		(2),	// Command Period (PRE to ACT)
    .tRC		(7),	// Command Period (REF to REF / ACT to ACT)
    .tMRD		(3))	// Mode Register Set To Command Delay time
   wb_sdram_ctrl0
   (// SDRAM interface
    .sdram_rst  (sdram_rst),
    .sdram_clk  (sdram_clk_d),
    .ba_pad_o   (ba),
    .a_pad_o    (a),
    .cs_n_pad_o (cs_n),
    .ras_pad_o  (ras),
    .cas_pad_o  (cas),
    .we_pad_o   (we),
    .dq_o       (dq_o),
    .dqm_pad_o  (dqm),
    .dq_i       (dq_i),
    .dq_oe      (dq_oe),
    .cke_pad_o  (cke),
		 // Wishbone interface
    .wb_clk   (wb_clk),
    .wb_rst   (wb_rst),
    .wb_adr_i (wb_adr),
    .wb_stb_i (wb_stb),
    .wb_cyc_i (wb_cyc),
    .wb_cti_i (wb_cti),
    .wb_bte_i (wb_bte),
    .wb_we_i  (wb_we) ,
    .wb_sel_i (wb_sel),
    .wb_dat_i (wb_dat),
    .wb_dat_o (wb_rdt),
    .wb_ack_o (wb_ack));

   //Tristate buffer
   assign dq = dq_oe ? dq_o : 16'bz;
   assign dq_i = dq;
   
   //Memory model
   mt48lc16m16a2 mt48lc16m16a20
     (.Dq    (dq),
      .Addr  (a),
      .Ba    (ba),
      .Clk   (sdram_clk),
      .Cke   (cke),
      .Cs_n  (cs_n),
      .Ras_n (ras),
      .Cas_n (cas),
      .We_n  (we),
      .Dqm   (dqm));
   
endmodule
