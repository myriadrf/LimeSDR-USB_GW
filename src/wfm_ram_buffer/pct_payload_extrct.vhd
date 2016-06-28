-- ----------------------------------------------------------------------------	
-- FILE: 	pct_payload_extrct.vhd
-- DESCRIPTION:	extracts only data payload from stream packet
-- DATE:	June 17, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pct_payload_extrct is
	generic (data_w			: integer := 32;
				header_size		: integer := 16; --pct header size in bytes 
				pct_size			: integer := 4096 --pct size in bytes
		);
  port (
      --input ports 
		clk					: in std_logic;
		reset_n				: in std_logic;
		pct_data				: in std_logic_vector(data_w-1 downto 0);
		pct_wr				: in std_logic;
		pct_payload_data	: out std_logic_vector(data_w-1 downto 0);
		pct_payload_valid	: out std_logic;
		pct_payload_dest	: out std_logic_vector(1 downto 0)
	

      --output ports 
        
        );
end pct_payload_extrct;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pct_payload_extrct is
--declare signals,  components here
signal wr_cnt : unsigned (15 downto 0);

signal hdr_payload_reg	: std_logic_vector(data_w-1 downto 0);
 
signal payload_dest_reg	: std_logic_vector(1 downto 0);
signal payload_size_reg	: std_logic_vector(15 downto 0);

  
begin

-- ----------------------------------------------------------------------------
-- Pcket write operation counter
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
        wr_cnt<=(others=>'0'); 
      elsif (clk'event and clk = '1') then
 	      if pct_wr='1' then	
				if wr_cnt<(to_integer(unsigned(payload_size_reg))+header_size)*8/data_w - 1 then 
					wr_cnt<=wr_cnt+1;
				else 
					wr_cnt<=(others=>'0');
				end if; 
			else 
				wr_cnt<=wr_cnt;
			end if;
 	    end if;
    end process;

-- ----------------------------------------------------------------------------
-- to capture header values
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
		if reset_n='0' then
			hdr_payload_reg<=(others=>'1');
		elsif (clk'event and clk = '1') then
			if wr_cnt=0 and pct_wr='1' then 
				hdr_payload_reg<=pct_data;
			else 
				hdr_payload_reg<=hdr_payload_reg;
			end if;
		end if;
    end process;

payload_dest_reg<=hdr_payload_reg(6 downto 5);
payload_size_reg<=hdr_payload_reg(23 downto 8);


-- ----------------------------------------------------------------------------
-- payload_wr signal process
-- ----------------------------------------------------------------------------
process (wr_cnt,payload_size_reg, pct_wr)
begin 
		if wr_cnt>3 and wr_cnt<=(to_integer(unsigned(payload_size_reg))+header_size)*8/data_w - 1 then 
			pct_payload_valid<= pct_wr;
		else 
			pct_payload_valid<= '0';
		end if;		 
end process;

pct_payload_data<=pct_data;
pct_payload_dest<=payload_dest_reg;

end arch;   






