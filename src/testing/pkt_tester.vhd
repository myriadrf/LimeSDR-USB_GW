-- ----------------------------------------------------------------------------	
-- FILE: 	pkt_tester.vhd
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
entity pkt_tester is
	generic( busw 		: integer :=32;
				pkt_size	: integer :=4096
	);
  port (
        --input ports 
		  clk       		: in std_logic;
        reset_n   		: in std_logic;
		  data_format_sel	: in std_logic; -- 1 increasing sequence in packets, 0 only increasignsequence;
		  rdreq				: in std_logic;
		  data				: out std_logic_vector(busw-1 downto 0)

        --output ports 
        
        );
end pkt_tester;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pkt_tester is
--declare signals,  components here
signal pktdata_cnt : unsigned(10 downto 0);
signal data_cnt	 : unsigned(busw-1 downto 0);
type array_type  is array (0 to 7) of std_logic_vector(11 downto 0);
signal cnt_data : array_type;
type  array_type2  is array (0 to 6) of std_logic_vector(31 downto 0);
signal test_data : array_type2;
signal pkt_data	: std_logic_vector(31 downto 0);
signal pkt_cnt		: unsigned(15 downto 0);
signal rdreq_reg	: std_logic;
signal smpl_cnt	: unsigned(2 downto 0);

  
begin

process(data_cnt)
	begin 
		cnt_data(0) <= '0' & std_logic_vector(pktdata_cnt);
		cnt_data(1) <= '0' & std_logic_vector(pktdata_cnt+1);
		cnt_data(2) <= '0' & std_logic_vector(pktdata_cnt+2);
		cnt_data(3) <= '0' & std_logic_vector(pktdata_cnt+3);
		cnt_data(4) <= '0' & std_logic_vector(pktdata_cnt+4);
		cnt_data(5) <= '0' & std_logic_vector(pktdata_cnt+5);
		cnt_data(6) <= '0' & std_logic_vector(pktdata_cnt+6);
		cnt_data(7) <= '0' & std_logic_vector(pktdata_cnt+7);
end process;

test_data(0) <=x"0F0F0F0F";		-- header 0
test_data(1) <=x"0F0F0F0F";		-- header 1
test_data(2) <=(others=>'1');		-- header 2
test_data(3) <=(others=>'1');		-- header 3
test_data(4) <=cnt_data(2)(7 downto 0) & cnt_data(1) & cnt_data(0);										--x"02001000";
test_data(5) <=cnt_data(5)(3 downto 0) & cnt_data(4) & cnt_data(3) & cnt_data(2)(11 downto 8);	--x"50040030";
test_data(6) <=cnt_data(7) & cnt_data(6) & cnt_data(5)(11 downto 4);										--x"00700600";

--simple counter so send in bus 
  process(reset_n, clk)
    begin
      if reset_n='0' then
        data_cnt<=(others=>'0');
			rdreq_reg<='0'; 
 	    elsif (clk'event and clk = '1') then
				rdreq_reg<=rdreq;
 	      if rdreq='1' then 
				data_cnt<=data_cnt+1;
			else 
				data_cnt<=data_cnt;
			end if;
 	    end if;
    end process;
	 
	 
	   process(reset_n, clk)
    begin
      if reset_n='0' then
        pkt_cnt<=(others=>'0');
 	    elsif (clk'event and clk = '1') then
 	      if rdreq_reg='1' then 
				if pkt_cnt <  pkt_size/(busw/8)-1 then 
					pkt_cnt<=pkt_cnt+1;
				else 
					pkt_cnt<=(others=>'0');
				end if;				
			else 
					pkt_cnt<=pkt_cnt;
			end if;
 	    end if;
    end process;

	 
	   process(reset_n, clk)
    begin
      if reset_n='0' then
			smpl_cnt<=(others=>'0');
 	    elsif (clk'event and clk = '1') then
			if pkt_cnt > 3 then 
				if smpl_cnt < 2 then 
					smpl_cnt<=smpl_cnt+1;
				else 
					smpl_cnt<=(others=>'0');
				end if;
			else 
				smpl_cnt<=smpl_cnt;
			end if;
 	    end if;
    end process;


	 
	 
	 
	 
	 data <= std_logic_vector(data_cnt) when data_format_sel='0' else 
			  (others=>'1');
  
end arch;   




