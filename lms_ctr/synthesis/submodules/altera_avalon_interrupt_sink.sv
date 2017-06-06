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


// $File: //acds/rel/15.1/ip/sopc/components/verification/altera_avalon_interrupt_sink/altera_avalon_interrupt_sink.sv $
// $Revision: #1 $
// $Date: 2015/08/09 $
// $Author: swbranch $
//------------------------------------------------------------------------------
// =head1 NAME
// altera_avalon_interrupt_sink
// =head1 SYNOPSIS
// Avalon Interrupt Sink Bus Functional Model (BFM)
//-----------------------------------------------------------------------------
// =head1 DESCRIPTION
// This is an Avalon Interrupt Sink Bus Functional Model (BFM)
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

module altera_avalon_interrupt_sink (
				     clk, 
				     reset,
				       
				     irq
				     );
   
   parameter ASSERT_HIGH_IRQ           = 1; // Ictive high irq
   parameter AV_IRQ_W                  = 1; // Interrupt request bus width
   parameter ASYNCHRONOUS_INTERRUPT    = 0; // Asynchronous irq signal to its associated clock
   parameter VHDL_ID                   = 0; // VHDL BFM ID number

   // =head1 PINS
   // =head2 Clock Interface   
   input                   clk;
   input                   reset;	  

   // =head2 Avalon Interrupt Sink Interface   
   input [AV_IRQ_W-1:0]    irq;   

   // =cut
   
// synthesis translate_off
   import verbosity_pkg::*;  
   
   //--------------------------------------------------------------------------
   // Internal Machinery
   //--------------------------------------------------------------------------
   
   logic [AV_IRQ_W-1:0]    irq_inactive   = (ASSERT_HIGH_IRQ)? {AV_IRQ_W{1'b0}} : {AV_IRQ_W{1'b1}};
   logic [AV_IRQ_W-1:0]    irq_register   = irq_inactive;
   
   if (ASYNCHRONOUS_INTERRUPT == 1) begin
      always @(reset or irq) begin
         if (reset) begin
       irq_register = irq_inactive;
         end else begin
       irq_register = irq;
         end
      end
   end else begin
      always @(posedge clk) begin
         if (reset) begin
       irq_register <= irq_inactive;
         end else begin
       irq_register <= irq;
         end
      end
   end

   function automatic void hello();
      // Introduction Message to console      
      $sformat(message, "%m: - Hello from altera_avalon_interrupt_sink");
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   $Revision: #1 $");
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   $Date: 2015/08/09 $");
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   AV_IRQ_W 	            = %0d", AV_IRQ_W);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   ASSERT_HIGH_IRQ         = %0d", ASSERT_HIGH_IRQ);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   ASYNCHRONOUS_INTERRUPT  = %0d", ASYNCHRONOUS_INTERRUPT);
      print(VERBOSITY_INFO, message);
   endfunction

   initial begin
      hello();
   end

   //--------------------------------------------------------------------------
   // =head1 Public Methods API
   // =pod
   // This section describes the public methods in the application programming
   // interface (API). In this case the application program is the test bench
   // which instantiates and controls and queries state in this BFM component.
   // Test programs must only use these public access methods and events to 
   // communicate with this BFM component. The API and the module pins
   // are the only interfaces in this component that are guaranteed to be
   // stable. The API will be maintained for the life of the product. 
   // While we cannot prevent a test program from directly accessing internal
   // tasks, functions, or data private to the BFM, there is no guarantee that
   // these will be present in the future. In fact, it is best for the user
   // to assume that the underlying implementation of this component can 
   // and will change.
   // =cut
   //--------------------------------------------------------------------------

   function automatic string get_version();  // public
      // Return BFM version as a string of three integers separated by periods.
      // For example, version 9.1 sp1 is encoded as "9.1.1".      
      string ret_version = "15.1";
      return ret_version;      
   endfunction
   
   function automatic logic [AV_IRQ_W-1:0] get_irq();  // public
      $sformat(message, "%m: called get_irq");
      print(VERBOSITY_DEBUG, message);
      return irq_register;
   endfunction 

   function automatic void clear_irq();  // public
      irq_register = irq_inactive;
      $sformat(message, "%m: called clear_irq");
      print(VERBOSITY_DEBUG, message);            
   endfunction 

// synthesis translate_on
endmodule 

