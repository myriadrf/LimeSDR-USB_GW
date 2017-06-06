/*  ISC License
 *
 *  Common verilog constants for the Wishbone protocol
 *
 *  Copyright (C) 2016  Olof Kindgren <olof.kindgren@gmail.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

localparam CLASSIC_CYCLE = 1'b0;
localparam BURST_CYCLE   = 1'b1;

localparam READ  = 1'b0;
localparam WRITE = 1'b1;

localparam [2:0]
  CTI_CLASSIC      = 3'b000,
  CTI_CONST_BURST  = 3'b001,
  CTI_INC_BURST    = 3'b010,
  CTI_END_OF_BURST = 3'b111;

localparam [1:0]
  BTE_LINEAR  = 2'd0,
  BTE_WRAP_4  = 2'd1,
  BTE_WRAP_8  = 2'd2,
  BTE_WRAP_16 = 2'd3;
