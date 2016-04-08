-- ----------------------------------------------------------------------------	
-- FILE:	txtspcfg.vhd
-- DESCRIPTION:	Serial configuration interface to control TX modules
-- DATE:	June 07, 2007
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:	
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity txtspcfg is
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
		--txen: in std_logic;	-- Power down all modules when txen=0 not used
		
		oen: out std_logic; --nc
		
		-- PLL reconfiguration lines
		spi_pll_locked			: in std_logic;
		spi_config_controls	: out std_logic_vector(1 downto 0);
		spi_config_data 		: out std_logic_vector(143 downto 0);
		
		-- Control lines		(spi controlled signals)
		stream_load		: out std_logic;  --	load data to ram
		stream_txen		: out std_logic;	-- enable streaming from ram
		stream_rxen		: out std_logic;	-- enable streaming to fx3
		stream_rxdsrc	: out std_logic;
		lms_gpio0		: out std_logic;
		lms_gpio1		: out std_logic;
		lms_gpio2		: out std_logic;
		fx3_reset		: out std_logic;
		ps_en_0			: out std_logic;
		ps_en_1			: out std_logic;
		up_dn_0			: out std_logic;
		up_dn_1			: out std_logic;
		phase				: out std_logic_vector(9 downto 0);
		pll_areset		: out std_logic;
--		en		: out std_logic;
		stateo: out std_logic_vector(5 downto 0);
		lte_synch_dis			: out std_logic;	-- 1 - LTE synchronization disabled, 0 - LTE synchronization enabled
		lte_txpct_loss_clr 	: out std_logic;  -- 1 - clear txpct_loss flag on LTE packets,
		lte_mimo_en				: out std_logic;	-- 1 - mimo mode enabled
		lte_ch_en				: out std_logic_vector (15 downto 0); 	--LSb first chanell
		lte_smpl_width			: out std_logic_vector(1 downto 0); 	-- "10"-12bit, "01"-14bit, "00"-16bit;
		lte_clr_smpl_nr		: out std_logic;
		lms_rst					: out std_logic;
		lms_ss					: out std_logic;
		phase_reg_sel			: out std_logic_vector(7 downto 0);
		drct_clk_en				: out std_logic

	);
end txtspcfg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture txtspcfg_arch of txtspcfg is

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
					when "00011" => dout_reg <= mem(3)(15 downto 3) & spi_pll_locked & mem(3)(1 downto 0);
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
			mem(0)  	<= "1000000010000011"; --  16 free, UNUSED[15:0],gw_version[4:0] (03 mimo mode)
			mem(1)  	<= "0000000000000011"; --  0 free, lte_ch_en[15:0]
			mem(2)  	<= "0010010000010100"; --  3 free, UNUSED[15],ps_en_1,up_dn_1,pll_areset, ps_en_0, up_dn_0, phase[9:0]
			mem(3)  	<= "0000000000000000"; --  14 free, UNUSED[15:3],PLL_LOCKED, RESERVED, PLL_EN_CONFIG
			--mem(3)  	<= "0000000000000000"; --10 free, UNUSED[15:6],PLL_STATUS, PLL_IND[3:0], PLL_EN_CONFIG
			mem(4)  	<= "0000000101110000"; --  5 free, CHP_current[10:8],VCO_pScale, LF_Res[6:2],LF_Cap[1:0] 
			mem(5)  	<= "0000000001001010"; --  10 free, UNUSED[8:0],lte_clr_smpl_nr, lte_synch_dis, ch_sel, stream_rxdsrc, stream_rxen, stream_txen, stream_load
			mem(6)  	<= "0000000000000000"; --  13 free, UNUSED[12:0], lms_gpio2 (0 - out1), lms_gpio1 ,lms_gpio0
			mem(7)  	<= "0000000000001010"; --  11 free, lte_txpct_loss_clr, UNUSED[10:0], lte_smpl_width[1:0], lte_mimo_en, fx3_reset
			mem(8)  	<= "0000000000000000"; --  0 free, N_high_cnt[15:8],N_low_cnt[7:0]
			mem(9)	<= "0000000100000001"; --  0 free, M_high_cnt[15:8],M_low_cnt[7:0]
			mem(10)	<= "0000000100000001"; --  0 free, c0_high_cnt[15:8],c0_low_cnt[7:0]
			mem(11)	<= "0000000100000001"; --  0 free, c1_high_cnt[15:8],c1_low_cnt[7:0]
			mem(12)	<= "0000000000000000"; --  0 free, c2_high_cnt[15:8],c2_low_cnt[7:0]
			mem(13)	<= "0000000000000000"; --  0 free, c3_high_cnt[15:8],c3_low_cnt[7:0]
			mem(14)	<= "0000000000000000"; --  0 free, c4_high_cnt[15:8],c4_low_cnt[7:0]
			mem(15)	<= "0001010100000001"; -- 2 free, c4_odd_div, c4_bypass, c3_odd_div, c3_bypass, c2_odd_div, c2_bypass, c1_odd_div, c1_bypass, c0_odd_div, c0_bypass, M_odd_div, M_bypass, N_odd_div, N_bypass
			mem(16)  <= "0000000000000000"; -- PLL_LOCKED[15:0]			
			mem(20)	<= "0000000001111111"; -- FMC, RFDIO, ETC control
			mem(21)	<= "0000000000000000"; -- RFDIO GPIOs
			mem(22)	<= "0000000000010101"; -- drct_clk_en, phase_reg_sel
			--
			mem(29)  <= "0000000000001110"; -- 00 frre, Board ID (SoDeRa PCIE)
			mem(30)  <= "0000000000000001"; -- 00 free, Function (1)
			mem(31)  <= "0000000000001000"; -- 00 free, GW wersion (8)
			
			
		elsif sclk'event and sclk = '1' then
				if mem_we = '1' then
					mem(to_integer(unsigned(inst_reg(4 downto 0)))) <= din_reg(14 downto 0) & sdin;
				end if;
				
				--if dout_reg_len = '0' then
					--mem(9)  <= bsigi(14 downto 0) & bstate;
					--mem(10) <= bsigq(7 downto 0) & bsigi(22 downto 15);
					--mem(11)(14 downto 0) <= bsigq(22 downto 8);
				--end if;
				
		end if;
	end process ram;
	
	-- ---------------------------------------------------------------------------------------------
	-- Decoding logic
	-- ---------------------------------------------------------------------------------------------
	--edit by new map
	lte_ch_en				<= mem(1) (15 downto 0);
	phase						<= mem(2)(9 downto 0);
	up_dn_0					<= mem(2)(10);
	ps_en_0					<= mem(2)(11);
	pll_areset				<= mem(2)(12);	
	up_dn_1					<= mem(2)(13);
	ps_en_1					<= mem(2)(14);	
	lte_mimo_en				<= mem(7)(1);
	lte_smpl_width 		<= mem(7) (3 downto 2);	
	stream_load				<= mem(5)(0);
	stream_txen				<= mem(5)(1);
	stream_rxen				<= mem(5)(2);
	stream_rxdsrc			<= mem(5)(3);
	lte_synch_dis			<= mem(5)(5);
	lte_clr_smpl_nr		<= mem(5)(6);
	lms_gpio0				<= mem(6)(0);
	lms_gpio1				<= mem(6)(1);
	lms_gpio2				<= mem(6)(2);
	lte_txpct_loss_clr	<= mem(7)(15);
	fx3_reset				<= mem(7)(0);
	lms_rst					<= mem(20)(0);
	lms_ss					<= mem(20)(1);
	drct_clk_en				<= mem(22) (8);
	phase_reg_sel			<= mem(22) (7 downto 0);
	drct_clk_en				<= mem(22) (8);
	phase_reg_sel			<= mem(22) (7 downto 0);
	

 	
	-- PLL
	spi_config_data_rev 	  <=  "00" & mem(4) (1 downto 0) & mem(4) (6 downto 2)  & mem(4) (7)  & "00000" & mem(4) (10 downto 8) &
	                     mem(15) (0) & mem(8 ) (15  downto 8) & --N
                        mem(15) (1) & mem(8 ) (7 downto 0) &
                        
                        mem(15) (2) & mem(9 ) (15  downto 8) & --M 
                        mem(15) (3) & mem(9 ) (7 downto 0) &
                        
                        mem(15) (4 ) & mem(10) (15 downto 8) & --c0
                      	mem(15) (5 ) & mem(10) (7  downto 0) &
                      	 
                      	mem(15) (6 ) & mem(11) (15 downto 8) & --c1
                       	mem(15) (7 ) & mem(11) (7  downto 0) & 
                        
                        mem(15) (8 ) & mem(12) (15 downto 8) & --c2
                        mem(15) (9 ) & mem(12) (7  downto 0) &
                        
                        mem(15) (10) & mem(13) (15 downto 8) & --c3
                        mem(15) (11) &	mem(13) (7  downto 0) &
  
                        mem(15) (12) & mem(14) (15 downto 8) & --c4
                        mem(15) (13) & mem(14) (7  downto 0) ;
								
								
for_lop : for i in 0 to 143 generate
   spi_config_data(i) <= spi_config_data_rev(143-i);  
end generate;
																	
	spi_config_controls(1 downto 0) <= mem(3)(1 downto 0);

end txtspcfg_arch;
