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
-- altera vhdl_input_version vhdl_2008
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
      g_PCT_MAX_SIZE          : integer := 4096; -- Maximum packet size in bytes 
      g_PCT_HDR_SIZE          : integer := 16;   -- Packet header size in bytes
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
      pct_header        : out std_logic_vector(g_PCT_HDR_SIZE*8-1 downto 0);
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
-- Constants
constant c_MAX_PCT_WORDS         : integer := g_PCT_MAX_SIZE*8/g_PCTFIFO_RDATA_WIDTH;
constant c_PCT_HDR_WORDS         : integer := g_PCT_HDR_SIZE*8/g_PCTFIFO_RDATA_WIDTH;
constant c_RD_RATIO              : integer := g_PCTFIFO_RDATA_WIDTH/8;

-- inst0
signal inst0_pct_wrreq           : std_logic;          
signal inst0_pct_data            : std_logic_vector(g_INFIFO_DATA_WIDTH-1 downto 0);
signal inst0_pct_header          : std_logic_vector(g_PCT_HDR_SIZE*8-1 downto 0);
signal inst0_pct_header_valid    : std_logic;

-- inst1
constant c_INST1_WRUSEDW_WIDTH   : integer := FIFO_WORDS_TO_Nbits(g_PCT_MAX_SIZE/(g_INFIFO_DATA_WIDTH/8),true);
constant c_INST1_RDUSEDW_WIDTH   : integer := FIFO_WORDS_TO_Nbits(g_PCT_MAX_SIZE/(g_PCTFIFO_RDATA_WIDTH/8),true);
signal inst1_reset_n             : std_logic;
signal inst1_wrempty             : std_logic;
signal inst1_rdusedw             : std_logic_vector(c_INST1_RDUSEDW_WIDTH-1 downto 0);
signal inst1_rdempty             : std_logic;

-- inst2
signal inst2_rdreq               : std_logic;
signal inst2_q                   : std_logic_vector(g_PCT_HDR_SIZE*8-1 downto 0);
signal inst2_rdempty             : std_logic;

-- internal signals
signal pct_header_valid          : std_logic;
signal pct_words                 : unsigned(15 downto 0);
signal pct_rdy_reg               : std_logic;

  
begin
-- ----------------------------------------------------------------------------
-- Reset logic
-- ----------------------------------------------------------------------------  
   sync_reg0 : entity work.sync_reg 
   port map(clk, pct_aclr_n AND reset_n, '1', inst1_reset_n);

-- ----------------------------------------------------------------------------
-- Packet separate state machine
-- ----------------------------------------------------------------------------    
   inst0_pct_separate_fsm : entity work.pct_separate_fsm
   generic map(
      g_DATA_WIDTH   => g_INFIFO_DATA_WIDTH,
      g_PCT_MAX_SIZE => g_PCT_MAX_SIZE,
      g_PCT_HDR_SIZE => g_PCT_HDR_SIZE
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
   
-- ----------------------------------------------------------------------------
-- FIFO for storing one packet
-- ----------------------------------------------------------------------------   
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

-- ----------------------------------------------------------------------------
-- FIFO for storing packet header
-- ----------------------------------------------------------------------------
   inst2_fifo_inst : entity work.fifo_inst   
   generic map(
      dev_family     => dev_family,
      wrwidth        => g_PCT_HDR_SIZE*8,
      wrusedw_witdth => 3, 
      rdwidth        => g_PCT_HDR_SIZE*8,
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

-- ----------------------------------------------------------------------------
-- Internal processes 
-- ----------------------------------------------------------------------------
   -- Packet header valid
   pct_hdr_valid_proc : process(pct_rdclk, reset_n)
   begin
      if reset_n = '0' then 
         pct_header_valid <= '0';
      elsif (pct_rdclk'event AND pct_rdclk='1') then 
         pct_header_valid <= inst2_rdreq;
      end if;
   end process;
   
   -- Capture packet size in bytes from packet header and convert to FIFO read words count
   pct_words_proc : process(pct_rdclk, reset_n)
   begin
      if reset_n = '0' then 
         pct_words  <= (others=>'1');
      elsif (pct_rdclk'event AND pct_rdclk='1') then
         
         if pct_data_rdreq = '1' OR inst1_rdempty = '1' then 
            pct_words <= (others=>'1');
         elsif pct_header_valid = '1' then
            -- For compatibility: if there are no packet size inserted in packet header
            --                    then  pct_words = max number of packet words
            if inst2_q(23 downto 8) = "0000000000000000" then 
               pct_words <= to_unsigned(c_MAX_PCT_WORDS,pct_words'length);
            else 
               pct_words <= unsigned(inst2_q(23 downto 8))/c_RD_RATIO + c_PCT_HDR_WORDS;
            end if;
         else 
            pct_words <= pct_words;
         end if;
         
      end if;
   end process;
   
-- ----------------------------------------------------------------------------
-- Output registers
-- ---------------------------------------------------------------------------- 
   out_reg : process(pct_rdclk, reset_n)
   begin
      if reset_n = '0' then 
         pct_rdy_reg <= '0';
      elsif (pct_rdclk'event AND pct_rdclk='1') then 
      
         if unsigned(inst1_rdusedw) = pct_words  then 
            pct_rdy_reg <= '1';
         else
            pct_rdy_reg <= '0';
         end if;
         
      end if;
   end process;
   
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------   
   pct_rdy           <= pct_rdy_reg;
   pct_header        <= inst2_q;
   pct_data_rdempty  <= inst1_rdempty;
  
end arch;   


