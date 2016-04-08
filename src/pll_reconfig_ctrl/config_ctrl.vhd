-- ----------------------------------------------------------------------------	
-- FILE: 	config_ctrl.vhd
-- DESCRIPTION:	controls altpll_reconfig module
-- DATE:	April 6, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity config_ctrl is
port(
	clk 	: in std_logic;
	rst 	: in std_logic;
	busy 	: in std_logic;
	
	addr 			: in std_logic_vector(7 downto 0);
	rd_data 		: in std_logic;
	spi_data		: in std_logic_vector(143 downto 0);
	en_config	: in	std_logic;
	en_clk		: out std_logic;
	wr_rom 		: out std_logic;
	reconfig		: out std_logic;
	config_data : out std_logic
);
end config_ctrl;

architecture arch of config_ctrl is
	type fsm_type is (idle, s0, w0, s1, w1);
	
	signal state_r, state_n : fsm_type;
	signal fall_r, fall_n : std_logic_vector(1 downto 0);
	signal q_r, q_n : std_logic;
	signal addr_r, addr_n : std_logic_vector(7 downto 0);
	signal clk_ctrl_r, clk_ctrl_n : std_logic;
	
	signal config 	 : std_logic;
	signal stop_clk : std_logic;
begin

	reg_proc : process(clk, rst)
	begin
		if rst = '1' then
			state_r 		<= idle;
			clk_ctrl_r  <= '0';
			addr_r  		<= (others => '0');
			fall_r  		<= (others => '0');
			q_r 	  		<= '0';
		elsif rising_edge(clk) then
			state_r 		<= state_n;
			clk_ctrl_r	<= clk_ctrl_n;
			addr_r		<= addr_n;
			q_r			<= q_n;
			fall_r		<= fall_n;
		end if;	
	end process;
	
	addr_n <= addr;
	fall_n <= fall_r(0) & en_config;
	
	config 	<= '1' when fall_r = "01" else '0';	-- detect config. signal change from '0' to '1'
	stop_clk <= '1' when fall_r = "10" else '0';	-- detect config. signal change from '1' to '0'
	
	data_proc : process(spi_data, q_r, rd_data, addr_r)
	begin
		q_n <= q_r;
		if rd_data = '1' then
			q_n <= spi_data(to_integer(unsigned(addr_r)));
		end if;
	end process;
	
	config_data <= q_r;
	en_clk <= clk_ctrl_r;
	
	ctrl_proc : process(busy, state_r, config, clk_ctrl_r, stop_clk)
	begin
		state_n    <= state_r;
		clk_ctrl_n <= clk_ctrl_r;
		wr_rom   <= '0';
		reconfig <= '0';
		case state_r is
			when idle =>		-- wait for configuration commnad
				if config = '1' and busy = '0' then
					state_n <= s0;
				else
					if stop_clk = '1' then
						clk_ctrl_n <= '0';
					end if;
					state_n <= state_r;
				end if;
			when s0 => 			-- write data from SPI reg. to the altera pll reconfiguration core
				wr_rom <= '1';
				state_n <= w0;
			when w0 =>			-- wait
				if busy = '0' then
					state_n <= s1;
				else
					state_n <= state_r;
				end if;			--- assert reconfiguration signal
			when s1 =>
				reconfig <= '1';
				state_n <= w1;
			when w1 =>			-- disable clock output
				if busy = '0' then
					state_n <= idle;
					clk_ctrl_n <= '1';		-- enable PLL clock input
				else
					state_n <= state_r;
				end if;
			when others => 
				state_n <= idle;
		end case;
	end process;
end arch;