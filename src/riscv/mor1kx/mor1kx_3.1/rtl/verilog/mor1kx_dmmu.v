/******************************************************************************
 This Source Code Form is subject to the terms of the
 Open Hardware Description License, v. 1.0. If a copy
 of the OHDL was not distributed with this file, You
 can obtain one at http://juliusbaxter.net/ohdl/ohdl.txt

 Description: Data MMU implementation

 Copyright (C) 2013 Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>

 ******************************************************************************/

`include "mor1kx-defines.v"

module mor1kx_dmmu
  #(
    parameter FEATURE_DMMU_HW_TLB_RELOAD = "NONE",
    parameter OPTION_OPERAND_WIDTH = 32,
    parameter OPTION_DMMU_SET_WIDTH = 6,
    parameter OPTION_DMMU_WAYS = 1
    )
   (
    input 				  clk,
    input 				  rst,

    input 				  enable_i,
    input [OPTION_OPERAND_WIDTH-1:0] 	  virt_addr_i,
    input [OPTION_OPERAND_WIDTH-1:0] 	  virt_addr_match_i,
    output [OPTION_OPERAND_WIDTH-1:0] 	  phys_addr_o,
    output 				  cache_inhibit_o,

    input 				  op_store_i,
    input 				  op_load_i,
    input 				  supervisor_mode_i,

    output 				  tlb_miss_o,
    output 				  pagefault_o,

    output reg 				  tlb_reload_req_o,
    output 				  tlb_reload_busy_o,
    input 				  tlb_reload_ack_i,
    output reg [OPTION_OPERAND_WIDTH-1:0] tlb_reload_addr_o,
    input [OPTION_OPERAND_WIDTH-1:0] 	  tlb_reload_data_i,
    output 				  tlb_reload_pagefault_o,
    input 				  tlb_reload_pagefault_clear_i,

    // SPR interface
    input [15:0] 			  spr_bus_addr_i,
    input 				  spr_bus_we_i,
    input 				  spr_bus_stb_i,
    input [OPTION_OPERAND_WIDTH-1:0] 	  spr_bus_dat_i,

    output [OPTION_OPERAND_WIDTH-1:0] 	  spr_bus_dat_o,
    output 				  spr_bus_ack_o
    );

   wire [OPTION_OPERAND_WIDTH-1:0]    dtlb_match_dout;
   wire [OPTION_DMMU_SET_WIDTH-1:0]   dtlb_match_addr;
   wire 			      dtlb_match_we;
   wire [OPTION_OPERAND_WIDTH-1:0]    dtlb_match_din;

   wire [OPTION_OPERAND_WIDTH-1:0]    dtlb_match_huge_dout;
   wire [OPTION_DMMU_SET_WIDTH-1:0]   dtlb_match_huge_addr;
   wire				      dtlb_match_huge_we;

   wire [OPTION_OPERAND_WIDTH-1:0]    dtlb_trans_dout;
   wire [OPTION_DMMU_SET_WIDTH-1:0]   dtlb_trans_addr;
   wire 			      dtlb_trans_we;
   wire [OPTION_OPERAND_WIDTH-1:0]    dtlb_trans_din;

   wire [OPTION_OPERAND_WIDTH-1:0]    dtlb_trans_huge_dout;
   wire [OPTION_DMMU_SET_WIDTH-1:0]   dtlb_trans_huge_addr;
   wire				      dtlb_trans_huge_we;

   reg 				      dtlb_match_reload_we;
   reg [OPTION_OPERAND_WIDTH-1:0]     dtlb_match_reload_din;

   reg 				      dtlb_trans_reload_we;
   reg [OPTION_OPERAND_WIDTH-1:0]     dtlb_trans_reload_din;

   wire 			      dtlb_match_spr_cs;
   reg 				      dtlb_match_spr_cs_r;
   wire 			      dtlb_trans_spr_cs;
   reg 				      dtlb_trans_spr_cs_r;

   wire 			      dmmucr_spr_cs;
   reg 				      dmmucr_spr_cs_r;
   reg [OPTION_OPERAND_WIDTH-1:0]     dmmucr;

   wire				      tlb_huge;

   wire				      tlb_miss;
   wire				      tlb_huge_miss;

   reg 				      tlb_reload_pagefault;
   reg 				      tlb_reload_huge;

   // ure: user read enable
   // uwe: user write enable
   // sre: supervisor read enable
   // swe: supervisor write enable
   wire 			      ure;
   wire 			      uwe;
   wire 			      sre;
   wire 			      swe;

   reg 				      spr_bus_ack;

   always @(posedge clk `OR_ASYNC_RST)
     if (rst)
       spr_bus_ack <= 0;
     else if (spr_bus_stb_i & spr_bus_addr_i[15:11] == 5'd1)
       spr_bus_ack <= 1;
     else
       spr_bus_ack <= 0;

   assign spr_bus_ack_o = spr_bus_ack & spr_bus_stb_i &
			  spr_bus_addr_i[15:11] == 5'd1;

   assign cache_inhibit_o = tlb_huge ? dtlb_trans_huge_dout[1] :
			     dtlb_trans_dout[1];
   assign ure = tlb_huge ? dtlb_trans_huge_dout[6] : dtlb_trans_dout[6];
   assign uwe = tlb_huge ? dtlb_trans_huge_dout[7] : dtlb_trans_dout[7];
   assign sre = tlb_huge ? dtlb_trans_huge_dout[8] : dtlb_trans_dout[8];
   assign swe = tlb_huge ? dtlb_trans_huge_dout[9] : dtlb_trans_dout[9];

   assign pagefault_o = (supervisor_mode_i ?
			!swe & op_store_i || !sre & op_load_i :
			!uwe & op_store_i || !ure & op_load_i) &
			!tlb_reload_busy_o;

   always @(posedge clk `OR_ASYNC_RST)
     if (rst) begin
	dtlb_match_spr_cs_r <= 0;
	dtlb_trans_spr_cs_r <= 0;
	dmmucr_spr_cs_r <= 0;
     end else begin
	dtlb_match_spr_cs_r <= dtlb_match_spr_cs;
	dtlb_trans_spr_cs_r <= dtlb_trans_spr_cs;
	dmmucr_spr_cs_r <= dmmucr_spr_cs;
     end

generate /* verilator lint_off WIDTH */
if (FEATURE_DMMU_HW_TLB_RELOAD == "ENABLED") begin
/* verilator lint_on WIDTH */
   assign dmmucr_spr_cs = spr_bus_stb_i &
			  spr_bus_addr_i == `OR1K_SPR_DMMUCR_ADDR;

   always @(posedge clk `OR_ASYNC_RST)
     if (rst)
       dmmucr <= 0;
     else if (dmmucr_spr_cs & spr_bus_we_i)
       dmmucr <= spr_bus_dat_i;

end else begin
   assign dmmucr_spr_cs = 0;
   always @(posedge clk)
     dmmucr <= 0;
end
endgenerate

   // TODO: optimize this
   assign dtlb_match_spr_cs = spr_bus_stb_i &
			      (spr_bus_addr_i >= `OR1K_SPR_DTLBW0MR0_ADDR) &
			      (spr_bus_addr_i < `OR1K_SPR_DTLBW0TR0_ADDR);
   assign dtlb_trans_spr_cs = spr_bus_stb_i &
			      (spr_bus_addr_i >= `OR1K_SPR_DTLBW0TR0_ADDR) &
			      (spr_bus_addr_i < `OR1K_SPR_DTLBW1MR0_ADDR);

   assign dtlb_match_addr = dtlb_match_spr_cs ?
			    spr_bus_addr_i[OPTION_DMMU_SET_WIDTH-1:0] :
			    virt_addr_i[13+(OPTION_DMMU_SET_WIDTH-1):13];
   assign dtlb_trans_addr = dtlb_trans_spr_cs ?
			    spr_bus_addr_i[OPTION_DMMU_SET_WIDTH-1:0] :
			    virt_addr_i[13+(OPTION_DMMU_SET_WIDTH-1):13];

   assign dtlb_match_we = dtlb_match_spr_cs & spr_bus_we_i |
			  dtlb_match_reload_we;
   assign dtlb_trans_we = dtlb_trans_spr_cs & spr_bus_we_i |
			  dtlb_trans_reload_we;

   assign dtlb_match_din = dtlb_match_reload_we ? dtlb_match_reload_din :
			   spr_bus_dat_i;
   assign dtlb_trans_din = dtlb_trans_reload_we ? dtlb_trans_reload_din :
			   spr_bus_dat_i;

   assign dtlb_match_huge_addr = virt_addr_i[24+(OPTION_DMMU_SET_WIDTH-1):24];
   assign dtlb_trans_huge_addr = virt_addr_i[24+(OPTION_DMMU_SET_WIDTH-1):24];

   assign dtlb_match_huge_we = dtlb_match_reload_we & tlb_reload_huge;
   assign dtlb_trans_huge_we = dtlb_trans_reload_we & tlb_reload_huge;

   assign spr_bus_dat_o = dtlb_match_spr_cs_r ? dtlb_match_dout :
			  dtlb_trans_spr_cs_r ? dtlb_trans_dout :
			  dmmucr_spr_cs_r ? dmmucr : 0;

   assign tlb_huge = &dtlb_match_huge_dout[1:0]; // huge & valid

   assign tlb_miss = dtlb_match_dout[31:13] != virt_addr_match_i[31:13] |
		     !dtlb_match_dout[0];  // valid bit

   assign tlb_huge_miss = dtlb_match_huge_dout[31:24] !=
			  virt_addr_match_i[31:24] | !dtlb_match_huge_dout[0];

   assign tlb_miss_o = (tlb_miss & !tlb_huge | tlb_huge_miss & tlb_huge) &
		       !tlb_reload_pagefault;

   assign phys_addr_o = tlb_huge ?
			{dtlb_trans_huge_dout[31:24], virt_addr_match_i[23:0]} :
			{dtlb_trans_dout[31:13], virt_addr_match_i[12:0]};

generate /* verilator lint_off WIDTH */
if (FEATURE_DMMU_HW_TLB_RELOAD == "ENABLED") begin
   /* verilator lint_on WIDTH */

   // Hardware TLB reload
   // Compliant with the suggestion outlined in this thread:
   // http://lists.openrisc.net/pipermail/openrisc/2013-July/001806.html
   //
   // PTE layout:
   // | 31 ... 13 | 12 |  11  |   10  | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
   // |    PPN    | Reserved  |PRESENT| L | X | W | U | D | A |WOM|WBC|CI |CC |
   //
   // Where X/W/U maps into SWE/SRE/UWE/URE like this:
   // X | W | U    SWE | SRE | UWE | URE
   // ----------   ---------------------
   // x | 0 | 0  =  0  |  1  |  0  |  0
   // x | 0 | 1  =  0  |  1  |  0  |  1
   // x | 1 | 0  =  1  |  1  |  0  |  0
   // x | 1 | 1  =  1  |  1  |  1  |  1


   localparam TLB_IDLE		 	= 2'd0;
   localparam TLB_GET_PTE_POINTER	= 2'd1;
   localparam TLB_GET_PTE		= 2'd2;
   localparam TLB_READ			= 2'd3;

   reg [1:0] tlb_reload_state = TLB_IDLE;
   wire      do_reload;

   assign do_reload = enable_i & tlb_miss_o & (dmmucr[31:10] != 0) &
		      (op_load_i | op_store_i);

   assign tlb_reload_busy_o = enable_i & (tlb_reload_state != TLB_IDLE) | do_reload;

   assign tlb_reload_pagefault_o = tlb_reload_pagefault &
				    !tlb_reload_pagefault_clear_i;

   always @(posedge clk) begin
      if (tlb_reload_pagefault_clear_i)
	tlb_reload_pagefault <= 0;
      dtlb_trans_reload_we <= 0;
      dtlb_trans_reload_din <= 0;
      dtlb_match_reload_we <= 0;
      dtlb_match_reload_din <= 0;

      case (tlb_reload_state)
	TLB_IDLE: begin
	   tlb_reload_huge <= 0;
	   tlb_reload_req_o <= 0;
	   if (do_reload) begin
	      tlb_reload_req_o <= 1;
	      tlb_reload_addr_o <= {dmmucr[31:10],
				    virt_addr_match_i[31:24], 2'b00};
	      tlb_reload_state <= TLB_GET_PTE_POINTER;
	   end
	end

	//
	// Here we get the pointer to the PTE table, next is to fetch
	// the actual pte from the offset in the table.
	// The offset is calculated by:
	// ((virt_addr_match >> PAGE_BITS) & (PTE_CNT-1)) << 2
	// Where PAGE_BITS is 13 (8 kb page) and PTE_CNT is 2048
	// (number of PTEs in the PTE table)
	//
	TLB_GET_PTE_POINTER: begin
	   tlb_reload_huge <= 0;
	   if (tlb_reload_ack_i) begin
	      if (tlb_reload_data_i[31:13] == 0) begin
		 tlb_reload_pagefault <= 1;
		 tlb_reload_req_o <= 0;
		 tlb_reload_state <= TLB_IDLE;
	      end else if (tlb_reload_data_i[9]) begin
		 tlb_reload_huge <= 1;
		 tlb_reload_req_o <= 0;
		 tlb_reload_state <= TLB_GET_PTE;
	      end else begin
		 tlb_reload_addr_o <= {tlb_reload_data_i[31:13],
				       virt_addr_match_i[23:13], 2'b00};
		 tlb_reload_state <= TLB_GET_PTE;
	      end
	   end
	end

	//
	// Here we get the actual PTE, left to do is to translate the
	// PTE data into our translate and match registers.
	//
	TLB_GET_PTE: begin
	   if (tlb_reload_ack_i) begin
	      tlb_reload_req_o <= 0;
	      // Check PRESENT bit
	      if (!tlb_reload_data_i[10]) begin
		 tlb_reload_pagefault <= 1;
		 tlb_reload_state <= TLB_IDLE;
	      end else begin
		 // Translate register generation.
		 // PPN
		 dtlb_trans_reload_din[31:13] <= tlb_reload_data_i[31:13];
		 // SWE = W
		 dtlb_trans_reload_din[9] <= tlb_reload_data_i[7];
		 // SRE = 1
		 dtlb_trans_reload_din[8] <= 1'b1;
		 // UWE = W & U
		 dtlb_trans_reload_din[7] <= tlb_reload_data_i[7] &
					      tlb_reload_data_i[6];
		 // URE = U
		 dtlb_trans_reload_din[6] <= tlb_reload_data_i[6];
		 // Dirty, Accessed, Weakly-Ordered-Memory, Writeback cache,
		 // Cache inhibit, Cache coherent
		 dtlb_trans_reload_din[5:0] <= tlb_reload_data_i[5:0];
		 dtlb_trans_reload_we <= 1;

		 // Match register generation.
		 // VPN
		 dtlb_match_reload_din[31:13] <= virt_addr_match_i[31:13];
		 // Valid
		 dtlb_match_reload_din[0] <= 1;
		 dtlb_match_reload_we <= 1;

		 tlb_reload_state <= TLB_READ;
	      end
	   end
	end

	// Let the just written values propagate out on the read ports
	TLB_READ: begin
	   tlb_reload_state <= TLB_IDLE;
	end

	default:
	  tlb_reload_state <= TLB_IDLE;
      endcase

      // Abort if enable deasserts in the middle of a reload
      if (!enable_i | (dmmucr[31:10] == 0))
	tlb_reload_state <= TLB_IDLE;

   end
end else begin // if (FEATURE_DMMU_HW_TLB_RELOAD == "ENABLED")
   assign tlb_reload_pagefault_o = 0;
   assign tlb_reload_busy_o = 0;
   always @(posedge clk) begin
      tlb_reload_req_o <= 0;
      tlb_reload_addr_o <= 0;
      tlb_reload_pagefault <= 0;
      dtlb_trans_reload_we <= 0;
      dtlb_trans_reload_din <= 0;
      dtlb_match_reload_we <= 0;
      dtlb_match_reload_din <= 0;
   end
end
endgenerate

   // DTLB match registers
   mor1kx_true_dpram_sclk
     #(
       .ADDR_WIDTH(OPTION_DMMU_SET_WIDTH),
       .DATA_WIDTH(OPTION_OPERAND_WIDTH)
       )
   dtlb_match_regs
     (
      // Outputs
      .dout_a				(dtlb_match_dout),
      .dout_b				(dtlb_match_huge_dout),
      // Inputs
      .clk				(clk),
      .addr_a				(dtlb_match_addr),
      .we_a				(dtlb_match_we),
      .din_a				(dtlb_match_din),
      .addr_b				(dtlb_match_huge_addr),
      .we_b				(dtlb_match_huge_we),
      .din_b				(dtlb_match_reload_din)
      );


   // DTLB translate registers
   mor1kx_true_dpram_sclk
     #(
       .ADDR_WIDTH(OPTION_DMMU_SET_WIDTH),
       .DATA_WIDTH(OPTION_OPERAND_WIDTH)
       )
   dtlb_translate_regs
     (
      // Outputs
      .dout_a				(dtlb_trans_dout),
      .dout_b				(dtlb_trans_huge_dout),
      // Inputs
      .clk				(clk),
      .addr_a				(dtlb_trans_addr),
      .we_a				(dtlb_trans_we),
      .din_a				(dtlb_trans_din),
      .addr_b				(dtlb_trans_huge_addr),
      .we_b				(dtlb_trans_huge_we),
      .din_b				(dtlb_trans_reload_din)
      );

endmodule // mor1kx_dmmu
