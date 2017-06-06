/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE rev.B2 compliant I2C Master bit-controller        ////
////                                                             ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/projects/i2c/    ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: i2c_master_bit_ctrl.v,v 1.14 2009-01-20 10:25:29 rherveille Exp $
//
//  $Date: 2009-01-20 10:25:29 $
//  $Revision: 1.14 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: $
//               Revision 1.14  2009/01/20 10:25:29  rherveille
//               Added clock synchronization logic
//               Fixed slave_wait signal
//
//               Revision 1.13  2009/01/19 20:29:26  rherveille
//               Fixed synopsys miss spell (synopsis)
//               Fixed cr[0] register width
//               Fixed ! usage instead of ~
//               Fixed bit controller parameter width to 18bits
//
//               Revision 1.12  2006/09/04 09:08:13  rherveille
//               fixed short scl high pulse after clock stretch
//               fixed slave model not returning correct '(n)ack' signal
//
//               Revision 1.11  2004/05/07 11:02:26  rherveille
//               Fixed a bug where the core would signal an arbitration lost (AL bit set), when another master controls the bus and the other master generates a STOP bit.
//
//               Revision 1.10  2003/08/09 07:01:33  rherveille
//               Fixed a bug in the Arbitration Lost generation caused by delay on the (external) sda line.
//               Fixed a potential bug in the byte controller's host-acknowledge generation.
//
//               Revision 1.9  2003/03/10 14:26:37  rherveille
//               Fixed cmd_ack generation item (no bug).
//
//               Revision 1.8  2003/02/05 00:06:10  rherveille
//               Fixed a bug where the core would trigger an erroneous 'arbitration lost' interrupt after being reset, when the reset pulse width < 3 clk cycles.
//
//               Revision 1.7  2002/12/26 16:05:12  rherveille
//               Small code simplifications
//
//               Revision 1.6  2002/12/26 15:02:32  rherveille
//               Core is now a Multimaster I2C controller
//
//               Revision 1.5  2002/11/30 22:24:40  rherveille
//               Cleaned up code
//
//               Revision 1.4  2002/10/30 18:10:07  rherveille
//               Fixed some reported minor start/stop generation timing issuess.
//
//               Revision 1.3  2002/06/15 07:37:03  rherveille
//               Fixed a small timing bug in the bit controller.\nAdded verilog simulation environment.
//
//               Revision 1.2  2001/11/05 11:59:25  rherveille
//               Fixed wb_ack_o generation bug.
//               Fixed bug in the byte_controller statemachine.
//               Added headers.
//

//
/////////////////////////////////////
// Bit controller section
/////////////////////////////////////
//
// Translate simple commands into SCL/SDA transitions
// Each command has 5 states, A/B/C/D/idle
//
// start:	SCL	~~~~~~~~~~\____
//	SDA	~~~~~~~~\______
//		 x | A | B | C | D | i
//
// repstart	SCL	____/~~~~\___
//	SDA	__/~~~\______
//		 x | A | B | C | D | i
//
// stop	SCL	____/~~~~~~~~
//	SDA	==\____/~~~~~
//		 x | A | B | C | D | i
//
//- write	SCL	____/~~~~\____
//	SDA	==X=========X=
//		 x | A | B | C | D | i
//
//- read	SCL	____/~~~~\____
//	SDA	XXXX=====XXXX
//		 x | A | B | C | D | i
//

// Timing:     Normal mode      Fast mode
///////////////////////////////////////////////////////////////////////
// Fscl        100KHz           400KHz
// Th_scl      4.0us            0.6us   High period of SCL
// Tl_scl      4.7us            1.3us   Low period of SCL
// Tsu:sta     4.7us            0.6us   setup time for a repeated start condition
// Tsu:sto     4.0us            0.6us   setup time for a stop conditon
// Tbuf        4.7us            1.3us   Bus free time between a stop and start condition
//

`include "i2c_master_defines.v"

module i2c_master_bit_ctrl (
    input             clk,      // system clock
    input             rst,      // synchronous active high reset
    input             nReset,   // asynchronous active low reset
    input             ena,      // core enable signal

    input      [15:0] clk_cnt,  // clock prescale value

    input      [ 3:0] cmd,      // command (from byte controller)
    output reg        cmd_ack,  // command complete acknowledge
    output reg        busy,     // i2c bus busy
    output reg        al,       // i2c bus arbitration lost

    input             din,
    output reg        dout,

    input             scl_i,    // i2c clock line input
    output            scl_o,    // i2c clock line output
    output            scl_oen,  // i2c clock line output enable (active low)
    input             sda_i,    // i2c data line input
    output            sda_o,    // i2c data line output
    output            sda_oen,  // i2c data line output enable (active low)

    output reg        slave_adr_received,
    output reg [7:0]  slave_adr,
    input             master_mode,
    output reg        cmd_slave_ack,
    input [1:0]       slave_cmd ,
    input             sl_wait,
    output            slave_reset

);


    //
    // variable declarations
    //

    reg [ 1:0] cSCL, cSDA;      // capture SCL and SDA
    reg [ 2:0] fSCL, fSDA;      // SCL and SDA filter inputs
    reg        sSCL, sSDA;      // filtered and synchronized SCL and SDA inputs
    reg        dSCL, dSDA;      // delayed versions of sSCL and sSDA
    reg        dscl_oen;        // delayed scl_oen
    reg        sda_chk;         // check SDA output (Multi-master arbitration)
    reg        clk_en;          // clock generation signals
    reg        slave_wait;      // slave inserts wait states
    reg [15:0] cnt;             // clock divider counter (synthesis)
    reg [13:0] filter_cnt;      // clock divider for filter


    // state machine variable
    reg [17:0] c_state; // synopsys enum_state
    reg [4:0] 	      slave_state;
    //
    // module body
    //

    // whenever the slave is not ready it can delay the cycle by pulling SCL low
    // delay scl_oen
    always @(posedge clk)
      dscl_oen <= scl_oen;

    // slave_wait is asserted when master wants to drive SCL high, but the slave pulls it low
    // slave_wait remains asserted until the slave releases SCL
    always @(posedge clk or negedge nReset)
      if (!nReset) slave_wait <= 1'b0;
      else         slave_wait <= (scl_oen & ~dscl_oen & ~sSCL) | (slave_wait & ~sSCL);

    // master drives SCL high, but another master pulls it low
    // master start counting down its low cycle now (clock synchronization)
    wire scl_sync   = dSCL & ~sSCL & scl_oen;


    // generate clk enable signal
    always @(posedge clk or negedge nReset)
      if (~nReset)
      begin
          cnt    <= 16'h0;
          clk_en <= 1'b1;
      end
      else if (rst || ~|cnt || !ena || scl_sync)
      begin
          cnt    <= clk_cnt;
          clk_en <= 1'b1;
      end
      else if (slave_wait)
      begin
          cnt    <= cnt;
          clk_en <= 1'b0;
      end
      else
      begin
          cnt    <= cnt - 16'h1;
          clk_en <= 1'b0;
      end


    // generate bus status controller

    // capture SDA and SCL
    // reduce metastability risk
    always @(posedge clk or negedge nReset)
      if (!nReset)
      begin
          cSCL <= 2'b00;
          cSDA <= 2'b00;
      end
      else if (rst)
      begin
          cSCL <= 2'b00;
          cSDA <= 2'b00;
      end
      else
      begin
          cSCL <= {cSCL[0],scl_i};
          cSDA <= {cSDA[0],sda_i};
      end


    // filter SCL and SDA signals; (attempt to) remove glitches
    always @(posedge clk or negedge nReset)
      if      (!nReset     ) filter_cnt <= 14'h0;
      else if (rst || !ena ) filter_cnt <= 14'h0;
      else if (~|filter_cnt) filter_cnt <= clk_cnt >> 2; //16x I2C bus frequency
      else                   filter_cnt <= filter_cnt -1;


    always @(posedge clk or negedge nReset)
      if (!nReset)
      begin
          fSCL <= 3'b111;
          fSDA <= 3'b111;
      end
      else if (rst)
      begin
          fSCL <= 3'b111;
          fSDA <= 3'b111;
      end
      else if (~|filter_cnt)
      begin
          fSCL <= {fSCL[1:0],cSCL[1]};
          fSDA <= {fSDA[1:0],cSDA[1]};
      end


    // generate filtered SCL and SDA signals
    always @(posedge clk or negedge nReset)
      if (~nReset)
      begin
          sSCL <= 1'b1;
          sSDA <= 1'b1;

          dSCL <= 1'b1;
          dSDA <= 1'b1;
      end
      else if (rst)
      begin
          sSCL <= 1'b1;
          sSDA <= 1'b1;

          dSCL <= 1'b1;
          dSDA <= 1'b1;
      end
      else
      begin
          sSCL <= &fSCL[2:1] | &fSCL[1:0] | (fSCL[2] & fSCL[0]);
          sSDA <= &fSDA[2:1] | &fSDA[1:0] | (fSDA[2] & fSDA[0]);

          dSCL <= sSCL;
          dSDA <= sSDA;
      end

    // detect start condition => detect falling edge on SDA while SCL is high
    // detect stop condition => detect rising edge on SDA while SCL is high
    reg sta_condition;
    reg sto_condition;

    always @(posedge clk or negedge nReset)
      if (~nReset)
      begin
          sta_condition <= 1'b0;
          sto_condition <= 1'b0;
      end
      else if (rst)
      begin
          sta_condition <= 1'b0;
          sto_condition <= 1'b0;
      end
      else
      begin
          sta_condition <= ~sSDA &  dSDA & sSCL;
          sto_condition <=  sSDA & ~dSDA & sSCL;
      end


    // generate i2c bus busy signal
    always @(posedge clk or negedge nReset)
      if      (!nReset) busy <= 1'b0;
      else if (rst    ) busy <= 1'b0;
      else              busy <= (sta_condition | busy) & ~sto_condition;


    // generate arbitration lost signal
    // aribitration lost when:
    // 1) master drives SDA high, but the i2c bus is low
    // 2) stop detected while not requested
    reg cmd_stop;
    always @(posedge clk or negedge nReset)
      if (~nReset)
          cmd_stop <= 1'b0;
      else if (rst)
          cmd_stop <= 1'b0;
      else if (clk_en)
          cmd_stop <= cmd == `I2C_CMD_STOP;

    always @(posedge clk or negedge nReset)
      if (~nReset)
          al <= 1'b0;
      else if (rst)
          al <= 1'b0;
      else
          al <= (sda_chk & ~sSDA & sda_oen) | (|c_state & sto_condition & ~cmd_stop);


    // generate dout signal (store SDA on rising edge of SCL)
    always @(posedge clk)
      if (sSCL & ~dSCL) dout <= sSDA;


    // generate statemachine

    // nxt_state decoder
    parameter [17:0] idle    = 18'b0_0000_0000_0000_0000;
    parameter [17:0] start_a = 18'b0_0000_0000_0000_0001;
    parameter [17:0] start_b = 18'b0_0000_0000_0000_0010;
    parameter [17:0] start_c = 18'b0_0000_0000_0000_0100;
    parameter [17:0] start_d = 18'b0_0000_0000_0000_1000;
    parameter [17:0] start_e = 18'b0_0000_0000_0001_0000;
    parameter [17:0] stop_a  = 18'b0_0000_0000_0010_0000;
    parameter [17:0] stop_b  = 18'b0_0000_0000_0100_0000;
    parameter [17:0] stop_c  = 18'b0_0000_0000_1000_0000;
    parameter [17:0] stop_d  = 18'b0_0000_0001_0000_0000;
    parameter [17:0] rd_a    = 18'b0_0000_0010_0000_0000;
    parameter [17:0] rd_b    = 18'b0_0000_0100_0000_0000;
    parameter [17:0] rd_c    = 18'b0_0000_1000_0000_0000;
    parameter [17:0] rd_d    = 18'b0_0001_0000_0000_0000;
    parameter [17:0] wr_a    = 18'b0_0010_0000_0000_0000;
    parameter [17:0] wr_b    = 18'b0_0100_0000_0000_0000;
    parameter [17:0] wr_c    = 18'b0_1000_0000_0000_0000;
    parameter [17:0] wr_d    = 18'b1_0000_0000_0000_0000;

    reg scl_oen_master ;
    reg sda_oen_master ;
    reg sda_oen_slave;
    reg scl_oen_slave;

    always @(posedge clk or negedge nReset)
      if (!nReset)
      begin
          c_state <= idle;
          cmd_ack <= 1'b0;
          scl_oen_master <=  1'b1;
          sda_oen_master <=  1'b1;
          sda_chk <= 1'b0;
      end
      else if (rst | al)
      begin
          c_state <= idle;
          cmd_ack <= 1'b0;
          scl_oen_master <=  1'b1;
          sda_oen_master <=  1'b1;
          sda_chk <= 1'b0;
      end
      else
      begin
          cmd_ack   <= 1'b0; // default no command acknowledge + assert cmd_ack only 1clk cycle

          if (clk_en)
              case (c_state) // synopsys full_case parallel_case
                    // idle state
                    idle:
                    begin
                        case (cmd) // synopsys full_case parallel_case
                             `I2C_CMD_START: c_state <= start_a;
                             `I2C_CMD_STOP:  c_state <= stop_a;
                             `I2C_CMD_WRITE: c_state <= wr_a;
                             `I2C_CMD_READ:  c_state <= rd_a;
                             default:        c_state <= idle;
                        endcase

                        scl_oen_master <= scl_oen_master; // keep SCL in same state
                        sda_oen_master <= sda_oen_master; // keep SDA in same state
                        sda_chk <= 1'b0;    // don't check SDA output
                    end

                    // start
                    start_a:
                    begin
                        c_state <= start_b;
                        scl_oen_master <= scl_oen_master; // keep SCL in same state
                        sda_oen_master <= 1'b1;    // set SDA high
                        sda_chk <= 1'b0;    // don't check SDA output
                    end

                    start_b:
                    begin
                        c_state <= start_c;
                        scl_oen_master <= 1'b1; // set SCL high
                        sda_oen_master <= 1'b1; // keep SDA high
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    start_c:
                    begin
                        c_state <= start_d;
                        scl_oen_master <= 1'b1; // keep SCL high
                        sda_oen_master <= 1'b0; // set SDA low
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    start_d:
                    begin
                        c_state <= start_e;
                        scl_oen_master <= 1'b1; // keep SCL high
                        sda_oen_master <= 1'b0; // keep SDA low
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    start_e:
                    begin
                        c_state <= idle;
                        cmd_ack <= 1'b1;
                        scl_oen_master <= 1'b0; // set SCL low
                        sda_oen_master <= 1'b0; // keep SDA low
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    // stop
                    stop_a:
                    begin
                        c_state <= stop_b;
                        scl_oen_master <= 1'b0; // keep SCL low
                        sda_oen_master <= 1'b0; // set SDA low
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    stop_b:
                    begin
                        c_state <= stop_c;
                        scl_oen_master <= 1'b1; // set SCL high
                        sda_oen_master <= 1'b0; // keep SDA low
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    stop_c:
                    begin
                        c_state <= stop_d;
                        scl_oen_master <= 1'b1; // keep SCL high
                        sda_oen_master <= 1'b0; // keep SDA low
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    stop_d:
                    begin
                        c_state <= idle;
                        cmd_ack <= 1'b1;
                        scl_oen_master <= 1'b1; // keep SCL high
                        sda_oen_master <= 1'b1; // set SDA high
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    // read
                    rd_a:
                    begin
                        c_state <= rd_b;
                        scl_oen_master <= 1'b0; // keep SCL low
                        sda_oen_master <= 1'b1; // tri-state SDA
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    rd_b:
                    begin
                        c_state <= rd_c;
                        scl_oen_master <= 1'b1; // set SCL high
                        sda_oen_master <= 1'b1; // keep SDA tri-stated
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    rd_c:
                    begin
                        c_state <= rd_d;
                        scl_oen_master <= 1'b1; // keep SCL high
                        sda_oen_master <= 1'b1; // keep SDA tri-stated
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    rd_d:
                    begin
                        c_state <= idle;
                        cmd_ack <= 1'b1;
                        scl_oen_master <= 1'b0; // set SCL low
                        sda_oen_master <= 1'b1; // keep SDA tri-stated
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    // write
                    wr_a:
                    begin
                        c_state <= wr_b;
                        scl_oen_master <= 1'b0; // keep SCL low
                        sda_oen_master <= din;  // set SDA
                        sda_chk <= 1'b0; // don't check SDA output (SCL low)
                    end

                    wr_b:
                    begin
                        c_state <= wr_c;
                        scl_oen_master <= 1'b1; // set SCL high
                        sda_oen_master <= din;  // keep SDA
                        sda_chk <= 1'b0; // don't check SDA output yet
                                            // allow some time for SDA and SCL to settle
                    end

                    wr_c:
                    begin
                        c_state <= wr_d;
                        scl_oen_master <= 1'b1; // keep SCL high
                        sda_oen_master <= din;
                        sda_chk <= 1'b1; // check SDA output
                    end

                    wr_d:
                    begin
                        c_state <= idle;
                        cmd_ack <= 1'b1;
                        scl_oen_master <= 1'b0; // set SCL low
                        sda_oen_master <= din;
                        sda_chk <= 1'b0; // don't check SDA output (SCL low)
                    end

              endcase
      end

   //----------Addition for slave mode...
   reg [3:0] slave_cnt;

   //The SCL can only be driven when Master mode

   assign sda_oen = master_mode ? sda_oen_master : sda_oen_slave ;
   assign scl_oen = master_mode ? scl_oen_master : scl_oen_slave ;
   reg 	     slave_act;
   reg 	     slave_adr_received_d;

   //A 1 cycle pulse slave_adr_recived is generated when a slave adress is recvied after a startcommand.

   always @(posedge clk or negedge nReset)
     if (!nReset) begin
	slave_adr <=  8'h0;
	slave_cnt <=  4'h8;
	slave_adr_received <=  1'b0;
	slave_act <=  1'b0;
     end
     else begin
	slave_adr_received <=  1'b0;

	if ((sSCL & ~dSCL) && slave_cnt != 4'h0 && slave_act)	 begin
	   slave_adr <=  {slave_adr[6:0], sSDA};
	   slave_cnt <=  slave_cnt -1;
	end
	else if (slave_cnt == 4'h0 && !sta_condition && slave_act) begin
	   slave_adr_received <=  1'b1;
	   slave_act <=  1'b0;
	end

	if (sta_condition) begin
	   slave_cnt <=  4'h8;
	   slave_adr <=  8'h0;
	   slave_adr_received <=  1'b0;
	   slave_act <=  1'b1;
	end
	if(sto_condition) begin
	   slave_adr_received <=  1'b0;
	   slave_act <=  1'b0;
	end
     end



   parameter [4:0] slave_idle    = 5'b0_0000;
   parameter [4:0] slave_wr      = 5'b0_0001;
   parameter [4:0] slave_wr_a    = 5'b0_0010;
   parameter [4:0] slave_rd      = 5'b0_0100;
   parameter [4:0] slave_rd_a    = 5'b0_1000;
   parameter [4:0] slave_wait_next_cmd_1   = 5'b1_0000;
   parameter [4:0] slave_wait_next_cmd_2   = 5'b1_0001;

   always @(posedge clk or negedge nReset)
     if (!nReset)
       begin
          slave_state <=  slave_idle;
          cmd_slave_ack   <=  1'b0;
          sda_oen_slave   <=  1'b1;
          scl_oen_slave   <=  1'b1;
       end
     else if (rst | sta_condition || !ena)
       begin
          slave_state <=  slave_idle;
          cmd_slave_ack   <=  1'b0;
          sda_oen_slave   <=  1'b1;
          scl_oen_slave   <=  1'b1;
       end
     else
       begin
          cmd_slave_ack   <=  1'b0; // default no command acknowledge + assert cmd_ack only 1clk cycle

          if (sl_wait)
            scl_oen_slave   <=  1'b0;
          else
            scl_oen_slave   <=  1'b1;

          case (slave_state)
            slave_idle:

              begin

                 case (slave_cmd) // synopsys full_case parallel_case
                   `I2C_SLAVE_CMD_WRITE: slave_state <=  slave_wr;
                   `I2C_SLAVE_CMD_READ:
		     begin
			slave_state <=  slave_rd;
			// Restore SDA high here in case we're got it low
			sda_oen_slave <=  1'b1;
		     end
                   default:
		     begin
			slave_state <=  slave_idle;
			sda_oen_slave <=  1'b1; // Moved this here, JB
		     end
                 endcase
              end

            slave_wr:
              begin
                 if (~sSCL & ~dSCL)  begin //SCL == LOW
                    slave_state <=  slave_wr_a;
                    sda_oen_slave <=  din;
                 end
              end

            slave_wr_a:
              begin
                 if (~sSCL & dSCL)  begin //SCL FALLING EDGE
                    cmd_slave_ack <=  1'b1;
                    slave_state <=  slave_wait_next_cmd_1;
                 end
              end

	    slave_wait_next_cmd_1:
              slave_state <=  slave_wait_next_cmd_2;

	    slave_wait_next_cmd_2:
              slave_state <=  slave_idle;


            slave_rd:
              begin
                 if (sSCL & ~dSCL)  begin   // SCL Rising edge
                    slave_state <=  slave_rd_a;
                 end
              end

            slave_rd_a:
              begin
                 if (~sSCL & dSCL)  begin       // SCL falling edge
                    cmd_slave_ack <=  1'b1;
                    slave_state <=  slave_wait_next_cmd_1;
                 end
              end
          endcase // case (slave_state)
       end

   assign slave_reset = sta_condition | sto_condition;

    // assign scl and sda output (always gnd)
    assign scl_o = 1'b0;
    assign sda_o = 1'b0;

endmodule
