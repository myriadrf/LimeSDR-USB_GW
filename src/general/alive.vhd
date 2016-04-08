-- ----------------------------------------------------------------------------	
-- FILE:	alive.vhd
-- DESCRIPTION:	Frequency divider implementation using counter.
-- DATE:	22 Sep 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:	
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--=============================================
-- Entity
--=============================================
entity alive is	port
	(
		 rst: in std_logic;
		 clk: in std_logic;
		 beat: out std_logic
	);
end alive;

--=============================================
-- Architecture
--=============================================
architecture alive_arch of alive is
	signal cnt: unsigned (23 downto 0);
begin

	cntp: process (clk, rst)
	begin
		if rst = '0' then
			cnt <= (others => '0');
		elsif (clk'event and clk = '1') then
			cnt <= cnt + 1;
		end if;
	end process cntp;
	
	beat <= cnt(22);

end alive_arch;

