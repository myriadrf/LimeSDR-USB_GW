-- ----------------------------------------------------------------------------	
-- FILE: 	LMS7002_DIQ2_sim.vhd
-- DESCRIPTION:	Generates simulation data for LMS7002 DIQ2 port
-- DATE:	Jan 10, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity LMS7002_DIQ2_sim is
	generic( file_name	: string := "file.txt";
				data_width	: integer	:= 12 
	);
	port (
      --input ports 
      clk       	: in std_logic;
      reset_n   	: in std_logic;

		mode			: in std_logic; -- JESD207: 1; TRXIQ: 0
		trxiqpulse	: in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
		ddr_en 		: in std_logic; -- DDR: 1; SDR: 0
		mimo_en		: in std_logic; -- SISO: 1; MIMO: 0
		fidm			: in std_logic; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1. 

		-- Data to BB
		DIQ 			: out std_logic_vector(data_width-1 downto 0);
		fsync			: out std_logic --Frame start
        
        );
end LMS7002_DIQ2_sim;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of LMS7002_DIQ2_sim is
--declare signals,  components here
signal my_sig_name : std_logic_vector (7 downto 0);

--inst0 signals
signal inst0_en 		: std_logic;
signal inst0_en_dly 	: std_logic;
signal inst0_AI 		: std_logic_vector(data_width-1 downto 0);
signal inst0_AQ 		: std_logic_vector(data_width-1 downto 0);
signal inst0_BI 		: std_logic_vector(data_width-1 downto 0);
signal inst0_BQ 		: std_logic_vector(data_width-1 downto 0);


signal SDR_SISO_DIQ : std_logic_vector(data_width-1 downto 0);
signal DDR_MIMO_DIQ : std_logic_vector(data_width-1 downto 0);
signal DDR_SISO_DIQ : std_logic_vector(data_width-1 downto 0);

signal fsync_reg		: std_logic;

signal trxiqpulse_fsync : std_logic;

begin

adc_data_inst0 : entity work.adc_data_sim 
generic map (
	file_name 	=> file_name,
	data_width 	=> data_width
)
port map(
	clk		=> clk,
	reset_n	=> reset_n, 
	en			=> inst0_en, 
	AI			=> inst0_AI, 
	AQ			=> inst0_AQ, 
	BI			=> inst0_BI, 
	BQ			=> inst0_BQ	
	
    );

-- ----------------------------------------------------------------------------
-- ADC read enable signal
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
			inst0_en<='0';
			inst0_en_dly<='0'; 
      elsif (clk'event and clk = '1') then
			if ddr_en='1' AND mimo_en='0' then
				inst0_en<='1'; 
			else 
				inst0_en<= not inst0_en;
			end if;
			inst0_en_dly<=inst0_en; 
 	    end if;
    end process;


-- ----------------------------------------------------------------------------
-- DIQ samples in SISO DDR mode
-- ----------------------------------------------------------------------------
process(clk, inst0_AI, inst0_AQ) 
	begin 
	if clk='1' then 
		DDR_SISO_DIQ<=inst0_AI;
	else 
		DDR_SISO_DIQ<=inst0_AQ;
	end if;
end process;


-- ----------------------------------------------------------------------------
-- DIQ samples in MIMO DDR mode
-- ----------------------------------------------------------------------------
process(clk, inst0_AI, inst0_AQ, inst0_BI, inst0_BQ, inst0_en) 
	begin 
	if clk='1' and inst0_en='0' then 
		DDR_MIMO_DIQ<=inst0_AI;
	elsif clk='0' and inst0_en='0' then 
		DDR_MIMO_DIQ<=inst0_AQ;
	elsif clk='1' and inst0_en='1' then 
		DDR_MIMO_DIQ<=inst0_BI;
	else 
		DDR_MIMO_DIQ<=inst0_BQ;
	end if;
end process;


-- ----------------------------------------------------------------------------
-- 
-- ----------------------------------------------------------------------------
process(clk) 
	begin 
	if clk='1'  then 
		trxiqpulse_fsync<=inst0_en;
	else 
		trxiqpulse_fsync<='0';
	end if;
end process;





-- ----------------------------------------------------------------------------
-- DIQ samples in SISO SDR mode
-- ----------------------------------------------------------------------------
process(inst0_en, inst0_AI, inst0_AQ) 
	begin 
	if inst0_en='0' then 
		SDR_SISO_DIQ<=inst0_AI;
	else 
		SDR_SISO_DIQ<=inst0_AQ;
	end if;
end process;


-- ----------------------------------------------------------------------------
-- fsync signal 
-- ----------------------------------------------------------------------------
fsync_reg <= 	trxiqpulse_fsync when trxiqpulse ='1' else 
               (clk and inst0_en_dly) when ddr_en='1' and mimo_en='0' else
					inst0_en_dly;

fsync <= not fsync_reg when fidm='0' else 
			fsync_reg; 





DIQ <= 	DDR_SISO_DIQ when ddr_en='1' and mimo_en='0' else 
			DDR_MIMO_DIQ when ddr_en='1' and mimo_en='1' else
			SDR_SISO_DIQ; 
  
end arch;   






