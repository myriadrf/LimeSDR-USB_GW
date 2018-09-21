-- ----------------------------------------------------------------------------
-- FILE:          two_fifo_inst.vhd
-- DESCRIPTION:   Two FIFO instances combined to one module
-- DATE:          4:16 PM Wednesday, June 13, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- Data is transferred from first FIFO to second in TRNSF_SIZE chunks.
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FIFO_PACK.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity two_fifo_inst is
   generic(
      DEV_FAMILY     : string  := "MAX 10";
      WRWIDTH        : integer := 32;
      WRUSEDW_WITDTH : integer := 10;     -- wrwords = 2^(WRUSEDW_WITDTH-1)
      RDWIDTH        : integer := 128;
      RDUSEDW_WIDTH  : integer := 9;      -- rdwords = 2^(RDUSEDW_WIDTH-1)
      SHOW_AHEAD     : string  := "OFF";
      TRNSF_SIZE     : integer := 1024;   -- First to second FIFO transfer size in bytes
      TRNSF_N        : integer := 4       -- N transfer cycles    
   );
   port (
      reset_0_n      : in std_logic;       -- reset for first FIFO, has to be synchronous to wrclk
      reset_1_n      : in std_logic;       -- reset for second FIFO, has to be synchronous to wrclk   
      wrclk          : in std_logic;
      wrreq          : in std_logic;
      data           : in std_logic_vector(wrwidth-1 downto 0);
      wrfull         : out std_logic;
      wrempty        : out std_logic;
      wrusedw        : out std_logic_vector(wrusedw_witdth-1 downto 0);
      rdclk          : in std_logic;
      rdreq          : in std_logic;
      q              : out std_logic_vector(rdwidth-1 downto 0);
      rdempty        : out std_logic;
      rdusedw        : out std_logic_vector(rdusedw_width-1 downto 0)   
   );
end two_fifo_inst;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of two_fifo_inst is
--declare signals,  components here
signal reset_n                   : std_logic;

--inst0
constant C_INST0_WRWIDTH         : integer := WRWIDTH;
constant C_INST0_WRUSEDW_WIDTH   : integer := WRUSEDW_WITDTH;
constant C_INST0_RDWIDTH         : integer := WRWIDTH;
constant C_INST0_RDUSEDW_WIDTH   : integer := FIFORD_SIZE(C_INST0_WRWIDTH,C_INST0_RDWIDTH,C_INST0_WRUSEDW_WIDTH);
signal inst0_rdreq               : std_logic;
signal inst0_q                   : std_logic_vector(C_INST0_RDWIDTH-1 downto 0);
signal inst0_rdusedw             : std_logic_vector(C_INST0_RDUSEDW_WIDTH-1 downto 0);

--inst1
constant C_INST1_WRWIDTH         : integer := WRWIDTH;
constant C_INST1_RDWIDTH         : integer := RDWIDTH;
constant C_INST1_RDUSEDW_WIDTH   : integer := RDUSEDW_WIDTH;
constant C_INST1_WRUSEDW_WIDTH   : integer := FIFOWR_SIZE(C_INST1_WRWIDTH,C_INST1_RDWIDTH,C_INST1_RDUSEDW_WIDTH);
signal inst1_wrreq               : std_logic;
signal inst1_data                : std_logic_vector(C_INST1_WRWIDTH-1 downto 0);
signal inst1_wrempty             : std_logic;

type state_type is (idle, check_fifo_0, check_trnsf, trnsf_fifo, check_fifo_1);
signal current_state, next_state : state_type;

signal trnsf_cnt                 : unsigned(7 downto 0);
signal rd_cnt                    : unsigned(15 downto 0);
  
begin
   
-- ----------------------------------------------------------------------------
-- Internal reset logic
-- ----------------------------------------------------------------------------  
   reset_n <= reset_0_n AND reset_1_n;
   
   
-- ----------------------------------------------------------------------------
-- First 2kB FIFO
-- ----------------------------------------------------------------------------
   fifo_2kB_inst0 : entity work.fifo_inst
   generic map(
      dev_family     => DEV_FAMILY,
      wrwidth        => C_INST0_WRWIDTH,
      wrusedw_witdth => C_INST0_WRUSEDW_WIDTH,
      rdwidth        => C_INST0_RDWIDTH,
      rdusedw_width  => C_INST0_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   )
   port map(
      reset_n     => reset_0_n, 
      wrclk       => wrclk,
      wrreq       => wrreq,
      data        => data,
      wrfull      => wrfull,
      wrempty     => wrempty,
      wrusedw     => wrusedw,
      rdclk       => wrclk,
      rdreq       => inst0_rdreq,
      q           => inst0_q,
      rdempty     => open,
      rdusedw     => inst0_rdusedw         
      );
   
-- ----------------------------------------------------------------------------
-- Second 6kB FIFO
-- ----------------------------------------------------------------------------
   inst1_data <= inst0_q;
   
   fifo_4kB_inst1 : entity work.fifo_inst
   generic map(
      dev_family     => DEV_FAMILY,
      wrwidth        => C_INST1_WRWIDTH,
      wrusedw_witdth => C_INST1_WRUSEDW_WIDTH,
      rdwidth        => C_INST1_RDWIDTH,
      rdusedw_width  => C_INST1_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   )
   port map(
         reset_n        => reset_n, 
         wrclk          => wrclk,
         wrreq          => inst1_wrreq,
         data           => inst1_data,
         wrfull         => open,
         wrempty        => inst1_wrempty,
         wrusedw        => open,
         rdclk          => rdclk,
         rdreq          => rdreq,
         q              => q,
         rdempty        => rdempty,
         rdusedw        => rdusedw
      );
   
   -- Count transfer cycles
   process(wrclk, reset_n)
   begin
      if reset_n = '0' then 
         trnsf_cnt <= (others=>'0');
      elsif (wrclk'event AND wrclk='1') then 
         if current_state = check_trnsf then 
            trnsf_cnt <= trnsf_cnt + 1;
         elsif current_state = idle then 
            trnsf_cnt <= (others=>'0');
         else 
            trnsf_cnt <= trnsf_cnt;        
         end if;
      end if;
   end process;
   
   -- Count Read cycle
   process(wrclk, reset_n)
   begin
      if reset_n = '0' then 
         rd_cnt <= (others=>'0');
      elsif (wrclk'event AND wrclk='1') then 
         if current_state = trnsf_fifo then 
            rd_cnt <= rd_cnt + 1;
         else 
            rd_cnt <= (others=>'0');
         end if;
      end if;
   end process;
   
-- ----------------------------------------------------------------------------
-- state machine
-- ----------------------------------------------------------------------------
   fsm_f : process(wrclk, reset_n) begin
      if(reset_n = '0') then
         current_state <= idle;
      elsif(wrclk'event and wrclk = '1')then 
         current_state <= next_state;
      end if;	
   end process;
   
-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
   fsm : process(current_state, inst1_wrempty, inst0_rdusedw, trnsf_cnt, rd_cnt) begin
      next_state <= current_state;
      case current_state is
      
         when idle =>                  -- idle state, wait for both FIFO to be ready
            if unsigned(inst0_rdusedw) > TRNSF_SIZE*8/C_INST0_RDWIDTH - 1 AND inst1_wrempty = '1' then 
               next_state <= check_trnsf;
            else 
               next_state <= idle;
            end if;
            
         when check_trnsf =>           -- Check number of transfer cycle
            if trnsf_cnt < TRNSF_N then 
               next_state <= check_fifo_0;
            else 
               next_state <= check_fifo_1;
            end if;
         
         when check_fifo_0 =>          -- Check if first FIFO has right amount words
            if unsigned(inst0_rdusedw) > TRNSF_SIZE*8/C_INST0_RDWIDTH - 1  then 
               next_state <= trnsf_fifo;
            else 
               next_state <= check_fifo_0;
            end if;
            
         when trnsf_fifo =>            -- Transfer one chunk of data from first to second FIFO 
            if rd_cnt < TRNSF_SIZE*8/C_INST0_RDWIDTH - 1 then 
               next_state <= trnsf_fifo;
            else 
               next_state <= check_trnsf;
            end if;
            
         when check_fifo_1 =>          -- Check if second FIFO is empty
            if inst1_wrempty = '1' then 
               next_state <= idle;
            else 
               next_state <= check_fifo_1;
            end if;
   
         when others => 
            next_state<=idle;
      end case;
   end process;
   
   -- Internal registers
   int_regs : process(wrclk, reset_n)
   begin
      if reset_n = '0' then 
         inst0_rdreq <= '0';
         inst1_wrreq <= '0';
      elsif (wrclk'event AND wrclk='1') then 
         if current_state = trnsf_fifo then 
            inst0_rdreq <= '1';
         else 
            inst0_rdreq <= '0';
         end if;
         
         inst1_wrreq <= inst0_rdreq;
      end if;
   end process;

-- ----------------------------------------------------------------------------
-- Output reg
-- ----------------------------------------------------------------------------


  
end arch;   


