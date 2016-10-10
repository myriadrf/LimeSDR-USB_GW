// (C) 2001-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/15.1/ip/merlin/altera_customins_slave_translator/altera_customins_slave_translator.sv#1 $
// $Revision: #1 $
// $Date: 2015/08/09 $
// $Author: swbranch $
// --------------------------------------
// Custom instruction slave translator
// --------------------------------------
`timescale 1 ns / 1 ns

module altera_customins_slave_translator
#(
    parameter N_WIDTH          = 8,
              USE_DONE         = 1,
              NUM_FIXED_CYCLES = 2
)
(
    // --------------------------------------
    // Slave
    // --------------------------------------
    input  wire [31:0] ci_slave_dataa,   
    input  wire [31:0] ci_slave_datab,   
    output wire [31:0] ci_slave_result,  
    input  wire [7:0]  ci_slave_n,       
    input  wire        ci_slave_readra,  
    input  wire        ci_slave_readrb,  
    input  wire        ci_slave_writerc, 
    input  wire [4:0]  ci_slave_a,       
    input  wire [4:0]  ci_slave_b,       
    input  wire [4:0]  ci_slave_c,
    input  wire [31:0] ci_slave_ipending,
    input  wire        ci_slave_estatus,

    input  wire        ci_slave_clk,
    input  wire        ci_slave_clken,
    input  wire        ci_slave_reset,
    input  wire        ci_slave_reset_req,
    input  wire        ci_slave_start,
    output wire        ci_slave_done,

    // --------------------------------------
    // Master
    // --------------------------------------
    output wire [31:0] ci_master_dataa, 
    output wire [31:0] ci_master_datab, 
    input  wire [31:0] ci_master_result,
    output wire [N_WIDTH-1:0]  ci_master_n,       
    output wire        ci_master_readra, 
    output wire        ci_master_readrb, 
    output wire        ci_master_writerc,
    output wire [4:0]  ci_master_a,      
    output wire [4:0]  ci_master_b,      
    output wire [4:0]  ci_master_c,
    output wire [31:0] ci_master_ipending,
    output wire        ci_master_estatus,

    output wire        ci_master_clk,
    output wire        ci_master_clken,
    output wire        ci_master_reset,
    output wire        ci_master_reset_req,
    output wire        ci_master_start,
    input  wire        ci_master_done
       
);
    localparam COUNTER_WIDTH = $clog2(NUM_FIXED_CYCLES);

    wire                     gen_done;
    reg  [COUNTER_WIDTH-1:0] count;
    reg                      running;
    reg                      reg_start;

    assign ci_slave_result   = ci_master_result;
    assign ci_master_writerc = ci_slave_writerc;
    assign ci_master_dataa   = ci_slave_dataa;
    assign ci_master_readra  = ci_slave_readra;
    assign ci_master_datab   = ci_slave_datab;
    assign ci_master_readrb  = ci_slave_readrb;
    assign ci_master_b = ci_slave_b;
    assign ci_master_c = ci_slave_c;
    assign ci_master_a = ci_slave_a;
    assign ci_master_ipending = ci_slave_ipending;
    assign ci_master_estatus = ci_slave_estatus;

    assign ci_master_clk    = ci_slave_clk;
    assign ci_master_clken  = ci_slave_clken;
    assign ci_master_reset  = ci_slave_reset;
    assign ci_master_reset_req = ci_slave_reset_req;

    // --------------------------------------
    // Is there something we need to do if the master does not 
    // have start?
    // --------------------------------------
    assign ci_master_start  = ci_slave_start;

    // --------------------------------------
    // Create the done signal if the slave does not drive it.
    // 
    // For num_cycles = 2, this is just the registered start.
    // Anything larger and we use a down-counter.
    // --------------------------------------
    assign ci_slave_done = (USE_DONE == 1) ? ci_master_done : gen_done;
    assign gen_done      = (NUM_FIXED_CYCLES == 2) ? reg_start : (count == 0);

    always @(posedge ci_slave_clk, posedge ci_slave_reset) begin
        if (ci_slave_reset)
            reg_start <= 0;
        else if (ci_slave_clken)
            reg_start <= ci_slave_start;
    end

    always @(posedge ci_slave_clk, posedge ci_slave_reset) begin
        if (ci_slave_reset) begin
            running <= 0;
            count   <= NUM_FIXED_CYCLES - 2;
        end 
        else if (ci_slave_clken) begin
            if (ci_slave_start)
                running <= 1;
            if (running)
                count   <= count - 1;
            if (ci_slave_done) begin
                running <= 0;
                count   <= NUM_FIXED_CYCLES - 2;
            end
        end
    end

    // --------------------------------------
    // Opcode base addresses must be a multiple of their span,
    // just like base addresses. This simplifies the following
    // assignment (just drop the high order bits)
    // --------------------------------------
    assign ci_master_n = ci_slave_n[N_WIDTH-1:0];


endmodule
