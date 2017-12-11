-- ----------------------------------------------------------------------------	
-- FILE: 	rxiq_siso_sdr.vhd
-- DESCRIPTION:	rxiq samples in SISO sdr mode
-- DATE:	Jan 13, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity rxiq_siso_sdr is
   generic(
      iq_width					: integer := 12
   );
  port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      fidm		   : in std_logic; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      --Rx interface data 
      DIQ_h		 	: in std_logic_vector(iq_width downto 0);
		DIQ_l	 	   : in std_logic_vector(iq_width downto 0);
      --fifo ports 
      fifo_wfull  : in std_logic;
      fifo_wrreq  : out std_logic;
      fifo_wdata  : out std_logic_vector(iq_width*4-1 downto 0)   
        );
end rxiq_siso_sdr;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of rxiq_siso_sdr is
--declare signals,  components here

signal sdr_reg_0        	: std_logic_vector(iq_width downto 0);

signal diq_pos0_reg       	: std_logic_vector(iq_width-1 downto 0);
signal diq_pos1_reg        : std_logic_vector(iq_width-1 downto 0);
signal diq_pos2_reg       	: std_logic_vector(iq_width-1 downto 0);
signal diq_pos3_reg        : std_logic_vector(iq_width-1 downto 0);

signal diq_pos0_cap_en		: std_logic;
signal diq_pos1_cap_en		: std_logic;
signal diq_pos2_cap_en		: std_logic;
signal diq_pos3_cap_en		: std_logic;

signal sdr_diq_valid    	: std_logic;
signal sdr_fifo_data			: std_logic_vector(iq_width*4-1 downto 0);
signal sdr_fifo_data_valid	: std_logic;

 
begin

sdr_diq_valid<=(sdr_reg_0(iq_width) XOR DIQ_l(iq_width));


 sdr_reg_proc : process(reset_n, clk)
    begin
      if reset_n='0' then
			sdr_reg_0<=(others=>'0');
      elsif (clk'event and clk = '1') then
			sdr_reg_0<=DIQ_l; 
 	    end if;
    end process;

-- ----------------------------------------------------------------------------
-- To capture DIQ data in 0 position (frame start)
-- ----------------------------------------------------------------------------
diq_pos0_cap_en <= not (diq_pos1_cap_en OR diq_pos2_cap_en);

 diq_pos0_reg_proc : process(reset_n, clk)
    begin
      if reset_n='0' then
         diq_pos0_reg 		<= (others=>'0');
			diq_pos1_cap_en 	<= '0'; 
      elsif (clk'event and clk = '1') then
			if DIQ_l(iq_width) = fidm AND sdr_diq_valid='1' AND diq_pos0_cap_en='1' then 
         	diq_pos0_reg 		<= DIQ_l(iq_width-1 downto 0);
				diq_pos1_cap_en	<= '1';
			else 
				diq_pos0_reg   	<= diq_pos0_reg;
				diq_pos1_cap_en	<='0';
			end if; 
 	    end if;
    end process;

-- ----------------------------------------------------------------------------
-- To capture DIQ data in 1 position
-- ----------------------------------------------------------------------------

 diq_pos1_reg_proc : process(reset_n, clk)
    begin
      if reset_n='0' then
         diq_pos1_reg <= (others=>'0');
			diq_pos2_cap_en <= '0';  
      elsif (clk'event and clk = '1') then
			if DIQ_l(iq_width) = NOT fidm AND sdr_diq_valid='1' AND diq_pos1_cap_en='1' then 
         	diq_pos1_reg <= DIQ_l(iq_width-1 downto 0);
				diq_pos2_cap_en <= '1';
			else 
				diq_pos1_reg <= diq_pos1_reg;
				diq_pos2_cap_en <= '0';
			end if; 
 	    end if;
    end process;

-- ----------------------------------------------------------------------------
-- To capture DIQ data in 2 position (frame start)
-- ----------------------------------------------------------------------------

 diq_pos2_reg_proc : process(reset_n, clk)
    begin
      if reset_n='0' then
         diq_pos2_reg <= (others=>'0');
			diq_pos3_cap_en <= '0';  
      elsif (clk'event and clk = '1') then
			if DIQ_l(iq_width) = fidm AND sdr_diq_valid='1' AND diq_pos2_cap_en='1' then 
         	diq_pos2_reg <= DIQ_l(iq_width-1 downto 0);
				diq_pos3_cap_en <= '1';
			else 
				diq_pos2_reg <= diq_pos2_reg;
				diq_pos3_cap_en <= '0';
			end if; 
 	    end if;
    end process;

-- ----------------------------------------------------------------------------
-- To capture DIQ data in 3 position
-- ----------------------------------------------------------------------------
diq_pos3_reg_proc : process(reset_n, clk)
    begin
      if reset_n='0' then
         diq_pos3_reg <= (others=>'0'); 
      elsif (clk'event and clk = '1') then
			if DIQ_l(iq_width) = NOT fidm AND sdr_diq_valid='1' AND diq_pos3_cap_en='1' then 
         	diq_pos3_reg <= DIQ_l(iq_width-1 downto 0);
			else 
				diq_pos3_reg <= diq_pos3_reg;
			end if; 
 	    end if;
    end process;
    
--sdr_fifo_data <= diq_pos0_reg & diq_pos1_reg & diq_pos2_reg & diq_pos3_reg;
sdr_fifo_data <= diq_pos3_reg & diq_pos2_reg & diq_pos1_reg & diq_pos0_reg;

sdr_fifo_data_valid_proc : process(reset_n, clk)
    begin
      if reset_n='0' then
         sdr_fifo_data_valid<='0'; 
      elsif (clk'event and clk = '1') then
			if diq_pos3_cap_en='1' then 
         	sdr_fifo_data_valid <= '1';
			else 
				sdr_fifo_data_valid <= '0';
			end if; 
 	    end if;
    end process;
    
fifo_wdata <= sdr_fifo_data;
fifo_wrreq <= sdr_fifo_data_valid AND NOT fifo_wfull;
    
 
end arch;   







