-- ----------------------------------------------------------------------------	
-- FILE:	fpgacfg.vhd
-- DESCRIPTION:	Serial configuration interface to control TX modules
-- DATE:	June 07, 2007
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:	
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;
use work.revisions.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity fpgacfg is
	port (
		-- Address and location of this module
		-- Will be hard wired at the top level
		maddress	: in std_logic_vector(9 downto 0);
		mimo_en	: in std_logic;	-- MIMO enable, from TOP SPI (always 1)
	
		-- Serial port IOs
		sdin	: in std_logic; 	-- Data in
		sclk	: in std_logic; 	-- Data clock
		sen	: in std_logic;	-- Enable signal (active low)
		sdout	: out std_logic; 	-- Data out
	
		-- Signals coming from the pins or top level serial interface
		lreset	: in std_logic; 	-- Logic reset signal, resets logic cells only  (use only one reset)
		mreset	: in std_logic; 	-- Memory reset signal, resets configuration memory only (use only one reset)
		HW_VER	: in std_logic_vector(3 downto 0);
		BOM_VER	: in std_logic_vector(2 downto 0);
		PWR_SRC	: in std_logic;
		
		oen: out std_logic; --nc
		stateo: out std_logic_vector(5 downto 0);
		
		
		--FPGA direct clocking
		phase_reg_sel 	: out std_logic_vector(15 downto 0);
		clk_ind			: out std_logic_vector(4 downto 0);
		cnt_ind			: out std_logic_vector(4 downto 0);
		load_phase_reg	: out std_logic;
		drct_clk_en		: out std_logic_vector(15 downto 0);
		--Interface Config		
		ch_en				: out std_logic_vector(15 downto 0);
		smpl_width		: out std_logic_vector(1 downto 0);
		mimo_int_en		: out std_logic;
		synch_dis		: out std_logic;
		smpl_nr_clr		: out std_logic;
		txpct_loss_clr	: out std_logic;
		rx_en				: out std_logic;
		tx_en				: out std_logic;
		wfm_ch_en		: out std_logic_vector(15 downto 0);
		wfm_play			: out std_logic;
		wfm_load			: out std_logic;
		wfm_smpl_width	: out std_logic_vector(1 downto 0);
		SPI_SS			: out std_logic_vector(15 downto 0);
		
		LMS1_SS			: out std_logic;
--		LMS2_SS			: out std_logic;
--		ADF_SS			: out std_logic;
--		DAC_SS			: out std_logic;
--		POT1_SS			: out std_logic;
		
		LMS1_RESET			: out std_logic;
		LMS1_CORE_LDO_EN	: out std_logic;
		LMS1_TXNRX1			: out std_logic;
		LMS1_TXNRX2			: out std_logic;
		LMS1_TXEN			: out std_logic;
		LMS1_RXEN			: out std_logic;
--		LMS2_RESET			: out std_logic;
--		LMS2_CORE_LDO_EN	: out std_logic;
--		LMS2_TXNRX1			: out std_logic;
--		LMS2_TXNRX2			: out std_logic;
--		LMS2_TXEN			: out std_logic;
--		LMS2_RXEN			: out std_logic;
		GPIO					: out std_logic_vector(6 downto 0);
		FPGA_LED1_CTRL		: out std_logic_vector(2 downto 0);
		FPGA_LED2_CTRL		: out std_logic_vector(2 downto 0);
		FX3_LED_CTRL		: out std_logic_vector(2 downto 0);
		FCLK_ENA				: out std_logic_vector(1 downto 0)
		


	);
end fpgacfg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture fpgacfg_arch of fpgacfg is

	signal inst_reg: std_logic_vector(15 downto 0);		-- Instruction register
	signal inst_reg_en: std_logic;

	signal din_reg: std_logic_vector(15 downto 0);		-- Data in register
	signal din_reg_en: std_logic;
	
	signal dout_reg: std_logic_vector(15 downto 0);		-- Data out register
	signal dout_reg_sen, dout_reg_len: std_logic;
	
	signal mem: marray32x16;									-- Config memory
	signal mem_we: std_logic;
	
	signal oe: std_logic;										-- Tri state buffers control
	signal spi_config_data_rev	: std_logic_vector(143 downto 0);
	
	-- Components
	use work.mcfg_components.mcfg32wm_fsm;
	for all: mcfg32wm_fsm use entity work.mcfg32wm_fsm(mcfg32wm_fsm_arch);

begin


	-- ---------------------------------------------------------------------------------------------
	-- Finite state machines
	-- ---------------------------------------------------------------------------------------------
	fsm: mcfg32wm_fsm port map( 
		address => maddress, mimo_en => mimo_en, inst_reg => inst_reg, sclk => sclk, sen => sen, reset => lreset,
		inst_reg_en => inst_reg_en, din_reg_en => din_reg_en, dout_reg_sen => dout_reg_sen,
		dout_reg_len => dout_reg_len, mem_we => mem_we, oe => oe, stateo => stateo);
		
	-- ---------------------------------------------------------------------------------------------
	-- Instruction register
	-- ---------------------------------------------------------------------------------------------
	inst_reg_proc: process(sclk, lreset)
		variable i: integer;
	begin
		if lreset = '0' then
			inst_reg <= (others => '0');
		elsif sclk'event and sclk = '1' then
			if inst_reg_en = '1' then
				for i in 15 downto 1 loop
					inst_reg(i) <= inst_reg(i-1);
				end loop;
				inst_reg(0) <= sdin;
			end if;
		end if;
	end process inst_reg_proc;

	-- ---------------------------------------------------------------------------------------------
	-- Data input register
	-- ---------------------------------------------------------------------------------------------
	din_reg_proc: process(sclk, lreset)
		variable i: integer;
	begin
		if lreset = '0' then
			din_reg <= (others => '0');
		elsif sclk'event and sclk = '1' then
			if din_reg_en = '1' then
				for i in 15 downto 1 loop
					din_reg(i) <= din_reg(i-1);
				end loop;
				din_reg(0) <= sdin;
			end if;
		end if;
	end process din_reg_proc;

	-- ---------------------------------------------------------------------------------------------
	-- Data output register
	-- ---------------------------------------------------------------------------------------------
	dout_reg_proc: process(sclk, lreset)
		variable i: integer;
	begin
		if lreset = '0' then
			dout_reg <= (others => '0');
		elsif sclk'event and sclk = '0' then
			-- Shift operation
			if dout_reg_sen = '1' then
				for i in 15 downto 1 loop
					dout_reg(i) <= dout_reg(i-1);
				end loop;
				dout_reg(0) <= dout_reg(15);
			-- Load operation
			elsif dout_reg_len = '1' then
				case inst_reg(4 downto 0) is	-- mux read-only outputs
					when "00001" => dout_reg <= x"0002";
					when "00010" => dout_reg <= (15 downto 8 => '0') & std_logic_vector(to_unsigned(COMPILE_REV, 8));
					when "00011" => dout_reg <= (15 downto 8 => '0') & PWR_SRC & BOM_VER & HW_VER;
					when others  => dout_reg <= mem(to_integer(unsigned(inst_reg(4 downto 0))));
				end case;
			end if;			      
		end if;
	end process dout_reg_proc;
	
	-- Tri state buffer to connect multiple serial interfaces in parallel
	--sdout <= dout_reg(7) when oe = '1' else 'Z';

--	sdout <= dout_reg(7);
--	oen <= oe;

	sdout <= dout_reg(15) and oe;
	oen <= oe;
	-- ---------------------------------------------------------------------------------------------
	-- Configuration memory
	-- --------------------------------------------------------------------------------------------- 
	ram: process(sclk, mreset) --(remap)
	begin
		-- Defaults
		if mreset = '0' then	
			--Read only registers
			mem(0)	<= "0000000000001110"; -- 00 frre, Board ID (LimeSDR-USB)
			mem(1)	<= "0000000000000000"; -- 00 free, GW version
			mem(2)	<= "0000000000000000"; -- 00 free, GW revision
			mem(3)	<= "0000000000000000"; --  9 free, BOM_VER[6:4],HW_VER[3:0]
			--FPGA direct clocking
			mem(4)	<= "0000000000000000"; --  0 free, phase_reg_sel
			mem(5)	<= "0000000000000000"; --  0 free, drct_clk_en, 
			mem(6)	<= "0000000000000000"; --  5 free, load_phase_reg, cnt_ind[4:0], clk_ind[4:0]
			--Interface Config
			mem(7)	<= "0000000000000011"; --  0 free, ch_en[15:0]
			mem(8)	<= "0000000100000010"; --  6 free, synch_dis, mimo_int_en, reserved[5:0], smpl_width[1:0]
			mem(9)	<= "0000000000000011"; -- 14 free, txpct_loss_clr, smpl_nr_clr,			
			mem(10)	<= "0000000000000000"; -- 14 free, tx_en, rx_en,
			mem(11)	<= "0000000000000000"; -- 16 free, (Reserved)
			mem(12)	<= "0000000000000011"; --  0 free, wfm_ch_en
			mem(13)	<= "0000000000000000"; --  0 free, Reserved,wfm_load,wfm_play,Reserved
			mem(14)	<= "0000000000000010"; -- 14 free, Reserved,wfm_smpl_width
			mem(15)	<= "0000000000000000"; -- 16 free, (Reserved)
			--Peripheral config
			mem(16)	<= "0000000000011000"; -- 16 free, (Reserved)
			mem(17)	<= "0000000000000010"; -- 16 free, (Reserved)
			mem(18)  <= "1111111111111111"; --  0 free, SPI_SS[15:0]
			mem(19)	<= "0110111101101011"; --  0 free, rsrvd,LMS2_RXEN,LMS2_TXEN,LMS2_TXNRX2,LMS2_TXNRX1,LMS2_CORE_LDO_EN,LMS2_RESET,LMS2_SS,rsrvd,LMS1_RXEN,LMS1_TXEN,LMS1_TXNRX2,LMS1_TXNRX1,LMS1_CORE_LDO_EN,LMS1_RESET,LMS1_SS
			mem(20)	<= "0000000000000011"; --  0 free, (Reserved LMS control)
			mem(21)	<= "0000000000000000"; --  0 free, (Reserved LMS control)
			mem(22)	<= "0000000000000000"; --  0 free, (Reserved LMS control)
			mem(23)	<= "0000000001000100"; --  0 free, (Reserved), GPIO[6:0]	
			
			mem(26)	<= "0000000000000000"; --  0 free, Reserved[15:8],FPGA_LED2_G,FPGA_LED2_R,FPGA_LED2_OVRD,Reserved,FPGA_LED1_G,FPGA_LED1_R,FPGA_LED1_OVRD
			mem(27)	<= "0000000000000000"; --  0 free, Reserved[15:0]
			mem(28)	<= "0000000000000000"; --  0 free, Reserved[15:4],FX3_LED_G,FX3_LED_R,FX3_LED_OVRD
			mem(29)	<= "0000000000000001"; --  0 free, FCLK_ENA[1:0]
			
		elsif sclk'event and sclk = '1' then
				if mem_we = '1' then
					mem(to_integer(unsigned(inst_reg(4 downto 0)))) <= din_reg(14 downto 0) & sdin;
				end if;
				
				if dout_reg_len = '0' then
--					for_loop : for i in 0 to 3 loop 				
--						mem(3)(i+4) <= not mem(3)(i);
--					end loop;
				end if;
				
		end if;
	end process ram;
	
	-- ---------------------------------------------------------------------------------------------
	-- Decoding logic
	-- ---------------------------------------------------------------------------------------------
			--FPGA direct clocking
		phase_reg_sel 	<= mem(4);
		drct_clk_en		<= mem(5);
		clk_ind			<= mem(6) (4 downto 0);
		cnt_ind			<= mem(6) (9 downto 5);
		load_phase_reg	<= mem(6) (10);
		--Interface Config		
		ch_en				<= mem(7);
		smpl_width		<= mem(8) (1 downto 0);
		mimo_int_en		<= mem(8) (8);
		synch_dis		<= mem(8) (9);
		smpl_nr_clr		<= mem(9) (0);
		txpct_loss_clr	<= mem(9) (1);
		rx_en				<= mem(10) (0);
		tx_en				<= mem(10) (1);
		
		wfm_ch_en		<= mem(12) (15 downto 0);
		wfm_play			<= mem(13) (1);
		wfm_load			<= mem(13) (2);
		wfm_smpl_width	<= mem(13) (1 downto 0);

		for_loop : for i in 0 to 15 generate --to prevent SPI_SS to go low on same time as sen
			SPI_SS(i)<= mem(18)(i) OR (NOT sen);
		end generate;
		

		LMS1_SS 				<= mem(19)(0) OR (NOT sen); --to prevent SPI_SS to go low on same time as sen
		LMS1_RESET 			<= mem(19)(1);
		LMS1_CORE_LDO_EN 	<= mem(19)(2);
		LMS1_TXNRX1			<= mem(19)(3); 
		LMS1_TXNRX2 		<= mem(19)(4);
		LMS1_TXEN			<= mem(19)(5); 
		LMS1_RXEN 			<= mem(19)(6);
	
--		LMS2_SS 				<= mem(19)(8) OR (NOT sen); --to prevent SPI_SS to go low on same time as sen
--		LMS2_RESET 			<= mem(19)(9);
--		LMS2_CORE_LDO_EN	<= mem(19)(10); 
--		LMS2_TXNRX1			<= mem(19)(11);
--		LMS2_TXNRX2			<= mem(19)(12);
--		LMS2_TXEN			<= mem(19)(13);
--		LMS2_RXEN			<= mem(19)(14);
		GPIO					<= mem(23) (6 downto 0);
		FPGA_LED1_CTRL		<= mem(26)(2 downto 0);
		FPGA_LED2_CTRL		<= mem(26)(6 downto 4);
		FX3_LED_CTRL		<= mem(28)(2 downto 0);
		FCLK_ENA				<= mem(29)(1 downto 0);


end fpgacfg_arch;
