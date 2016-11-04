--
-- LAP-EPFL
-- Real Time Embedded System Course
-- R.Beuchat
-- 20070402
-- 20080523
--
-- PIO parallel Port with Set and Clear and Not functions
-- Direction of each bit programmable
--
-- Avalon used with generic size
-- Register mode
-- Mapping:
-- Address	Function Write												Read
-- 0		Direct access to the output port	R/W						internal Port register
-- 1		Set Access,    '1' --> set '1', '0' --> don't change bit	external PIO
-- 2		Clear Access,  '1' --> clr '0', '0' --> don't change bit	external PIO
-- 3		Toggle Access, '1' --> not,     '0' --> don't change bit	external PIO
-- 4		Direction      '1' --> OUT,     '0' --> IN (default)		direction
-- 5		-															0
-- 6		-															0
-- 7		-															0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

entity avfifo is
	generic
	(
		width	: integer:=	32
	);
	port
	(
		clk		: in	std_logic;
		rsi_nrst	: in	std_logic;
		
		chipselect: in	std_logic;
		address: in	std_logic_vector(1 downto 0);
		write		: in	std_logic;
		writedata	: in	std_logic_vector(width-1 downto 0);
		read		: in	std_logic;
		readdata	: out	std_logic_vector(width-1 downto 0);
		
		coe_of_d: out	std_logic_vector(31 downto 0);
		coe_of_wr: out std_logic;
		coe_of_wrfull: in  std_logic;
		
		coe_if_d: in	std_logic_vector(31 downto 0);
		coe_if_rd: out std_logic;
		coe_if_rdempty: in  std_logic;
		
		coe_fifo_rst: out std_logic
		
	);
end avfifo;

architecture avfifo_arch of avfifo is
	signal status_reg : std_logic_vector(width-1 downto 0);
	signal fiford, fiford_reg : std_logic;
	signal zeroes24 : std_logic_vector(23 downto 0);

begin

	zeroes24 <= (others => '0');

	-- Output FIFO
	coe_of_d <= writedata;
	coe_of_wr <= '1' when chipselect = '1' and write = '1' and address = "00" and coe_of_wrfull = '0' else '0';
	
	-- Input FIFO
	fiford <= '1' when chipselect = '1' and read = '1' and address = "01" and coe_if_rdempty = '0' else '0';

	-- Read detect register
	frd_proc: process(clk, rsi_nrst)
	begin
		if rsi_nrst = '0' then
			fiford_reg <= '0';
		elsif rising_edge(clk) then
			fiford_reg <= fiford;
		end if;
	end process frd_proc;
	coe_if_rd <= '1' when fiford_reg = '0' and fiford = '1' else '0';
	
	-- Status register
	st_proc: process(clk, rsi_nrst)
	begin
		if rsi_nrst = '0' then
			status_reg <= (others => '0');
		elsif rising_edge(clk) then
			status_reg(1 downto 0) <= coe_of_wrfull & coe_if_rdempty;
		end if;
	end process st_proc;
	
	-- Control register
	ct_proc: process(clk, rsi_nrst)
	begin
		if rsi_nrst = '0' then
			coe_fifo_rst <= '0';
		elsif rising_edge(clk) then
			if (chipselect = '1') and (write = '1') and (address = "11") then
				coe_fifo_rst <= writedata(0);
			end if;
		end if;
	end process ct_proc;	
	

	-- Avalon data output mux
	rd_proc: process(address, status_reg, coe_if_d) 
	begin
		case address is
			when "01" => readdata <= coe_if_d;
			when "10" => readdata <= status_reg;		-- Status register to the Avalon bus
			when others => readdata <= (others => '0');			
		end case;
	end process rd_proc;



end avfifo_arch;

