-- ----------------------------------------------------------------------------	
-- FILE: 	sl_ctrl.vhd
-- DESCRIPTION:	writes to fifo even number of samples
-- DATE:	Jan 25, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sl_ctrl is
port(
	clk 	: in std_logic;
	rstn	: in std_logic;
	wrreq	: in std_logic;
	stream_load	: in std_logic;
	data		: in std_logic_vector(15 downto 0);
	wrusedw		: in std_logic_vector(13 downto 0);
	
	str_load_o  : out std_logic;
	wrreq_o		: out std_logic;
	data_o		: out std_logic_vector(15 downto 0)
);
end sl_ctrl;

architecture arch of sl_ctrl is
	constant data_const : std_logic_vector(15 downto 0) := x"8000";	-- default data value
	
	type state_type is (s0, s1, s2);
	
	signal f_r, f_n 	: std_logic;		-- flag register for rising edge detection
	signal s_r, s_n 	: state_type;		-- state register
	signal sl_r, sl_n : std_logic;		-- delay register
	signal r_edge, edge		: std_logic;			-- signal for rising edge detection
	signal delay_r, delay_n : std_logic_vector(7 downto 0);
begin
	reg_proc : process(clk, rstn)
	begin
		if rstn = '0' then
			f_r <= '1';
			sl_r <= '1';
			s_r <= s0;
			delay_r <= (others => '1');
		elsif rising_edge(clk) then
			f_r <= f_n;
			sl_r <= sl_n;
			s_r <= s_n;
			delay_r <= delay_n;
		end if;
	end process reg_proc;
	
	f_n 	<= stream_load;					-- shift in stream_load signal into flag register
	edge 	<= stream_load xor f_r;	-- detect rising edge and decide if write operation is neccessary
	r_edge <= stream_load and not(f_r);
	sl_n <= stream_load when edge = '1' else sl_r;
	
	delay_n <= delay_r(6 downto 0) & sl_n;
	
	-- control process
	ctrl_proc : process(r_edge, wrusedw, s_r, stream_load, data, wrreq)
	begin
	s_n     <= s_r;
	data_o <= data;
	wrreq_o <= wrreq;
		case s_r is
			when s0 =>
				if (r_edge = '1' and ((wrusedw(1 downto 0) /= "00") or (wrusedw(1 downto 0) /= "11"))) then -- if rising edge detected
					s_n 	  <= s1;		-- jump to the second cycle
				end if;
			when s1 =>
				wrreq_o  <= '1';			-- assert write req.
				data_o 	<= data_const;	-- with data accompanying it
				s_n		<= s2;		-- jump to the idle state
			when s2 =>
				wrreq_o  <= '1';			-- assert write req.
				data_o 	<= data_const;	-- with data accompanying it
				s_n		<= s0;		-- jump to the idle state
			when others =>
				s_n <= s0;
		end case;
	end process;

	str_load_o <= delay_r(7);	-- output delayed by eigth clock cycles
end arch;