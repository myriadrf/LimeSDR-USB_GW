/*
* wb_rom Generic on-chip ROM with Wishbone interface
* Copyright (C) 2015  Olof Kindgren, olof.kindgren@gmail.com
*
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/
module wb_bootrom
  #(parameter DEPTH = 0,             // Memory size in bytes
    parameter WB_AW = $clog2(DEPTH), // Wishbone address width
    parameter MEMFILE = "")          // Initialization file
  (input 	     wb_clk_i,
   input 	     wb_rst_i,
   input [31:0]      wb_adr_i,
   input 	     wb_cyc_i,
   input 	     wb_stb_i,
   output reg [31:0] wb_dat_o,
   output reg 	     wb_ack_o);

   reg [31:0] 	 mem[0:DEPTH/4-1];
   
   wire [WB_AW-1:0] adr = wb_adr_i[WB_AW-1:2];
   
   always @(posedge wb_clk_i) begin
      wb_ack_o <= wb_stb_i & wb_cyc_i & !wb_ack_o;
      wb_dat_o <= mem[adr];
   end
		     
   initial
     if(MEMFILE == "")
       $display("%m : Warning! Memory is not initialized");
     else begin
	$display("Preloading boot ROM from %s", MEMFILE);
	$readmemh(MEMFILE, mem);
     end

endmodule
