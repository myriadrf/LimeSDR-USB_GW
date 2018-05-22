-- ----------------------------------------------------------------------------
-- FILE:          fifo_trnsf.vhd
-- DESCRIPTION:   Transfers data from one FIFO to another FIFO 
-- DATE:          10:04 AM Tuesday, April 24, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES: Both FIFO has to be Same clock, same data width. 
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity fifo_trnsf is
   generic(
      rdwidth : integer := 64
      );
   port (

      clk            : in  std_logic;
      areset_n       : in  std_logic;
      -- RD side  
      fifo_rdreq     : out std_logic;
      fifo_q         : in  std_logic_vector(rdwidth-1 downto 0);
      fifo_rdempty   : in  std_logic;
      -- WR side  
      fifo_wrreq     : out std_logic;
      fifo_data      : out std_logic_vector(rdwidth-1 downto 0);
      fifo_wrfull    : in  std_logic
   );
end fifo_trnsf;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of fifo_trnsf is
--declare signals,  components here
signal reset_n          : std_logic;
signal my_sig_name      : std_logic_vector (7 downto 0); 
signal cnt              : unsigned(15 downto 0);
signal fifo_rdreq_int   : std_logic;

attribute noprune : boolean;
attribute noprune of cnt : signal is true;

  
begin
   
   -- Asynchronous reset to sync
   sync_reg0 : entity work.sync_reg 
   port map(clk, areset_n, '1', reset_n);
   
   -- FIFO read request signal
   fifo_rdreq_int <= not fifo_rdempty AND not fifo_wrfull AND reset_n;

   -- Counter for debugging
   process(reset_n, clk)
   begin
      if reset_n='0' then
         cnt <= (others=>'0');
      elsif (clk'event and clk = '1') then
         if fifo_rdreq_int = '1' then 
            cnt <= cnt +1;
         else 
            cnt <= cnt;
         end if;
      end if;
   end process;
    
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------    
   fifo_rdreq <= fifo_rdreq_int;   
   fifo_wrreq <= fifo_rdreq_int;
   fifo_data  <= fifo_q;
  
end arch;   
