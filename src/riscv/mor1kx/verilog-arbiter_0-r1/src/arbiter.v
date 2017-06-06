/**
 * Module: arbiter
 *
 * Description:
 *  A look ahead, round-robing parametrized arbiter.
 *
 * <> request
 *  each bit is controlled by an actor and each actor can 'request' ownership
 *  of the shared resource by bring high its request bit.
 *
 * <> grant
 *  when an actor has been given ownership of shared resource its 'grant' bit
 *  is driven high
 *
 * <> select
 *  binary representation of the grant signal (optional use)
 *
 * <> active
 *  is brought high by the arbiter when (any) actor has been given ownership
 *  of shared resource.
 *
 *
 * Created: Sat Jun  1 20:26:44 EDT 2013
 *
 * Author:  Berin Martini // berin.martini@gmail.com
 */
`ifndef _arbiter_ `define _arbiter_


module arbiter
  #(parameter
    NUM_PORTS = 6)
   (input                               clk,
    input                               rst,
    input      [NUM_PORTS-1:0]          request,
    output reg [NUM_PORTS-1:0]          grant,
    output reg [$clog2(NUM_PORTS)-1:0]  select,
    output reg                          active
);

    /**
     * Local parameters
     */

    localparam WRAP_LENGTH = 2*NUM_PORTS;


    // Find First 1 - Start from MSB and count downwards, returns 0 when no
    // bit set
    function [$clog2(NUM_PORTS)-1:0] ff1;
        input [NUM_PORTS-1:0] in;
        integer i;
        begin
            ff1 = 0;
            for (i = NUM_PORTS-1; i >= 0; i=i-1) begin
                if (in[i])
                    ff1 = i;
            end
        end
    endfunction


`ifdef VERBOSE
    initial $display("Bus arbiter with %d units", NUM_PORTS);
`endif


    /**
     * Internal signals
     */

    integer                 yy;

    wire                    next;
    wire [NUM_PORTS-1:0]    order;

    reg  [NUM_PORTS-1:0]    token;
    wire [NUM_PORTS-1:0]    token_lookahead [NUM_PORTS-1:0];
    wire [WRAP_LENGTH-1:0]  token_wrap;


    /**
     * Implementation
     */

    assign token_wrap   = {token, token};

    assign next         = ~|(token & request);


    always @(posedge clk)
        grant <= token & request;


    always @(posedge clk)
        select <= ff1(token & request);


    always @(posedge clk)
        active <= |(token & request);


    always @(posedge clk)
        if (rst) token <= 'b1;
        else if (next) begin

            for (yy = 0; yy < NUM_PORTS; yy = yy + 1) begin : TOKEN_

                if (order[yy]) begin
                    token <= token_lookahead[yy];
                end
            end
        end


    genvar xx;
    generate
        for (xx = 0; xx < NUM_PORTS; xx = xx + 1) begin : ORDER_

            assign token_lookahead[xx]  = token_wrap[xx +: NUM_PORTS];

            assign order[xx]            = |(token_lookahead[xx] & request);

        end
    endgenerate


endmodule

`endif //  `ifndef _arbiter_
