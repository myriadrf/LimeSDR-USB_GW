-- ----------------------------------------------------------------------------	
-- FILE: 	file_name.vhd
-- DESCRIPTION:	describe
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity FX3_slaveFIFO5b_top is
	generic (
				dev_family				: string := "Cyclone IV E";
				data_width				: integer := 32;								--when data_width is changed to 16b, socketx_wrusedw_size and 
																								--socketx_rdusedw_size has to be doubled to maintain same size
				EP01_rwidth				: integer := 64;
				EP81_wrusedw_width	: integer := 10;
				EP81_wwidth				: integer := 64;			
				EP0F_rwidth				: integer := 8;
				EP8F_wwidth				: integer := 8
				);
	port(
				reset_n 					: in std_logic;									--input reset active low
				clk	   				: in std_logic;									--input clk 100 Mhz  
				clk_out	   			: out std_logic;									--output clk 100 Mhz 
				usb_speed 				: in std_logic;									--USB3.0 - 1, USB2.0 - 0
				slcs 	   				: out std_logic;									--output chip select
				fdata      				: inout std_logic_vector(data_width-1 downto 0);         
				faddr      				: out std_logic_vector(4 downto 0);			--output fifo address
				slrd	   				: out std_logic;									--output read select
				sloe	   				: out std_logic;									--output output enable select
				slwr	   				: out std_logic;									--output write select
								  
				flaga	   				: in std_logic;                                
				flagb	   				: in std_logic;
				flagc	   				: in std_logic;									--Not used in 5bit addres mode
				flagd	   				: in std_logic;									--Not used in 5bit addres mode

				pktend	   			: out std_logic;									--output pkt end 
				EPSWITCH					: out std_logic;
		
				--stream endpoint fifo (PC->FPGA) 
				EP01_rdclk		: in std_logic;
				EP01_rd			: in std_logic;
				EP01_rdata		: out std_logic_vector(EP01_rwidth-1 downto 0);
				EP01_rempty		: out std_logic;
				ext_buff_rdy	: in std_logic;
				ext_buff_data	: out std_logic_vector(data_width-1 downto 0);
				ext_buff_wr		: out std_logic;
				--stream endpoint fifo (FPGA->PC)
				EP81_wclk		: in std_logic;
				EP81_aclrn		: in std_logic;
				EP81_wr			: in std_logic;
				EP81_wdata		: in std_logic_vector(EP81_wwidth-1 downto 0);
				EP81_wfull		: out std_logic;
				EP81_wrusedw	: out std_logic_vector(EP81_wrusedw_width-1 downto 0);
				--controll endpoint fifo (PC->FPGA)
				EP0F_rdclk		: in std_logic;
				EP0F_rd			: in std_logic;
				EP0F_rdata		: out std_logic_vector(EP0F_rwidth-1 downto 0);
				EP0F_rempty		: out std_logic;
				--controll endpoint fifo (FPGA->PC)
				EP8F_wclk		: in std_logic;
				EP8F_aclrn		: in std_logic;
				EP8F_wr			: in std_logic;
				EP8F_wdata		: in std_logic_vector(EP8F_wwidth-1 downto 0);
				EP8F_wfull		: out std_logic;
				GPIF_busy		: out std_logic
			
	    );

end entity FX3_slaveFIFO5b_top;

architecture arch of FX3_slaveFIFO5b_top is

constant socket0_wrusedw_size : integer := 11;
constant socket0_rdusedw_size : integer := 10; 

constant socket1_wrusedw_size : integer := 9;
constant socket1_rdusedw_size : integer := 9; 

constant socket2_wrusedw_size : integer := 10;
constant socket2_rdusedw_size : integer := 11;

constant socket3_wrusedw_size : integer := 9;
constant socket3_rdusedw_size : integer := 9;


	--socket 0 (configured to read data from it PC->FPGA)
signal inst1_socket0_fifo_data			: std_logic_vector(data_width-1 downto 0);
signal inst1_socket0_fifo_wrusedw		: std_logic_vector(socket0_wrusedw_size-1 downto 0);
signal inst1_socket0_fifo_wr				: std_logic;

	--socket 1 (configured to read control data from it PC->FPGA)
signal inst1_socket1_fifo_data			: std_logic_vector(data_width-1 downto 0);
signal inst1_socket1_fifo_wrusedw		: std_logic_vector(socket1_wrusedw_size-1 downto 0);
signal inst1_socket1_fifo_wr				: std_logic;

signal inst2_fifo_wrusedw					: std_logic_vector(socket0_wrusedw_size-1 downto 0);


signal inst4_fifo_q							: std_logic_vector(data_width-1 downto 0);
signal inst4_fifo_rdusedw					: std_logic_vector(socket2_rdusedw_size-1 downto 0);
signal inst4_fifo_rd							: std_logic;

signal inst5_fifo_q							: std_logic_vector(data_width-1 downto 0);
signal inst5_fifo_rdusedw					: std_logic_vector(socket3_rdusedw_size-1 downto 0);
signal inst5_fifo_rd							: std_logic;

signal ddr_clk_out							:std_logic_vector(0 downto 0);


component slaveFIFO5b is
	generic (num_of_sockets 		: integer := 1;
				data_width				: integer := 32;								--when data_width is changed to 16b, socketx_wrusedw_size and 
																								--socketx_rdusedw_size has to be doubled to maintain same size
				data_dma_size			: integer := 1024;							--data endpoint dma size in bytes
				control_dma_size		: integer := 1024;							--control endpoint dma size in bytes
				data_pct_size			: integer := 1024;							--packet size in bytes
				control_pct_size		: integer := 64;								--packet size in bytes, should be less then max dma size
				socket0_wrusedw_size : integer := 11;
				socket0_rdusedw_size	: integer := 10;
				socket1_wrusedw_size : integer := 11;
				socket1_rdusedw_size	: integer := 10;
				socket2_wrusedw_size : integer := 11;
				socket2_rdusedw_size	: integer := 10;
				socket3_wrusedw_size : integer := 11;
				socket3_rdusedw_size	: integer := 10
				);
	port(
		reset_n 					: in std_logic;									--input reset active low
		clk	   				: in std_logic;									--input clk 100 Mhz  
		clk_out	   			: out std_logic;									--output clk 100 Mhz 
		usb_speed 				: in std_logic;									--USB3.0 - 1, USB2.0 - 0
		slcs 	   				: out std_logic;									--output chip select
		fdata      				: inout std_logic_vector(data_width-1 downto 0);         
		faddr      				: out std_logic_vector(4 downto 0);			--output fifo address
		slrd	   				: out std_logic;									--output read select
		sloe	   				: out std_logic;									--output output enable select
		slwr	   				: out std_logic;									--output write select
                    
      flaga	   				: in std_logic;                                
		flagb	   				: in std_logic;
      flagc	   				: in std_logic;									--Not used in 5bit addres mode
      flagd	   				: in std_logic;									--Not used in 5bit addres mode

		pktend	   			: out std_logic;									--output pkt end 
		EPSWITCH					: out std_logic;
		
		--socket 0 (configured to read data from it PC->FPGA)
		socket0_fifo_data			: out std_logic_vector(data_width-1 downto 0);
		socket0_fifo_q				: in std_logic_vector(data_width-1 downto 0);
		socket0_fifo_wrusedw		: in std_logic_vector(socket0_wrusedw_size-1 downto 0);
		socket0_fifo_rdusedw		: in std_logic_vector(socket0_rdusedw_size-1 downto 0);
		socket0_fifo_wr			: out std_logic;
		socket0_fifo_rd			: out std_logic;

		--socket 1 (configured to read control data from it PC->FPGA)
		socket1_fifo_data			: out std_logic_vector(data_width-1 downto 0);
		socket1_fifo_q				: in std_logic_vector(data_width-1 downto 0);
		socket1_fifo_wrusedw		: in std_logic_vector(socket1_wrusedw_size-1 downto 0);
		socket1_fifo_rdusedw		: in std_logic_vector(socket1_rdusedw_size-1 downto 0);
		socket1_fifo_wr			: out std_logic;
		socket1_fifo_rd			: out std_logic;

		--socket 2 (configured to write data to it FPGA->PC)
		socket2_fifo_data			: out std_logic_vector(data_width-1 downto 0);
		socket2_fifo_q				: in std_logic_vector(data_width-1 downto 0);
		socket2_fifo_wrusedw		: in std_logic_vector(socket2_wrusedw_size-1 downto 0);
		socket2_fifo_rdusedw		: in std_logic_vector(socket2_rdusedw_size-1 downto 0);
		socket2_fifo_wr			: out std_logic;
		socket2_fifo_rd			: out std_logic;

		--socket 3 (configured to write control data to it FPGA->PC)
		socket3_fifo_data			: out std_logic_vector(data_width-1 downto 0);
		socket3_fifo_q				: in std_logic_vector(data_width-1 downto 0);
		socket3_fifo_wrusedw		: in std_logic_vector(socket3_wrusedw_size-1 downto 0);
		socket3_fifo_rdusedw		: in std_logic_vector(socket3_rdusedw_size-1 downto 0);
		socket3_fifo_wr			: out std_logic;
		socket3_fifo_rd			: out std_logic;
		GPIF_busy					: out std_logic

	    );
end component;

component fifo_inst is
  generic(dev_family	     : string  := "Cyclone IV E";
          wrwidth         : integer := 24;
          wrusedw_witdth  : integer := 12; --12=2048 words 
          rdwidth         : integer := 48;
          rdusedw_width   : integer := 11;
          show_ahead      : string  := "ON"
  );  
  port (
      --input ports 
      reset_n       : in std_logic;
      wrclk         : in std_logic;
      wrreq         : in std_logic;
      data          : in std_logic_vector(wrwidth-1 downto 0);
      wrfull        : out std_logic;
		wrempty		  : out std_logic;
      wrusedw       : out std_logic_vector(wrusedw_witdth-1 downto 0);
      rdclk 	     : in std_logic;
      rdreq         : in std_logic;
      q             : out std_logic_vector(rdwidth-1 downto 0);
      rdempty       : out std_logic;
      rdusedw       : out std_logic_vector(rdusedw_width-1 downto 0)     
        );
end component;

begin
	
	ALTDDIO_OUT_component : ALTDDIO_OUT
	GENERIC MAP (
		extend_oe_disable 		=> "OFF",
		intended_device_family 	=> dev_family,
		invert_output 				=> "OFF",
		lpm_hint 					=> "UNUSED",
		lpm_type 					=> "altddio_out",
		oe_reg 						=> "UNREGISTERED",
		power_up_high 				=> "OFF",
		width 						=> 1
	)
	PORT MAP (
		datain_h => "0",
		datain_l => "1",
		outclock => clk,
		dataout 	=> ddr_clk_out
	);
	
clk_out<=ddr_clk_out(0);	
	
inst1 : slaveFIFO5b 
	generic map (
				num_of_sockets 		=> 1,
				data_width				=> 32,							--when data_width is changed to 16b, socketx_wrusedw_size and 
																				--socketx_rdusedw_size has to be doubled to maintain same size
				data_dma_size			=> 4096,							--data endpoint dma size in bytes
				control_dma_size		=> 4096,							--control endpoint dma size in bytes
				data_pct_size			=> 4096,							--packet size in bytes
				control_pct_size		=> 64,							--packet size in bytes, should be less then max dma size
				socket0_wrusedw_size => socket0_wrusedw_size,
				socket0_rdusedw_size	=> socket0_rdusedw_size,
				socket1_wrusedw_size => socket1_wrusedw_size,
				socket1_rdusedw_size	=> socket1_rdusedw_size,
				socket2_wrusedw_size => socket2_wrusedw_size,
				socket2_rdusedw_size	=> socket2_rdusedw_size,
				socket3_wrusedw_size => socket3_wrusedw_size,
				socket3_rdusedw_size	=> socket3_rdusedw_size
				)
	port map(
		reset_n 					=> reset_n, 							--input reset active low
		clk	   				=> clk, 									--input clk 100 Mhz  
		clk_out	   			=> open, 								--output clk 100 Mhz 
		usb_speed 				=> usb_speed,							--USB3.0 - 1, USB2.0 - 0
		slcs 	   				=> slcs,									--output chip select
		fdata      				=> fdata,         
		faddr      				=> faddr, 								--output fifo address
		slrd	   				=> slrd, 								--output read select
		sloe	   				=> sloe,									--output output enable select
		slwr	   				=> slwr,									--output write select
                    
      flaga	   				=> flaga,                               
		flagb	   				=> flagb,
      flagc	   				=> flagc,								--Not used in 5bit addres mode
      flagd	   				=> flagd,								--Not used in 5bit addres mode

		pktend	   			=> pktend,								--output pkt end 
		EPSWITCH					=> EPSWITCH,
		
		--socket 0 (configured to read data from it PC->FPGA)
		socket0_fifo_data			=> inst1_socket0_fifo_data, 
		socket0_fifo_q				=> (others => '0'), 
		socket0_fifo_wrusedw		=> inst1_socket0_fifo_wrusedw,
		socket0_fifo_rdusedw		=> (others => '0'), 
		socket0_fifo_wr			=> inst1_socket0_fifo_wr,
		socket0_fifo_rd			=> open, 

		--socket 1 (configured to read control data from it PC->FPGA)
		socket1_fifo_data			=> inst1_socket1_fifo_data,
		socket1_fifo_q				=> (others => '0'),
		socket1_fifo_wrusedw		=> inst1_socket1_fifo_wrusedw,
		socket1_fifo_rdusedw		=> (others => '0'),
		socket1_fifo_wr			=> inst1_socket1_fifo_wr,
		socket1_fifo_rd			=> open,

		--socket 2 (configured to write data to it FPGA->PC)
		socket2_fifo_data			=> open, 
		socket2_fifo_q				=> inst4_fifo_q,
		socket2_fifo_wrusedw		=> (others => '0'), 
		socket2_fifo_rdusedw		=> inst4_fifo_rdusedw,
		socket2_fifo_wr			=> open, 
		socket2_fifo_rd			=> inst4_fifo_rd,

		--socket 3 (configured to write control data to it FPGA->PC)
		socket3_fifo_data			=> open, 
		socket3_fifo_q				=> inst5_fifo_q,
		socket3_fifo_wrusedw		=> (others => '0'), 
		socket3_fifo_rdusedw		=> inst5_fifo_rdusedw,
		socket3_fifo_wr			=> open, 
		socket3_fifo_rd			=> inst5_fifo_rd,
		GPIF_busy					=> GPIF_busy
		
	    );	
		 
--inst2 : fifo_inst --(for 01 endpoint, socket 0)
--  generic map(
--					dev_family	    => dev_family,
--					wrwidth         => data_width,
--					wrusedw_witdth  => socket0_wrusedw_size,  
--					rdwidth         => EP01_rwidth,
--					rdusedw_width   => socket0_rdusedw_size,
--					show_ahead      => "OFF"
--  )
--  port map(
--      --input ports 
--      reset_n       => reset_n,
--      wrclk         => clk,
--      wrreq         => inst1_socket0_fifo_wr,
--      data          => inst1_socket0_fifo_data,
--      wrfull        => open,
--		wrempty		  => open,
--      wrusedw       => inst2_fifo_wrusedw,
--      rdclk 	     => EP01_rdclk,
--      rdreq         => EP01_rd,
--      q             => EP01_rdata,
--      rdempty       => EP01_rempty,
--      rdusedw       => open   
--        );
		  
ext_buff_wr<=inst1_socket0_fifo_wr;	  
inst1_socket0_fifo_wrusedw<=(others=>'0') when ext_buff_rdy='1' else 
									(others=>'1');	
									
ext_buff_data<=inst1_socket0_fifo_data;
		
inst3 : fifo_inst --(for 0F endpoint, socket 1)
  generic map(
					dev_family	    => dev_family,
					wrwidth         => data_width,
					wrusedw_witdth  => socket1_wrusedw_size,  
					rdwidth         => EP0F_rwidth,
					rdusedw_width   => socket1_rdusedw_size,
					show_ahead      => "OFF"
  )
  port map(
      --input ports 
      reset_n       => reset_n,
      wrclk         => clk,
      wrreq         => inst1_socket1_fifo_wr,
      data          => inst1_socket1_fifo_data,
      wrfull        => open,
		wrempty		  => open,
      wrusedw       => inst1_socket1_fifo_wrusedw,
      rdclk 	     => EP0F_rdclk,
      rdreq         => EP0F_rd,
      q             => EP0F_rdata,
      rdempty       => EP0F_rempty,
      rdusedw       => open     
        );	
		
inst4 : fifo_inst --(for 81 endpoint, socket 2)
  generic map(
					dev_family	    => dev_family,
					wrwidth         => EP81_wwidth,
					wrusedw_witdth  => EP81_wrusedw_width,  
					rdwidth         => data_width,
					rdusedw_width   => socket2_rdusedw_size,
					show_ahead      => "ON"
  ) 
  port map(
      --input ports 
      reset_n       => EP81_aclrn,
      wrclk         => EP81_wclk,
      wrreq         => EP81_wr,
      data          => EP81_wdata,
      wrfull        => EP81_wfull,
		wrempty		  => open,
      wrusedw       => EP81_wrusedw,
      rdclk 	     => clk,
      rdreq         => inst4_fifo_rd,
      q             => inst4_fifo_q,
      rdempty       => open,
      rdusedw       => inst4_fifo_rdusedw    
        );
	
inst5 : fifo_inst --(for 8F endpoint, socket 3)
  generic map(
					dev_family	    => dev_family,
					wrwidth         => EP8F_wwidth,
					wrusedw_witdth  => socket3_wrusedw_size,  
					rdwidth         => data_width,
					rdusedw_width   => socket3_rdusedw_size,
					show_ahead      => "ON"
  ) 
  port map(
      --input ports 
      reset_n       => EP8F_aclrn,
      wrclk         => EP8F_wclk,
      wrreq         => EP8F_wr,
      data          => EP8F_wdata,
      wrfull        => EP8F_wfull,
		wrempty		  => open,
      wrusedw       => open,
      rdclk 	     => clk,
      rdreq         => inst5_fifo_rd,
      q             => inst5_fifo_q,
      rdempty       => open,
      rdusedw       => inst5_fifo_rdusedw    
        );		
	
		  
		  
end arch;







