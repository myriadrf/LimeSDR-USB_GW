
-- ----------------------------------------------------------------------------	
-- FILE: 	bit_unpack.vhd
-- DESCRIPTION:	unpacks data from 32bit words to samples
-- DATE:	March 30, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity comprlaration
-- ----------------------------------------------------------------------------
entity bit_unpack is

  port (
        --input ports 
        clk             : in std_logic;
        reset_n         : in std_logic;
        data_in         : in std_logic_vector(31 downto 0);
        data_in_valid   : in std_logic;
        sample_width    : in std_logic_vector(1 downto 0); --"10"-12bit, "01"-14bit, "00"-16bit;
        --output ports 
        data_out        : out std_logic_vector(63 downto 0);
        data_out_valid  : out std_logic       
        );
end bit_unpack;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of bit_unpack is
--Declare signals,  components here

--inst0 signals
signal inst0_data64_out			: std_logic_vector(63 downto 0);
signal inst0_data_out_valid	: std_logic;

--inst1 signals
signal inst1_data64_out			: std_logic_vector(63 downto 0);
signal inst1_data_out_valid	: std_logic;

signal inst2_data64_out       : std_logic_vector(63 downto 0);
signal inst2_data_out_valid   : std_logic;


--mux0 signals
signal mux0_data64				: std_logic_vector(63 downto 0);
signal mux0_data_out_valid		: std_logic;
signal mux0_sel					: std_logic;

signal mux0_data64_reg			: std_logic_vector(63 downto 0);
signal mux0_data_out_valid_reg: std_logic;


--mux1 signals
signal mux1_data64				: std_logic_vector(63 downto 0);
signal mux1_data_out_valid		: std_logic;
signal mux1_sel					: std_logic;

signal mux1_data64_reg			: std_logic_vector(63 downto 0);
signal mux1_data_out_valid_reg: std_logic;


  
begin


-- ----------------------------------------------------------------------------
-- Component instances
-- ----------------------------------------------------------------------------
unpack_32_to_48_inst0 : entity work.unpack_32_to_48 
port map (
	   clk       		=> clk,
      reset_n   		=> reset_n,
		data_in_wrreq	=> data_in_valid,
		data32_in		=> data_in,
		data64_out		=> inst0_data64_out,
		data_out_valid	=> inst0_data_out_valid
);

unpack_32_to_56_inst1 : entity work.unpack_32_to_56 
port map (
	   clk       		=> clk,
      reset_n   		=> reset_n,
		data_in_wrreq	=> data_in_valid,
		data32_in		=> data_in,
		data64_out		=> inst1_data64_out,
		data_out_valid	=> inst1_data_out_valid
);

unpack_32_to_64_inst2 : entity work.unpack_32_to_64 
port map (
	   clk       		=> clk,
      reset_n   		=> reset_n,
		data_in_wrreq	=> data_in_valid,
		data32_in		=> data_in,
		data64_out		=> inst2_data64_out,
		data_out_valid	=> inst2_data_out_valid
);

-- ----------------------------------------------------------------------------
-- MUX 0 
-- ----------------------------------------------------------------------------

mux0_sel 				<= sample_width(1);

mux0_data64 			<= inst0_data64_out when mux0_sel='1' else 
								inst1_data64_out;
					
mux0_data_out_valid 	<= inst0_data_out_valid when mux0_sel='1' else 
								inst1_data_out_valid;
			
-- ----------------------------------------------------------------------------
-- MUX 0 registers
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin 
	if reset_n = '0' then 
		mux0_data64_reg 			<= (others=> '0');
		mux0_data_out_valid_reg	<= '0';
	elsif (clk'event AND clk='1') then 
		mux0_data64_reg 			<= mux0_data64;
		mux0_data_out_valid_reg <= mux0_data_out_valid;
	end if;
end process;


-- ----------------------------------------------------------------------------
-- MUX 1 
-- ----------------------------------------------------------------------------
mux1_sel 					<= sample_width(1) OR sample_width(0);

mux1_data64 				<= mux0_data64_reg 			when mux1_sel='1' else 
									inst2_data64_out;
					
mux1_data_out_valid 		<= mux0_data_out_valid_reg when mux1_sel='1' else 
									inst2_data_out_valid;
									
-- ----------------------------------------------------------------------------
-- MUX 1 registers
-- ----------------------------------------------------------------------------									
process(clk, reset_n)
begin 
	if reset_n = '0' then 
		mux1_data64_reg 			<= (others=> '0');
		mux1_data_out_valid_reg	<= '0';
	elsif (clk'event AND clk='1') then 
		mux1_data64_reg 			<= mux1_data64;
		mux1_data_out_valid_reg <= mux1_data_out_valid;
	end if;
end process;

-- ----------------------------------------------------------------------------
-- Registers to output ports
-- ----------------------------------------------------------------------------

data_out 		<= mux1_data64_reg;
data_out_valid <=	mux1_data_out_valid_reg;



end arch;   



