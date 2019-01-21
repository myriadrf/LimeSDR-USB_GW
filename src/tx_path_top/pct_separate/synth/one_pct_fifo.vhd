-- ----------------------------------------------------------------------------
-- FILE:          one_pct_fifo.vhd
-- DESCRIPTION:   Reads from FIFO data and stores to other FIFO only one packet 
-- DATE:          10:51 AM Wednesday, January 16, 2019
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FIFO_PACK.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity one_pct_fifo is
   generic(
      dev_family              : string := "Cyclone IV E";
      g_INFIFO_DATA_WIDTH     : integer := 32;
      g_PCTFIFO_SIZE          : integer := 4096; -- Packet FIFO size in bytes
      g_PCTFIFO_RDATA_WIDTH   : integer := 128
   );
   port (
      clk               : in  std_logic;
      reset_n           : in  std_logic;
      infifo_rdreq      : out std_logic;
      infifo_data       : in  std_logic_vector(g_INFIFO_DATA_WIDTH-1 downto 0);
      infifo_rdempty    : in  std_logic;
      pct_rdclk         : in  std_logic;
      pct_aclr_n        : in  std_logic;
      pct_rdy           : out std_logic;
      pct_header        : out std_logic_vector(127 downto 0);
      pct_data_rdreq    : in  std_logic;
      pct_data          : out std_logic_vector(g_PCTFIFO_RDATA_WIDTH-1 downto 0);
      pct_data_rdempty  : out std_logic

   );
end one_pct_fifo;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of one_pct_fifo is
--declare signals,  components here
signal inst0_pct_wrreq           : std_logic;          
signal inst0_pct_data            : std_logic_vector(g_INFIFO_DATA_WIDTH-1 downto 0);
signal inst0_pct_header          : std_logic_vector(127 downto 0);
signal inst0_pct_header_valid    : std_logic;

--inst1
constant c_INST1_WRUSEDW_WIDTH   : integer := FIFO_WORDS_TO_Nbits(g_PCTFIFO_SIZE/(g_INFIFO_DATA_WIDTH/8),true);
constant c_INST1_RDUSEDW_WIDTH   : integer := FIFO_WORDS_TO_Nbits(g_PCTFIFO_SIZE/(g_PCTFIFO_RDATA_WIDTH/8),true);
signal inst1_reset_n             : std_logic;
signal inst1_wrempty             : std_logic;
signal inst1_rdusedw             : std_logic_vector(c_INST1_RDUSEDW_WIDTH-1 downto 0);
signal inst1_rdempty             : std_logic;

--inst2
signal inst2_rdreq               : std_logic;
signal inst2_q                   : std_logic_vector(127 downto 0);
signal inst2_rdempty             : std_logic;

signal current_pct_size          : std_logic_vector(15 downto 0);
signal current_pct_size_valid    : std_logic;

signal pct_rdy_reg               : std_logic;

  
begin
-- ----------------------------------------------------------------------------
    -- Reset logic
-- ----------------------------------------------------------------------------  
   sync_reg0 : entity work.sync_reg 
   port map(clk, pct_aclr_n, '1', inst1_reset_n);
   
   inst0_pct_separate_fsm : entity work.pct_separate_fsm
   generic map(
      g_DATA_WIDTH   => g_INFIFO_DATA_WIDTH
   )
   port map(
      clk               => clk,
      reset_n           => reset_n,
      infifo_rdreq      => infifo_rdreq,
      infifo_data       => infifo_data,
      infifo_rdempty    => infifo_rdempty,
      pct_wrreq         => inst0_pct_wrreq,
      pct_data          => inst0_pct_data,
      pct_wrempty       => inst1_wrempty,
      pct_header        => inst0_pct_header,    
      pct_header_valid  => inst0_pct_header_valid
   );
   
   
   inst1_fifo_inst : entity work.fifo_inst   
   generic map(
      dev_family     => dev_family,
      wrwidth        => g_INFIFO_DATA_WIDTH,
      wrusedw_witdth => c_INST1_WRUSEDW_WIDTH, 
      rdwidth        => g_PCTFIFO_RDATA_WIDTH,
      rdusedw_width  => c_INST1_RDUSEDW_WIDTH,   
      show_ahead     => "OFF"
   )
   port map(
      reset_n     => inst1_reset_n,
      wrclk       => clk,
      wrreq       => inst0_pct_wrreq,
      data        => inst0_pct_data,
      wrfull      => open,
      wrempty     => inst1_wrempty,
      wrusedw     => open,
      rdclk       => pct_rdclk,
      rdreq       => pct_data_rdreq,
      q           => pct_data,
      rdempty     => inst1_rdempty,
      rdusedw     => inst1_rdusedw           
   );
   
   inst2_fifo_inst : entity work.fifo_inst   
   generic map(
      dev_family     => dev_family,
      wrwidth        => 128,
      wrusedw_witdth => 3, 
      rdwidth        => 128,
      rdusedw_width  => 3,   
      show_ahead     => "OFF"
   )
   port map(
      reset_n     => inst1_reset_n,
      wrclk       => clk,
      wrreq       => inst0_pct_header_valid,
      data        => inst0_pct_header,
      wrfull      => open,
      wrempty     => open,
      wrusedw     => open,
      rdclk       => pct_rdclk,
      rdreq       => inst2_rdreq,
      q           => inst2_q,
      rdempty     => inst2_rdempty,
      rdusedw     => open           
   );
   
   inst2_rdreq <= NOT inst2_rdempty;
   
   proc_name : process(pct_rdclk, inst1_reset_n)
   begin
      if inst1_reset_n = '0' then 
         current_pct_size        <= (others=>'1');
         current_pct_size_valid  <= '0';
         pct_rdy_reg             <= '0';
      elsif (pct_rdclk'event AND pct_rdclk='1') then
         current_pct_size_valid <= inst2_rdreq;
         
         if pct_data_rdreq = '1' OR inst1_rdempty = '1' then 
            current_pct_size <= (others=>'1');
         elsif current_pct_size_valid = '1' then 
            current_pct_size <= "00" & inst2_q(23 downto 10);
         else 
            current_pct_size <= current_pct_size;
         end if;
         
         if unsigned(current_pct_size) = unsigned(inst1_rdusedw) then 
            pct_rdy_reg <= '1';
         else
            pct_rdy_reg <= '0';
         end if;
         
      end if;
   end process;
   
   pct_rdy           <= pct_rdy_reg;
   pct_header        <= inst2_q;
   pct_data_rdempty  <= inst1_rdempty;
  
end arch;   


