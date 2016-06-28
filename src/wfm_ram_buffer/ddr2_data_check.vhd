-- ----------------------------------------------------------------------------	
-- FILE: 	ddr2_data_check.vhd
-- DESCRIPTION:	describe
-- DATE:	June 16, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity ddr2_data_check is
	generic(data_w		: integer :=32
			);
  port (
      --input ports 
      clk				: in std_logic;
      reset_n			: in std_logic;
		data_in			: in std_logic_vector(data_w-1 downto 0);
		datain_valid	: in std_logic;
		current_match	: out std_logic;
		all_match		: out std_logic	

        );
end ddr2_data_check;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of ddr2_data_check is
--declare signals,  components here
signal lfsr_data 			: std_logic_vector (data_w-1 downto 0);
signal current_match_s	: std_logic;
signal all_match_s		: std_logic; 

component LFSR is
	generic(
			reg_with	: integer := 32;
			seed		: integer := 32 --starting seed
);
	port (
      clk       	: in std_logic;
      reset_n   	: in std_logic;
		en				: in std_logic;
		data			: out std_logic_vector(reg_with-1 downto 0)     
        );
end component;

  
begin


-- ----------------------------------------------------------------------------
-- LFSR instance
-- ----------------------------------------------------------------------------
lfsr_inst : LFSR
	generic map(
			reg_with	=> data_w,
			seed		=> 32 --starting seed
)
	port map(
      clk       	=> clk, 
      reset_n   	=> reset_n, 
		en				=> datain_valid, 
		data			=> lfsr_data     
        );


  process(reset_n, clk)
    begin
      if reset_n='0' then
        current_match_s<='1'; 
      elsif (clk'event and clk = '1') then
 	      if datain_valid='1' then
				if  lfsr_data=data_in then
					current_match_s<='1';
				else 
					current_match_s<='0';
				end if;
			else 
				current_match_s<=current_match_s;
			end if;
 	    end if;
    end process;


  process(reset_n, clk)
    begin
      if reset_n='0' then
        all_match_s<='1'; 
      elsif (clk'event and clk = '1') then
 	      if current_match_s='0' then
				all_match_s<='0';
			else 
				all_match_s<=all_match_s;
			end if;
 	    end if;
    end process;

all_match<=all_match_s;

current_match<=current_match_s;
  
end arch;   





