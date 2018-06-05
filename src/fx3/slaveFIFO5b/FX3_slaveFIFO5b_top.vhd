-- ----------------------------------------------------------------------------
-- FILE:          FX3_slaveFIFO5b_top.vhd
-- DESCRIPTION:   Top module for FX3 (USB3) connection
-- DATE:          10:31 AM Friday, May 18, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FIFO_PACK.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity FX3_slaveFIFO5b_top is
   generic (
      dev_family           : string := "Cyclone IV E";
      data_width           : integer := 32;  --when data_width is changed to 16b, socketx_wrusedw_size and 				
                                             --socketx_rdusedw_size has to be doubled to maintain same size
      -- Stream, socket 0, (PC->FPGA) 
      EP01_0_rdusedw_width : integer := 11;
      EP01_0_rwidth        : integer := 32;
      EP01_1_rdusedw_width : integer := 11;
      EP01_1_rwidth        : integer := 32;
      -- Stream, socket 2, (FPGA->PC)
      EP81_wrusedw_width   : integer := 10;
      EP81_wwidth          : integer := 64;
      -- Control, socket 1, (PC->FPGA)
      EP0F_rdusedw_width   : integer := 9;
      EP0F_rwidth          : integer := 32;
      -- Control, socket 3, (FPGA->PC)
      EP8F_wrusedw_width   : integer := 9;
      EP8F_wwidth          : integer := 32
   );
   port(
      reset_n        : in std_logic;      --input reset active low
      clk            : in std_logic;      --input clk 100 Mhz  
      usb_speed      : in std_logic;      --USB3.0 - 1, USB2.0 - 0
      slcs           : out std_logic;     --output chip select
      fdata          : inout std_logic_vector(data_width-1 downto 0);         
      faddr          : out std_logic_vector(4 downto 0);    --output fifo address
      slrd           : out std_logic;     --output read select
      sloe           : out std_logic;     --output output enable select
      slwr           : out std_logic;     --output write select
                     
      flaga          : in std_logic;                                
      flagb          : in std_logic;
      flagc          : in std_logic;      --Not used in 5bit addres mode
      flagd          : in std_logic;      --Not used in 5bit addres mode
      
      pktend         : out std_logic;     --output pkt end 
      EPSWITCH       : out std_logic;
      
      EP01_sel       : in std_logic;      -- 0 - EP01_0,
     --Stream endpoint fifo 0 (PC->FPGA) 
      EP01_0_rdclk   : in std_logic;
      EP01_0_aclrn   : in std_logic;
      EP01_0_rd      : in std_logic;
      EP01_0_rdata   : out std_logic_vector(EP01_0_rwidth-1 downto 0);
      EP01_0_rempty  : out std_logic;
      EP01_0_rdusedw : out std_logic_vector(EP01_0_rdusedw_width-1 downto 0);
      --Stream endpoint fifo 1 (PC->FPGA) 
      EP01_1_rdclk   : in std_logic;
      EP01_1_aclrn   : in std_logic;
      EP01_1_rd      : in std_logic;
      EP01_1_rdata   : out std_logic_vector(EP01_1_rwidth-1 downto 0);
      EP01_1_rempty  : out std_logic;
      EP01_1_rdusedw : out std_logic_vector(EP01_1_rdusedw_width-1 downto 0);

      --Stream endpoint fifo (FPGA->PC)
      EP81_wclk      : in std_logic;
      EP81_aclrn     : in std_logic;
      EP81_wr        : in std_logic;
      EP81_wdata     : in std_logic_vector(EP81_wwidth-1 downto 0);
      EP81_wfull     : out std_logic;
      EP81_wrusedw   : out std_logic_vector(EP81_wrusedw_width-1 downto 0);
      --Control endpoint fifo (PC->FPGA)
      EP0F_rdclk     : in std_logic;
      EP0F_aclrn     : in std_logic;
      EP0F_rd        : in std_logic;
      EP0F_rdata     : out std_logic_vector(EP0F_rwidth-1 downto 0);
      EP0F_rempty    : out std_logic;
      --Control endpoint fifo (FPGA->PC)
      EP8F_wclk      : in std_logic;
      EP8F_aclrn     : in std_logic;
      EP8F_wr        : in std_logic;
      EP8F_wdata     : in std_logic_vector(EP8F_wwidth-1 downto 0);
      EP8F_wfull     : out std_logic;
      GPIF_busy      : out std_logic
         
   );

end entity FX3_slaveFIFO5b_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of FX3_slaveFIFO5b_top is

constant socket0_wrusedw_size    : integer := FIFOWR_SIZE (data_width, EP01_0_rwidth, EP01_0_rdusedw_width);
constant socket0_0_rdusedw_size  : integer := EP01_0_rdusedw_width; 
constant socket0_1_rdusedw_size  : integer := EP01_1_rdusedw_width; 

constant socket1_wrusedw_size    : integer := FIFOWR_SIZE (data_width, EP0F_rdusedw_width, EP0F_rdusedw_width);
constant socket1_rdusedw_size    : integer := EP0F_rdusedw_width; 
   
constant socket2_wrusedw_size    : integer := EP81_wrusedw_width;
constant socket2_rdusedw_size    : integer := FIFORD_SIZE (EP81_wwidth, data_width, EP81_wrusedw_width);
   
constant socket3_wrusedw_size    : integer := EP8F_wrusedw_width;
constant socket3_rdusedw_size    : integer := FIFORD_SIZE (EP8F_wwidth, data_width, EP8F_wrusedw_width);

signal EP01_sel_sync                   : std_logic;
signal EP01_0_sclrn                    : std_logic;
signal EP01_1_sclrn                    : std_logic;
signal EP01_0_sclrn_reg                : std_logic;
signal EP01_1_sclrn_reg                : std_logic;

--inst0 
signal inst0_rdempty                   : std_logic;

   --socket 0 (configured to read data from it PC->FPGA)
signal inst1_socket0_fifo_reset_n      : std_logic;
signal inst1_socket0_fifo_data         : std_logic_vector(data_width-1 downto 0);
signal inst1_socket0_fifo_wrusedw      : std_logic_vector(socket0_wrusedw_size-1 downto 0);
signal inst1_socket0_fifo_wr           : std_logic;
signal inst1_socket1_fifo_reset_n      : std_logic;

   --socket 1 (configured to read control data from it PC->FPGA)
signal inst1_socket1_fifo_data         : std_logic_vector(data_width-1 downto 0);
signal inst1_socket1_fifo_wrusedw      : std_logic_vector(socket1_wrusedw_size-1 downto 0);
signal inst1_socket1_fifo_wr           : std_logic;

--inst2
signal inst2_wrreq                     : std_logic;
signal inst2_fifo_wrusedw              : std_logic_vector(socket0_wrusedw_size-1 downto 0);
signal inst2_reset_n                   : std_logic;

--inst3 
signal inst3_reset_n                   : std_logic;
signal inst3_pct_wr                    : std_logic;
signal inst3_pct_payload_data          : std_logic_vector(data_width-1 downto 0);
signal inst3_pct_payload_valid         : std_logic;

--inst4
signal inst4_wrreq                     : std_logic;
signal inst4_fifo_wrusedw              : std_logic_vector(socket0_wrusedw_size-1 downto 0);
signal inst4_reset_n                   : std_logic;

--inst5
signal inst5_reset_n                   : std_logic;
--inst6
signal inst6_fifo_q                    : std_logic_vector(data_width-1 downto 0);
signal inst6_fifo_rdusedw              : std_logic_vector(socket2_rdusedw_size-1 downto 0);
signal inst6_fifo_rd                   : std_logic;
--inst7
signal inst7_fifo_q                    : std_logic_vector(data_width-1 downto 0);
signal inst7_fifo_rdusedw              : std_logic_vector(socket3_rdusedw_size-1 downto 0);
signal inst7_fifo_rd                   : std_logic;

--signal ddr_clk_out                     :std_logic_vector(0 downto 0);


begin
 
-- ----------------------------------------------------------------------------
-- Reset logic
-- ----------------------------------------------------------------------------  
   -- Reset signal with synchronous removal to clk clock domain, 
   sync_reg0 : entity work.sync_reg 
   port map(clk, EP01_0_aclrn, '1', EP01_0_sclrn);
   
   sync_reg1 : entity work.sync_reg 
   port map(clk, EP01_1_aclrn, '1', EP01_1_sclrn);
  
   
   inst1_socket0_fifo_reset_n <= inst2_reset_n AND inst3_reset_n;
   
   sync_reg2 : entity work.sync_reg 
   port map(clk, EP0F_aclrn, '1', inst1_socket1_fifo_reset_n);
   
   inst5_reset_n <= inst1_socket1_fifo_reset_n;
   
   -- inst2 module is reset with one cycle pulse when EP01_1_aclrn is realeased
   process(clk, reset_n)
   begin 
      if reset_n = '0' then 
         inst2_reset_n     <= '0';
         EP01_0_sclrn_reg  <= '0';
      elsif (clk'event AND clk = '1') then 
         EP01_0_sclrn_reg <= EP01_0_sclrn;
         
         if EP01_0_sclrn = '1' and EP01_0_sclrn_reg = '0' then 
            inst2_reset_n <= '0';
         else 
            inst2_reset_n <= '1';
         end if;
      end if;
   end process;
   
   -- inst3 module is reset with one cycle pulse when EP01_1_aclrn is realeased
   process(clk, reset_n)
   begin 
      if reset_n = '0' then 
         inst3_reset_n     <= '0';
         EP01_1_sclrn_reg  <= '0';
      elsif (clk'event AND clk = '1') then 
         EP01_1_sclrn_reg <= EP01_1_sclrn;
         
         if EP01_1_sclrn = '1' and EP01_1_sclrn_reg = '0' then 
            inst3_reset_n <= '0';
         else 
            inst3_reset_n <= '1';
         end if;
      end if;
   end process;
   
   inst4_reset_n <= inst3_reset_n;
   
   
-- ----------------------------------------------------------------------------
-- Sync registers
-- ----------------------------------------------------------------------------   
   sync_reg3 : entity work.sync_reg 
   port map(clk, reset_n, EP01_sel, EP01_sel_sync);   
   
   
   
   
-- ----------------------------------------------------------------------------
-- slaveFIFO5b instance
-- ---------------------------------------------------------------------------- 
   inst1 : entity work.slaveFIFO5b 
   generic map (
      num_of_sockets       => 1,
      data_width           => 32,   --when data_width is changed to 16b, socketx_wrusedw_size and 
                                    --socketx_rdusedw_size has to be doubled to maintain same size
      data_dma_size        => 4096, --data endpoint dma size in bytes
      control_dma_size     => 4096, --control endpoint dma size in bytes
      data_pct_size        => 4096, --packet size in bytes
      control_pct_size     => 64,   --packet size in bytes, should be less then max dma size
      socket0_wrusedw_size => socket0_wrusedw_size,
      socket0_rdusedw_size => socket0_0_rdusedw_size,
      socket1_wrusedw_size => socket1_wrusedw_size,
      socket1_rdusedw_size => socket1_rdusedw_size,
      socket2_wrusedw_size => socket2_wrusedw_size,
      socket2_rdusedw_size => socket2_rdusedw_size,
      socket3_wrusedw_size => socket3_wrusedw_size,
      socket3_rdusedw_size => socket3_rdusedw_size
   )
   port map(
      reset_n                 => reset_n,    --input reset active low
      clk                     => clk,        --input clk 100 Mhz  
      clk_out                 => open,       --output clk 100 Mhz 
      usb_speed               => usb_speed,  --USB3.0 - 1, USB2.0 - 0
      slcs                    => slcs,       --output chip select
      fdata                   => fdata,         
      faddr                   => faddr,      --output fifo address
      slrd                    => slrd,       --output read select
      sloe                    => sloe,       --output output enable select
      slwr                    => slwr,       --output write select
                  
      flaga                   => flaga,                               
      flagb                   => flagb,
      flagc                   => flagc,      --Not used in 5bit addres mode
      flagd                   => flagd,      --Not used in 5bit addres mode
   
      pktend                  => pktend,     --output pkt end 
      EPSWITCH                => EPSWITCH,
      
      --socket 0 (configured to read data from it PC->FPGA)
      socket0_fifo_reset_n    => inst1_socket0_fifo_reset_n,
      socket0_fifo_data       => inst1_socket0_fifo_data, 
      socket0_fifo_q          => (others => '0'), 
      socket0_fifo_wrusedw    => inst1_socket0_fifo_wrusedw,
      socket0_fifo_rdusedw    => (others => '0'), 
      socket0_fifo_wr         => inst1_socket0_fifo_wr,
      socket0_fifo_rd         => open, 
   
      --socket 1 (configured to read control data from it PC->FPGA)
      socket1_fifo_reset_n    => inst1_socket1_fifo_reset_n,
      socket1_fifo_data       => inst1_socket1_fifo_data,
      socket1_fifo_q          => (others => '0'),
      socket1_fifo_wrusedw    => inst1_socket1_fifo_wrusedw,
      socket1_fifo_rdusedw    => (others => '0'),
      socket1_fifo_wr         => inst1_socket1_fifo_wr,
      socket1_fifo_rd         => open,
   
      --socket 2 (configured to write data to it FPGA->PC)
      socket2_fifo_data       => open, 
      socket2_fifo_q          => inst6_fifo_q,
      socket2_fifo_wrusedw    => (others => '0'), 
      socket2_fifo_rdusedw    => inst6_fifo_rdusedw,
      socket2_fifo_wr         => open, 
      socket2_fifo_rd         => inst6_fifo_rd,
   
      --socket 3 (configured to write control data to it FPGA->PC)
      socket3_fifo_data       => open, 
      socket3_fifo_q          => inst7_fifo_q,
      socket3_fifo_wrusedw    => (others => '0'), 
      socket3_fifo_rdusedw    => inst7_fifo_rdusedw,
      socket3_fifo_wr         => open, 
      socket3_fifo_rd         => inst7_fifo_rd,
      GPIF_busy               => GPIF_busy
      
   );
-- ----------------------------------------------------------------------------
--(for 01 endpoint, socket 0)
-- There are two FIFO buffers for this endpoint, one of them debending on EP01_sel
-- ----------------------------------------------------------------------------

inst2_wrreq <= inst1_socket0_fifo_wr when EP01_sel_sync = '0' else '0';
 
   inst2_EP01_0_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => dev_family,
      wrwidth        => data_width,
      wrusedw_witdth => socket0_wrusedw_size,  
      rdwidth        => EP01_0_rwidth,
      rdusedw_width  => socket0_0_rdusedw_size,
      show_ahead     => "OFF"
   )
   port map(
      --input ports 
      reset_n  => inst2_reset_n,
      wrclk    => clk,
      wrreq    => inst2_wrreq,
      data     => inst1_socket0_fifo_data,
      wrfull   => open,
      wrempty  => open,
      wrusedw  => inst2_fifo_wrusedw,
      rdclk    => EP01_0_rdclk,
      rdreq    => EP01_0_rd,
      q        => EP01_0_rdata,
      rdempty  => EP01_0_rempty,
      rdusedw  => EP01_0_rdusedw   
   );
   
   inst3_pct_wr <= inst1_socket0_fifo_wr when EP01_sel_sync = '1' else '0';
   
   pct_payload_extrct_inst3 : entity work.pct_payload_extrct
   generic map(
      data_w			=> data_width,
      header_size		=> 16, 
      pct_size			=> 4096
   ) 
  port map(
      --input ports 
      clk					=> clk,
      reset_n				=> inst3_reset_n,
      pct_data				=> inst1_socket0_fifo_data, 
      pct_wr				=> inst3_pct_wr,
      pct_payload_data	=> inst3_pct_payload_data,
      pct_payload_valid	=> inst3_pct_payload_valid,
      pct_payload_dest	=> open
   );
   
   
   inst4_EP01_1_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => dev_family,
      wrwidth        => data_width,
      wrusedw_witdth => socket0_wrusedw_size,  
      rdwidth        => EP01_1_rwidth,
      rdusedw_width  => socket0_1_rdusedw_size,
      show_ahead     => "ON"
   )
   port map(
      --input ports 
      reset_n  => inst4_reset_n,
      wrclk    => clk,
      wrreq    => inst3_pct_payload_valid,
      data     => inst3_pct_payload_data,
      wrfull   => open,
      wrempty  => open,
      wrusedw  => inst4_fifo_wrusedw,
      rdclk    => EP01_1_rdclk,
      rdreq    => EP01_1_rd,
      q        => EP01_1_rdata,
      rdempty  => EP01_1_rempty,
      rdusedw  => EP01_1_rdusedw   
   );
   
inst1_socket0_fifo_wrusedw <= inst2_fifo_wrusedw when EP01_sel_sync = '0' else 
                              inst4_fifo_wrusedw;
-- ----------------------------------------------------------------------------
--(for 0F endpoint, socket 1)
-- ---------------------------------------------------------------------------- 
   inst5_EP0F_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => dev_family,
      wrwidth        => data_width,
      wrusedw_witdth => socket1_wrusedw_size,  
      rdwidth        => EP0F_rwidth,
      rdusedw_width  => socket1_rdusedw_size,
      show_ahead     => "OFF"
   )
  port map(
      --input ports 
      reset_n  => inst5_reset_n,
      wrclk    => clk,
      wrreq    => inst1_socket1_fifo_wr,
      data     => inst1_socket1_fifo_data,
      wrfull   => open,
      wrempty  => open,
      wrusedw  => inst1_socket1_fifo_wrusedw,
      rdclk    => EP0F_rdclk,
      rdreq    => EP0F_rd,
      q        => EP0F_rdata,
      rdempty  => EP0F_rempty,
      rdusedw  => open     
   );
-- ----------------------------------------------------------------------------
--(for 81 endpoint, socket 2)
-- ---------------------------------------------------------------------------- 
   inst6_EP81_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => dev_family,
      wrwidth        => EP81_wwidth,
      wrusedw_witdth => EP81_wrusedw_width,  
      rdwidth        => data_width,
      rdusedw_width  => socket2_rdusedw_size,
      show_ahead     => "ON"
  ) 
  port map(
      --input ports 
      reset_n  => EP81_aclrn,
      wrclk    => EP81_wclk,
      wrreq    => EP81_wr,
      data     => EP81_wdata,
      wrfull   => EP81_wfull,
      wrempty  => open,
      wrusedw  => EP81_wrusedw,
      rdclk    => clk,
      rdreq    => inst6_fifo_rd,
      q        => inst6_fifo_q,
      rdempty  => open,
      rdusedw  => inst6_fifo_rdusedw    
        );
-- ----------------------------------------------------------------------------
--(for 8F endpoint, socket 3)
-- ---------------------------------------------------------------------------- 
   inst7_EP8F_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => dev_family,
      wrwidth        => EP8F_wwidth,
      wrusedw_witdth => socket3_wrusedw_size,  
      rdwidth        => data_width,
      rdusedw_width  => socket3_rdusedw_size,
      show_ahead     => "ON"
   ) 
  port map(
      --input ports 
      reset_n  => EP8F_aclrn,
      wrclk    => EP8F_wclk,
      wrreq    => EP8F_wr,
      data     => EP8F_wdata,
      wrfull   => EP8F_wfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => clk,
      rdreq    => inst7_fifo_rd,
      q        => inst7_fifo_q,
      rdempty  => open,
      rdusedw  => inst7_fifo_rdusedw    
   );

  
 
end arch;


