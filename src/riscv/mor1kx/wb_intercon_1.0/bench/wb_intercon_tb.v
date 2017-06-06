module wb_intercon_tb;

   localparam WB_ARB_NUM_MASTERS = 5;
   
   reg	   wb_clk = 1'b1;

   reg	   wb_mux_rst = 1'b1;
   wire    wb_mux_done;
   
   reg	   wb_arb_rst = 1'b1;
   wire    wb_arb_done;

   reg	   wb_upz_rst = 1'b1;
   wire    wb_upz_done;

   vlog_tb_utils vlog_tb_utils0();

   wb_mux_tb
   wb_mux_tb0
     (.wb_clk_i (wb_clk),
      .wb_rst_i (wb_mux_rst),
      .done     (wb_mux_done));
   
   wb_arbiter_tb
     #(.NUM_MASTERS (WB_ARB_NUM_MASTERS))
   wb_arbiter_tb0
     (.wb_clk_i (wb_clk),
      .wb_rst_i (wb_arb_rst),
      .done     (wb_arb_done));

   wb_upsizer_tb wb_upz_tb
     (.wb_clk_i (wb_clk),
      .wb_rst_i (wb_upz_rst),
      .done     (wb_upz_done));
   
   always #5 wb_clk <= ~wb_clk;

   task mux_test;
      begin
	 $display("==Running wb_mux tests==");
	 #100 wb_mux_rst <= 0;
	 @(posedge wb_mux_done);
	 #100 $display("==wb_mux tests done==");
	 wb_mux_rst <= 1;
      end
   endtask
   
   task arbiter_test;
      begin
	 $display("==Running wb_arbiter tests==");
	 wb_arb_rst <= 0;
	 @(posedge wb_arb_done);
	 #100 $display("==wb_arbiter tests done==");
	 wb_arb_rst <= 1;
      end
   endtask
   
   task upsizer_test;
      begin
	 $display("==Running wb_upsizer tests==");
	 wb_upz_rst <= 0;
	 @(posedge wb_upz_done);
	 #100 $display("==wb_upsizer tests done==");
	 wb_upz_rst <= 1;
      end
   endtask
   
   initial begin

      mux_test;
      arbiter_test;
      upsizer_test;

      #3 $finish;
   end
      
   
endmodule // orpsoc_tb
