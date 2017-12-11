-- ----------------------------------------------------------------------------	
-- FILE: 	rxiq.vhd
-- DESCRIPTION:	describe
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity rxiq is
   generic( 
      dev_family	: string := "Cyclone IV E";
      iq_width		: integer := 12
   );
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      --Mode settings
      trxiqpulse	: in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
		ddr_en 		: in std_logic; -- DDR: 1; SDR: 0
		mimo_en		: in std_logic; -- SISO: 1; MIMO: 0
		ch_en			: in std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.  
		fidm			: in std_logic; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      --Rx interface data 
      DIQ_h		 	: in std_logic_vector(iq_width downto 0);
		DIQ_l	 	   : in std_logic_vector(iq_width downto 0);
      --fifo ports 
      fifo_wfull  : in std_logic;
      fifo_wrreq  : out std_logic;
      fifo_wdata  : out std_logic_vector(iq_width*4-1 downto 0)        
        );
end rxiq;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of rxiq is
--declare signals,  components here

--inst0 signals
signal inst0_fifo_wrreq : std_logic;
signal inst0_fifo_wdata : std_logic_vector(iq_width*4-1 downto 0);
signal inst0_reset_n		: std_logic;

--inst1 signals
signal inst1_fifo_wrreq : std_logic;
signal inst1_fifo_wdata : std_logic_vector(iq_width*4-1 downto 0);
signal inst1_reset_n		: std_logic;

signal mux_fifo_wrreq	: std_logic;
signal mux_fifo_wdata	: std_logic_vector(iq_width*4-1 downto 0);

signal fifo_wrreq_reg   : std_logic;
signal fifo_wdata_reg   : std_logic_vector(iq_width*4-1 downto 0);
  
begin
 
 
 -- ----------------------------------------------------------------------------
-- Synchronous resets for instances
-- ----------------------------------------------------------------------------
inst0_reset_proc : process(reset_n, clk)
begin
   if reset_n ='0' then 
      inst0_reset_n <= '0';
   elsif (clk'event and clk='1') then 
      if mimo_en = '0' then 
         inst0_reset_n <= '1';
      else 
         inst0_reset_n <= '0';
      end if;
   end if;
end process;

inst1_reset_proc : process(reset_n, clk)
begin
   if reset_n ='0' then 
      inst1_reset_n <= '0';
   elsif (clk'event and clk='1') then 
      if mimo_en = '1' then 
         inst1_reset_n <= '1';
      else 
         inst1_reset_n <= '0';
      end if;
   end if;
end process;
 
 
 inst0_rxiq_siso : entity work.rxiq_siso
   generic map (
      iq_width    => 12
   )
   port map (
      clk         => clk,
      reset_n     => inst0_reset_n,
      ddr_en 	   => ddr_en,
      fidm		   => fidm,
      DIQ_h		 	=> DIQ_h,
		DIQ_l	 	   => DIQ_l,
      fifo_wfull  => fifo_wfull,
      fifo_wrreq  => inst0_fifo_wrreq,
      fifo_wdata  => inst0_fifo_wdata
        );
        
 inst1_rxiq_mimo : entity work.rxiq_mimo
   generic map (
      iq_width    => 12
   )
   port map (
      clk         => clk,
      reset_n     => inst1_reset_n,
		trxiqpulse	=> trxiqpulse,
      ch_en		   => ch_en,
      fidm		   => fidm,
      DIQ_h		 	=> DIQ_h,
		DIQ_l	 	   => DIQ_l,
      fifo_wfull  => fifo_wfull,
      fifo_wrreq  => inst1_fifo_wrreq,
      fifo_wdata  => inst1_fifo_wdata
        );  
      
 --output mux
mux_fifo_wrreq <= inst0_fifo_wrreq when mimo_en='0' else inst1_fifo_wrreq;
mux_fifo_wdata <= inst0_fifo_wdata when mimo_en='0' else inst1_fifo_wdata;

--output register
process (reset_n, clk)
begin 
   if reset_n='0' then
      fifo_wdata_reg <=(others=>'0');
      fifo_wrreq_reg <='0';
   elsif (clk'event AND clk = '1') then 
      fifo_wdata_reg <=mux_fifo_wdata;
      fifo_wrreq_reg <=mux_fifo_wrreq;
   end if;
end process;

fifo_wdata <= fifo_wdata_reg;
fifo_wrreq <= fifo_wrreq_reg AND NOT fifo_wfull;




  
end arch;   






