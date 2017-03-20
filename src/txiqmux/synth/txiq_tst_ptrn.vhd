-- ----------------------------------------------------------------------------	
-- FILE: 	txiq_tst_ptrn.vhd
-- DESCRIPTION:	Creates test samples for tx IQ in DDR mode
-- DATE:	Jan 27, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity txiq_tst_ptrn is
   generic(
      diq_width   : integer := 12
   );
   port (

      clk      : in std_logic;
      reset_n  : in std_logic;
      fidm     : in std_logic; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
		ptrn_i	: in std_logic_vector(15 downto 0);
		ptrn_q	: in std_logic_vector(15 downto 0);

      diq_h    : out std_logic_vector(diq_width downto 0);
      diq_l    : out std_logic_vector(diq_width downto 0)

        );
end txiq_tst_ptrn;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of txiq_tst_ptrn is
--declare signals,  components here
signal fidm_sync  : std_logic;
signal fsync_int  : std_logic;
signal fsync_ext  : std_logic;
signal ptrn_h     : std_logic_vector(15 downto 0);
signal ptrn_l     : std_logic_vector(15 downto 0);
signal ptrn_i_sync: std_logic_vector(15 downto 0);
signal ptrn_q_sync: std_logic_vector(15 downto 0);
  
begin

--Synch registers
sync_reg0 : entity work.sync_reg
port map(clk, '1', fidm, fidm_sync);

bus_sync_reg0 : entity work.bus_synch
generic map (16)
port map(clk, '1', ptrn_i, ptrn_i_sync);

bus_sync_reg1 : entity work.bus_synch
generic map (16)
port map(clk, '1', ptrn_q, ptrn_q_sync);


----Test pattern 
--ptrn_h <= x"AAAA"; --I
--ptrn_l <= X"5555"; --Q

ptrn_h <= ptrn_i_sync; --I
ptrn_l <= ptrn_q_sync; --Q
 
fsync_gen : process(reset_n, clk)
    begin
      if reset_n='0' then
         fsync_int <= '1';  
      elsif (clk'event and clk = '1') then
 	      fsync_int <= not fsync_int;
 	    end if;
    end process;
    
fsync_ext <= fsync_int when fidm_sync = '1' else NOT fsync_int;

diq_h(diq_width) <= fsync_ext;
diq_l(diq_width) <= fsync_ext;

diq_h(diq_width-1 downto 0) <= ptrn_h(diq_width-1 downto 0);
diq_l(diq_width-1 downto 0) <= ptrn_l(diq_width-1 downto 0);
  
end arch;   





