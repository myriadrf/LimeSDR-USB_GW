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


// $Id: //acds/rel/15.1/ip/merlin/altera_merlin_router/altera_merlin_router.sv.terp#1 $
// $Revision: #1 $
// $Date: 2015/08/09 $
// $Author: swbranch $

// -------------------------------------------------------
// Merlin Router
//
// Asserts the appropriate one-hot encoded channel based on 
// either (a) the address or (b) the dest id. The DECODER_TYPE
// parameter controls this behaviour. 0 means address decoder,
// 1 means dest id decoder.
//
// In the case of (a), it also sets the destination id.
// -------------------------------------------------------

`timescale 1 ns / 1 ns

module lms_ctr_mm_interconnect_0_router_default_decode
  #(
     parameter DEFAULT_CHANNEL = 4,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 5 
   )
  (output [81 - 78 : 0] default_destination_id,
   output [11-1 : 0] default_wr_channel,
   output [11-1 : 0] default_rd_channel,
   output [11-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[81 - 78 : 0];

  generate
    if (DEFAULT_CHANNEL == -1) begin : no_default_channel_assignment
      assign default_src_channel = '0;
    end
    else begin : default_channel_assignment
      assign default_src_channel = 11'b1 << DEFAULT_CHANNEL;
    end
  endgenerate

  generate
    if (DEFAULT_RD_CHANNEL == -1) begin : no_default_rw_channel_assignment
      assign default_wr_channel = '0;
      assign default_rd_channel = '0;
    end
    else begin : default_rw_channel_assignment
      assign default_wr_channel = 11'b1 << DEFAULT_WR_CHANNEL;
      assign default_rd_channel = 11'b1 << DEFAULT_RD_CHANNEL;
    end
  endgenerate

endmodule


module lms_ctr_mm_interconnect_0_router
(
    // -------------------
    // Clock & Reset
    // -------------------
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                       sink_valid,
    input  [95-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output                          src_valid,
    output reg [95-1    : 0] src_data,
    output reg [11-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    // -------------------------------------------------------
    // Local parameters and variables
    // -------------------------------------------------------
    localparam PKT_ADDR_H = 52;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 81;
    localparam PKT_DEST_ID_L = 78;
    localparam PKT_PROTECTION_H = 85;
    localparam PKT_PROTECTION_L = 83;
    localparam ST_DATA_W = 95;
    localparam ST_CHANNEL_W = 11;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 55;
    localparam PKT_TRANS_READ  = 56;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    // -------------------------------------------------------
    // Figure out the number of bits to mask off for each slave span
    // during address decoding
    // -------------------------------------------------------
    localparam PAD0 = log2ceil(64'h10000 - 64'h8000); 
    localparam PAD1 = log2ceil(64'h11000 - 64'h10800); 
    localparam PAD2 = log2ceil(64'h11020 - 64'h11000); 
    localparam PAD3 = log2ceil(64'h11040 - 64'h11020); 
    localparam PAD4 = log2ceil(64'h11060 - 64'h11040); 
    localparam PAD5 = log2ceil(64'h11080 - 64'h11060); 
    localparam PAD6 = log2ceil(64'h110a0 - 64'h11080); 
    localparam PAD7 = log2ceil(64'h110b0 - 64'h110a0); 
    localparam PAD8 = log2ceil(64'h110c0 - 64'h110b0); 
    localparam PAD9 = log2ceil(64'h110d0 - 64'h110c0); 
    localparam PAD10 = log2ceil(64'h110d8 - 64'h110d0); 
    // -------------------------------------------------------
    // Work out which address bits are significant based on the
    // address range of the slaves. If the required width is too
    // large or too small, we use the address field width instead.
    // -------------------------------------------------------
    localparam ADDR_RANGE = 64'h110d8;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam RG = RANGE_ADDR_WIDTH-1;
    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;

      reg [PKT_ADDR_W-1 : 0] address;
      always @* begin
        address = {PKT_ADDR_W{1'b0}};
        address [REAL_ADDRESS_RANGE:0] = sink_data[OPTIMIZED_ADDR_H : PKT_ADDR_L];
      end   

    // -------------------------------------------------------
    // Pass almost everything through, untouched
    // -------------------------------------------------------
    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [11-1 : 0] default_src_channel;




    // -------------------------------------------------------
    // Write and read transaction signals
    // -------------------------------------------------------
    wire read_transaction;
    assign read_transaction  = sink_data[PKT_TRANS_READ];


    lms_ctr_mm_interconnect_0_router_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

        // --------------------------------------------------
        // Address Decoder
        // Sets the channel and destination ID based on the address
        // --------------------------------------------------

    // ( 0x8000 .. 0x10000 )
    if ( {address[RG:PAD0],{PAD0{1'b0}}} == 17'h8000   ) begin
            src_channel = 11'b00000010000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 5;
    end

    // ( 0x10800 .. 0x11000 )
    if ( {address[RG:PAD1],{PAD1{1'b0}}} == 17'h10800   ) begin
            src_channel = 11'b00000001000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 4;
    end

    // ( 0x11000 .. 0x11020 )
    if ( {address[RG:PAD2],{PAD2{1'b0}}} == 17'h11000   ) begin
            src_channel = 11'b10000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 6;
    end

    // ( 0x11020 .. 0x11040 )
    if ( {address[RG:PAD3],{PAD3{1'b0}}} == 17'h11020   ) begin
            src_channel = 11'b01000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 7;
    end

    // ( 0x11040 .. 0x11060 )
    if ( {address[RG:PAD4],{PAD4{1'b0}}} == 17'h11040   ) begin
            src_channel = 11'b00100000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 8;
    end

    // ( 0x11060 .. 0x11080 )
    if ( {address[RG:PAD5],{PAD5{1'b0}}} == 17'h11060   ) begin
            src_channel = 11'b00010000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 3;
    end

    // ( 0x11080 .. 0x110a0 )
    if ( {address[RG:PAD6],{PAD6{1'b0}}} == 17'h11080   ) begin
            src_channel = 11'b00000000010;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 1;
    end

    // ( 0x110a0 .. 0x110b0 )
    if ( {address[RG:PAD7],{PAD7{1'b0}}} == 17'h110a0   ) begin
            src_channel = 11'b00001000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 2;
    end

    // ( 0x110b0 .. 0x110c0 )
    if ( {address[RG:PAD8],{PAD8{1'b0}}} == 17'h110b0  && read_transaction  ) begin
            src_channel = 11'b00000100000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 9;
    end

    // ( 0x110c0 .. 0x110d0 )
    if ( {address[RG:PAD9],{PAD9{1'b0}}} == 17'h110c0   ) begin
            src_channel = 11'b00000000001;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
    end

    // ( 0x110d0 .. 0x110d8 )
    if ( {address[RG:PAD10],{PAD10{1'b0}}} == 17'h110d0  && read_transaction  ) begin
            src_channel = 11'b00000000100;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 10;
    end

end


    // --------------------------------------------------
    // Ceil(log2()) function
    // --------------------------------------------------
    function integer log2ceil;
        input reg[65:0] val;
        reg [65:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule


