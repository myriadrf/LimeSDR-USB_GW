-- ----------------------------------------------------------------------------	
-- FILE:	mcfg_components.vhd
-- DESCRIPTION:	This package contains all component declarations.
-- DATE:	Dec 31, 2013
-- AUTHOR(s):	Lime Microsystems
-- REVISION
-- ----------------------------------------------------------------------------	

library	ieee;
use ieee.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Package declaration
-- ----------------------------------------------------------------------------

package mcfg_components is

-- ----------------------------------------------------------------------------


-- ----------------------------------------------------------------------------
component mcfg32w_fsm
	port (		  
		address: in std_logic_vector(9 downto 0);	-- Hardware address
		inst_reg: in std_logic_vector(15 downto 0);	-- Instruction register (read only here)
		sclk: in std_logic;				-- Serial clock
		sen: in std_logic;				-- Serial enable
		reset: in std_logic;				-- Reset
		inst_reg_en: out std_logic;			-- Instruction register enable
		din_reg_en: out std_logic;			-- Data in register enable
		dout_reg_sen: out std_logic;			-- Data out register shift enable
		dout_reg_len: out std_logic;			-- Data out register load enable
		mem_we: out std_logic;				-- Memory write enable
		oe: out std_logic;				-- Output enable
		stateo: out std_logic_vector(5 downto 0)
	);
end component;

-- ----------------------------------------------------------------------------
component mcfg32wm_fsm
	port(
		address: in std_logic_vector(9 downto 0);	-- Hardware address
		mimo_en: in std_logic;
		inst_reg: in std_logic_vector(15 downto 0);	-- Instruction register (read only here)
		sclk: in std_logic;				-- Serial clock
		sen: in std_logic;				-- Serial enable
		reset: in std_logic;				-- Reset
		inst_reg_en: out std_logic;			-- Instruction register enable
		din_reg_en: out std_logic;			-- Data in register enable
		dout_reg_sen: out std_logic;			-- Data out register shift enable
		dout_reg_len: out std_logic;			-- Data out register load enable
		mem_we: out std_logic;				-- Memory write enable
		oe: out std_logic;				-- Output enable
		stateo: out std_logic_vector(5 downto 0)
	);
end component;

-- ----------------------------------------------------------------------------
component mcfg32wmp_fsm
	port(
		address: in std_logic_vector(9 downto 0);	-- Hardware address
		mimo_en: in std_logic;
		inst_reg: in std_logic_vector(15 downto 0);	-- Instruction register (read only here)
		sclk: in std_logic;				-- Serial clock
		sen: in std_logic;				-- Serial enable
		reset: in std_logic;				-- Reset
		inst_reg_en: out std_logic;			-- Instruction register enable
		din_reg_en: out std_logic;			-- Data in register enable
		dout_reg_sen: out std_logic;			-- Data out register shift enable
		dout_reg_len: out std_logic;			-- Data out register load enable
		mem_we: out std_logic;				-- Memory write enable
		oe: out std_logic;				-- Output enable
		stateo: out std_logic_vector(5 downto 0);

		iodir: out std_logic;												-- IO pin direction control
		mode: in std_logic													-- 3 or 4 SPI mode
	);
end component;

-- ----------------------------------------------------------------------------
component mcfg64w_fsm
	port (		  
		address: in std_logic_vector(8 downto 0);	-- Hardware address
		inst_reg: in std_logic_vector(15 downto 0);	-- Instruction register (read only here)
		sclk: in std_logic;				-- Serial clock
		sen: in std_logic;				-- Serial enable
		reset: in std_logic;				-- Reset
		inst_reg_en: out std_logic;			-- Instruction register enable
		din_reg_en: out std_logic;			-- Data in register enable
		dout_reg_sen: out std_logic;			-- Data out register shift enable
		dout_reg_len: out std_logic;			-- Data out register load enable
		mem_we: out std_logic;				-- Memory write enable
		oe: out std_logic;				-- Output enable
		stateo: out std_logic_vector(5 downto 0)
	);
end component;

-- ----------------------------------------------------------------------------
component mcfg64wm_fsm
	port(
		address: in std_logic_vector(8 downto 0);	-- Hardware address
		mimo_en: in std_logic;
		inst_reg: in std_logic_vector(15 downto 0);	-- Instruction register (read only here)
		sclk: in std_logic;				-- Serial clock
		sen: in std_logic;				-- Serial enable
		reset: in std_logic;				-- Reset
		inst_reg_en: out std_logic;			-- Instruction register enable
		din_reg_en: out std_logic;			-- Data in register enable
		dout_reg_sen: out std_logic;			-- Data out register shift enable
		dout_reg_len: out std_logic;			-- Data out register load enable
		mem_we: out std_logic;				-- Memory write enable
		oe: out std_logic;				-- Output enable
		stateo: out std_logic_vector(5 downto 0)
	);
end component;

-- ----------------------------------------------------------------------------
component mcfg128w_fsm
	port(
		address: in std_logic_vector(7 downto 0);	-- Hardware address
		mimo_en: in std_logic;
		inst_reg: in std_logic_vector(15 downto 0);	-- Instruction register (read only here)
		sclk: in std_logic;				-- Serial clock
		sen: in std_logic;				-- Serial enable
		reset: in std_logic;				-- Reset
		inst_reg_en: out std_logic;			-- Instruction register enable
		din_reg_en: out std_logic;			-- Data in register enable
		dout_reg_sen: out std_logic;			-- Data out register shift enable
		dout_reg_len: out std_logic;			-- Data out register load enable
		mem_we: out std_logic;				-- Memory write enable
		oe: out std_logic;				-- Output enable
		stateo: out std_logic_vector(5 downto 0);
		iodir: out std_logic;												-- IO pin direction control
		mode: in std_logic													-- 3 or 4 SPI mode
	);
end component;

-- ----------------------------------------------------------------------------
component mcfg128wm_fsm
	port(
		address: in std_logic_vector(7 downto 0);	-- Hardware address
		mimo_en: in std_logic;
		inst_reg: in std_logic_vector(15 downto 0);	-- Instruction register (read only here)
		sclk: in std_logic;				-- Serial clock
		sen: in std_logic;				-- Serial enable
		reset: in std_logic;				-- Reset
		inst_reg_en: out std_logic;			-- Instruction register enable
		din_reg_en: out std_logic;			-- Data in register enable
		dout_reg_sen: out std_logic;			-- Data out register shift enable
		dout_reg_len: out std_logic;			-- Data out register load enable
		mem_we: out std_logic;				-- Memory write enable
		oe: out std_logic;				-- Output enable
		stateo: out std_logic_vector(5 downto 0);
		iodir: out std_logic;												-- IO pin direction control
		mode: in std_logic													-- 3 or 4 SPI mode
	);
end component;

-- ----------------------------------------------------------------------------
component mcfg
	port (
		-- Address and location of this module
		-- Will be hard wired at the top level
		maddress: in std_logic_vector(9 downto 0);
		mimo_en: in std_logic;	-- MIMO enable, from TOP SPI
	
		-- Serial port IOs
		sdin: in std_logic; 	-- Data in
		sclk: in std_logic; 	-- Data clock
		sen: in std_logic;	-- Enable signal (active low)
		sdout: out std_logic; 	-- Data out
	
		-- Signals coming from the pins or top level serial interface
		hreset: in std_logic; 	-- Hard reset signal, resets everything
		txen: in std_logic;	-- Power down all modules when txen=0
		
		oen: out std_logic;
		
		en		: buffer std_logic;
		NCOF	: buffer std_logic_vector (31 downto 0);
		stateo: out std_logic_vector(5 downto 0);
		gcorri: out std_logic_vector(10 downto 0);
		gcorrq: out std_logic_vector(10 downto 0);
		iqcorr: out std_logic_vector(11 downto 0);
		dccorri: out std_logic_vector(7 downto 0);
		dccorrq: out std_logic_vector(7 downto 0);
    fsinc_polarity: out std_logic;     -- 1: frame start, when 1; 0: frame start, when 0.
    interleave_mode: out std_logic;    -- 0: IQ; 1: QI.
    clk_pol: out std_logic;            -- 0: positive; 1: negative.
		ovr: out std_logic_vector(2 downto 0);	--HBI interpolation ratio 
		gfir1l: out std_logic_vector(2 downto 0);		--Length of GPFIR1
		gfir1n: out std_logic_vector(7 downto 0);		--Clock division ratio of GPFIR1
		gfir2l: out std_logic_vector(2 downto 0);		--Length of GPFIR2
		gfir2n: out std_logic_vector(7 downto 0);		--Clock division ratio of GPFIR2
		gfir3l: out std_logic_vector(2 downto 0);		--Length of GPFIR3
		gfir3n: out std_logic_vector(7 downto 0);		--Clock division ratio of GPFIR3
		TNCOF	: buffer std_logic_vector (31 downto 0);
		insel: out std_logic;
		ph_byp: out std_logic;
		gc_byp: out std_logic;
		gfir1_byp: out std_logic;
		gfir2_byp: out std_logic;
		gfir3_byp: out std_logic;
		dc_byp: out std_logic;
		cmix_byp: out std_logic;
		isinc_byp: out std_logic
	);
end component;

-- ----------------------------------------------------------------------------
component ncocfg
	port (
		-- Address and location of this module
		-- Will be hard wired at the top level
		maddress: in std_logic_vector(8 downto 0);
		mimo_en: in std_logic;	-- MIMO enable, from TOP SPI
		
		-- Clock for shadow register
		clk: in std_logic;
	
		-- Serial port IOs
		sdin: in std_logic; 	-- Data in
		sclk: in std_logic; 	-- Data clock
		sen: in std_logic;	-- Enable signal (active low)
		sdout: out std_logic; 	-- Data out
	
		-- Signals coming from the pins or top level serial interface
		lreset: in std_logic; 	-- Logic reset signal, resets logic cells only
		mreset: in std_logic; 	-- Memory reset signal, resets configuration memory only
		oen: out std_logic;
		
		pho: out std_logic_vector(15 downto 0);
		fcw: out std_logic_vector(31 downto 0);
		
		dthbit: out std_logic_vector(3 downto 0)
	);
end component;

-- ----------------------------------------------------------------------------
component mcfg12c64w16b_fsm
	port(
		address: in std_logic_vector(4 downto 0);	-- Hardware address
		inst_reg: in std_logic_vector(11 downto 0);	-- Instruction register (read only here)
		sclk: in std_logic;				-- Serial clock
		sen: in std_logic;				-- Serial enable
		reset: in std_logic;				-- Reset
		inst_reg_en: out std_logic;			-- Instruction register enable
		din_reg_en: out std_logic;			-- Data in register enable
		dout_reg_sen: out std_logic;			-- Data out register shift enable
		dout_reg_len: out std_logic;			-- Data out register load enable
		mem_we: out std_logic;				-- Memory write enable
		oe: out std_logic;				-- Output enable
		stateo: out std_logic_vector(4 downto 0)
	);
end component;

-- ----------------------------------------------------------------------------
component mcfg12c128w16b_fsm
	port(
		address: in std_logic_vector(3 downto 0);	-- Hardware address
		inst_reg: in std_logic_vector(11 downto 0);	-- Instruction register (read only here)
		sclk: in std_logic;				-- Serial clock
		sen: in std_logic;				-- Serial enable
		reset: in std_logic;				-- Reset
		inst_reg_en: out std_logic;			-- Instruction register enable
		din_reg_en: out std_logic;			-- Data in register enable
		dout_reg_sen: out std_logic;			-- Data out register shift enable
		dout_reg_len: out std_logic;			-- Data out register load enable
		mem_we: out std_logic;				-- Memory write enable
		oe: out std_logic;				-- Output enable
		stateo: out std_logic_vector(4 downto 0)
	);
end component;

-- ----------------------------------------------------------------------------
component topcfg
	port (
		-- Address and location of this module
		-- These signals will be hard wired at the top level
		maddress: in std_logic_vector(3 downto 0);
	
		-- Serial port A IOs
		sdin: in std_logic; 	-- Data in
		sclk: in std_logic; 	-- Data clock
		sen: in std_logic;	-- Enable signal (active low)
		sdout: out std_logic; 	-- Data out
		oen: out std_logic;			-- Enable for data out
		sddir: out std_logic;	-- SDIO  direction control
	
		-- Signals coming from the pins or top level serial interface
		hreset: in std_logic; 	-- Hard reset signal, resets everything
		clk: in std_logic;	-- Master clock (40MHz), drives shadow register
		
		--=== Control lines ===--
		
		-- MIMO channel select
		mimo1en: in std_logic;
		--mimo2en: in std_logic;
		
		-- Soft enables
		--stxen1: in std_logic;
		--stxen2: in std_logic;
		--srxen1: in std_logic;
		--srxen2: in std_logic;
		

		-- AFE control lines
		ISEL_DAC_AFE				: out std_logic_vector(2 downto 0);
		MODE_INTERLEAVE_AFE	: out std_logic;
		MUX_AFE_1						: out std_logic_vector(1 downto 0);
		MUX_AFE_2						: out std_logic_vector(1 downto 0);
		PD_AFE							: out std_logic;
		PD_RX_AFE1					: out std_logic;
		PD_RX_AFE2					: out std_logic;
		PD_TX_AFE1					: out std_logic;
		PD_TX_AFE2					: out std_logic;
		
		-- BIAS control lines
		RESRV_BIAS			: out std_logic_vector(10 downto 0);
		MUX_BIAS_OUT		: out std_logic_vector(1 downto 0);
		RP_CALIB_BIAS		: out std_logic_vector(4 downto 0);
		PD_FRP_BIAS			: out std_logic;
		PD_F_BIAS				: out std_logic;
		PD_PTRP_BIAS		: out std_logic;
		PD_PT_BIAS			: out std_logic;
		PD_BIAS_MASTER	: out std_logic;
		
		-- XBUF control lines
		SLFB_XBUF_RX			: out std_logic;
		SLFB_XBUF_TX			: out std_logic;
		BYP_XBUF_RX				: out std_logic;
		BYP_XBUF_TX				: out std_logic;
		EN_OUT2_XBUF_TX		: out std_logic;
		EN_TBUFIN_XBUF_RX	: out std_logic;
		PD_XBUF_RX				: out std_logic;
		PD_XBUF_TX				: out std_logic;

		-- CLKGEN control lines		
		RESRV_CGN						: out std_logic_vector(3 downto 1);
		
		VCO_CMPHO_CGEN:	in std_logic;
		VCO_CMPLO_CGEN:	in std_logic;
		COARSEPLL_COMPO_CGEN:	in std_logic;
		COARSE_STEPDONE_CGEN:	in std_logic;
		
		REV_CLKDAC_CGEN			: out std_logic;
		REV_CLKADC_CGEN			: out std_logic; 

		CP2_CLKGEN					: out std_logic_vector(3 downto 0);
		CP3_CLKGEN					: out std_logic_vector(3 downto 0);
		CZ_CLKGEN						: out std_logic_vector(3 downto 0);

		ICT_VCO_CGEN				: out std_logic_vector(4 downto 0);
		CSW_VCO_CGEN				: out std_logic_vector(7 downto 0);
		COARSE_START_CGEN		: out std_logic;

		REVPH_PFD_CGEN			: out std_logic;
		IOFFSET_CP_CGEN			: out std_logic_vector(5 downto 0);
		IPULSE_CP_CGEN			: out std_logic_vector(5 downto 0);

		CLKH_OV_CLKL_CLKGN	: out std_logic_vector(1 downto 0);
		DIV_OUTCH_CLKGEN		: out std_logic_vector(7 downto 0);
		TST_CLKGEN					: out std_logic_vector(2 downto 0);

		REV_SDMCLK_CGEN			: out std_logic;
		SEL_SDMCLK_CGEN			: out std_logic;
		SX_DITHER_EN_CGEN		: out std_logic;
		INT_SDM_CGEN				: out std_logic_vector(9 downto 0);
		FRAC_SDM_CGEN				: out std_logic_vector(19 downto 0);

		SPDUP_VCO_CGEN			: out std_logic;
		RESET_N_CGEN				: out std_logic;
		EN_ADCCLKH_CLKGN		: out std_logic;
		EN_COARSE_CKLGEN		: out std_logic;
		EN_INTONLY_SDM_CGEN	: out std_logic;
		EN_SDM_CLK_CGEN			: out std_logic;
		EN_SDM_TSTO_CGEN		: out std_logic;
		PD_CP_CGEN					: out std_logic;
		PD_FDIV_FB_CGEN			: out std_logic;
		PD_FDIV_O_CGEN			: out std_logic;
		PD_SDM_CGEN					: out std_logic;
		PD_VCO_CGEN					: out std_logic;
		PD_VCO_COMP_CGEN		: out std_logic;
		
		-- LDO control lines	
		RDIV_AFE			: out std_logic_vector(7 downto 0);
		RDIV_SPIBUF: out std_logic_vector(7 downto 0);

		RDIV_CPGN			: out std_logic_vector(7 downto 0);
		RDIV_CPSXR   	: out std_logic_vector(7 downto 0);

		RDIV_CPSXT		: out std_logic_vector(7 downto 0);
		RDIV_DIG     	: out std_logic_vector(7 downto 0);

		RDIV_DIGGN		: out std_logic_vector(7 downto 0);
		RDIV_DIGSXR  	: out std_logic_vector(7 downto 0);

		RDIV_DIGSXT		: out std_logic_vector(7 downto 0);
		RDIV_DIVGN  	: out std_logic_vector(7 downto 0);

		RDIV_DIVSXR		: out std_logic_vector(7 downto 0);
		RDIV_DIVSXT 	: out std_logic_vector(7 downto 0);

		RDIV_LNA12		: out std_logic_vector(7 downto 0);
		RDIV_LNA14		: out std_logic_vector(7 downto 0);

		RDIV_MXRFE		: out std_logic_vector(7 downto 0);
		RDIV_RBB  		: out std_logic_vector(7 downto 0);

		RDIV_RXBUF		: out std_logic_vector(7 downto 0);
		RDIV_TBB			: out std_logic_vector(7 downto 0);

		RDIV_TIA12		: out std_logic_vector(7 downto 0);
		RDIV_TIA14		: out std_logic_vector(7 downto 0);

		RDIV_TLOB			: out std_logic_vector(7 downto 0);
		RDIV_TPAD			: out std_logic_vector(7 downto 0);

		RDIV_TXBUF		: out std_logic_vector(7 downto 0);
		RDIV_VCOGN		: out std_logic_vector(7 downto 0);

		RDIV_VCOSXR		: out std_logic_vector(7 downto 0);
		RDIV_VCOSXT		: out std_logic_vector(7 downto 0);

		SPDUP_LDO_AFE						: out std_logic;
		SPDUP_LDO_CPGN					: out std_logic;
		SPDUP_LDO_CPSXR					: out std_logic;
		SPDUP_LDO_CPSXT					: out std_logic;
		SPDUP_LDO_DIG						: out std_logic;
		SPDUP_LDO_DIGGN					: out std_logic;
		SPDUP_LDO_DIGSXR				: out std_logic;
		SPDUP_LDO_DIGSXT				: out std_logic;
		SPDUP_LDO_DIVGN					: out std_logic;

		SPDUP_LDO_DIVSXR				: out std_logic;
		SPDUP_LDO_DIVSXT				: out std_logic;
		SPDUP_LDO_LNA12					: out std_logic;
		SPDUP_LDO_LNA14					: out std_logic;
		SPDUP_LDO_MXRFE					: out std_logic;
		SPDUP_LDO_RBB						: out std_logic;
		SPDUP_LDO_RXBUF					: out std_logic;
		SPDUP_LDO_TBB						: out std_logic;
		SPDUP_LDO_TIA12					: out std_logic;
		SPDUP_LDO_TIA14					: out std_logic;
		SPDUP_LDO_TLOB					: out std_logic;
		SPDUP_LDO_TPAD					: out std_logic;
		SPDUP_LDO_TXBUF					: out std_logic;
		SPDUP_LDO_VCOGN					: out std_logic;
		SPDUP_LDO_VCOSXR				: out std_logic;
		SPDUP_LDO_VCOSXT				: out std_logic;

		BYP_LDO_AFE							: out std_logic;
		BYP_LDO_CPGN						: out std_logic;
		BYP_LDO_CPSXR						: out std_logic;
		BYP_LDO_CPSXT						: out std_logic;
		BYP_LDO_DIG							: out std_logic;
		BYP_LDO_DIGGN						: out std_logic;
		BYP_LDO_DIGSXR					: out std_logic;
		BYP_LDO_DIGSXT					: out std_logic;
		BYP_LDO_DIVGN						: out std_logic;
		BYP_LDO_DIVSXR					: out std_logic;
		BYP_LDO_DIVSXT					: out std_logic;
		BYP_LDO_LNA12						: out std_logic;
		BYP_LDO_LNA14						: out std_logic;
		BYP_LDO_MXRFE						: out std_logic;
		BYP_LDO_RBB							: out std_logic;
		BYP_LDO_RXBUF						: out std_logic;

		BYP_LDO_TBB						: out std_logic;
		BYP_LDO_TIA12         : out std_logic;
		BYP_LDO_TIA14         : out std_logic;
		BYP_LDO_TLOB          : out std_logic;
		BYP_LDO_TPAD          : out std_logic;
		BYP_LDO_TXBUF         : out std_logic;
		BYP_LDO_VCOGN         : out std_logic;
		BYP_LDO_VCOSXR        : out std_logic;
		BYP_LDO_VCOSXT        : out std_logic;
                      
		EN_LOADIMP_LDO_AFE    : out std_logic;
		EN_LOADIMP_LDO_CPGN   : out std_logic;
		EN_LOADIMP_LDO_CPSXR  : out std_logic;

		EN_LOADIMP_LDO_CPSXT	: out std_logic;
		EN_LOADIMP_LDO_DIG    : out std_logic;
		EN_LOADIMP_LDO_DIGGN  : out std_logic;
		EN_LOADIMP_LDO_DIGSXR : out std_logic;
		EN_LOADIMP_LDO_DIGSXT : out std_logic;
		EN_LOADIMP_LDO_DIVGN  : out std_logic;
		EN_LOADIMP_LDO_DIVSXR : out std_logic;
		EN_LOADIMP_LDO_DIVSXT : out std_logic;
		EN_LOADIMP_LDO_LNA12  : out std_logic;
		EN_LOADIMP_LDO_LNA14  : out std_logic;
		EN_LOADIMP_LDO_MXRFE  : out std_logic;
		EN_LOADIMP_LDO_RBB    : out std_logic;
		EN_LOADIMP_LDO_RXBUF  : out std_logic;
		EN_LOADIMP_LDO_TBB    : out std_logic;
		EN_LOADIMP_LDO_TIA12  : out std_logic;
		EN_LOADIMP_LDO_TIA14  : out std_logic;

		EN_LOADIMP_LDO_TLOB			: out std_logic;
		EN_LOADIMP_LDO_TPAD     : out std_logic;
		EN_LOADIMP_LDO_TXBUF    : out std_logic;
		EN_LOADIMP_LDO_VCOGN    : out std_logic;
		EN_LOADIMP_LDO_VCOSXR   : out std_logic;
		EN_LOADIMP_LDO_VCOSXT   : out std_logic;
		EN_LDO_AFE              : out std_logic;
		EN_LDO_CPGN             : out std_logic;
		EN_LDO_CPSXR            : out std_logic;
		EN_LDO_TLOB             : out std_logic;
		EN_LDO_TPAD             : out std_logic;
		EN_LDO_TXBUF            : out std_logic;
		EN_LDO_VCOGN            : out std_logic;
		EN_LDO_VCOSXR           : out std_logic;
		EN_LDO_VCOSXT           : out std_logic;
		EN_LDO_CPSXT            : out std_logic;

		EN_LDO_DIG			: out std_logic;
		EN_LDO_DIGGN    : out std_logic;
		EN_LDO_DIGSXR   : out std_logic;
		EN_LDO_DIGSXT   : out std_logic;
		EN_LDO_DIVGN    : out std_logic;
		EN_LDO_DIVSXR   : out std_logic;
		EN_LDO_DIVSXT   : out std_logic;
		EN_LDO_LNA12    : out std_logic;
		EN_LDO_LNA14    : out std_logic;
		EN_LDO_MXRFE    : out std_logic;
		EN_LDO_RBB      : out std_logic;
		EN_LDO_RXBUF    : out std_logic;
		EN_LDO_TBB      : out std_logic;
		EN_LDO_TIA12    : out std_logic;
		EN_LDO_TIA14    : out std_logic;
		
		BYP_LDO_DIGIp1				:	out std_logic;
		pd_LDO_DIGIp1					:	out std_logic;
		EN_LOADIMP_LDO_DIGIp1	:	out std_logic;
		RDIV_DIGIp1						:	out std_logic_vector(7 downto 0);
		SPDUP_LDO_DIGIp1			:	out std_logic;
		BYP_LDO_DIGIp2				:	out std_logic;
		pd_LDO_DIGIp2					:	out std_logic;
		EN_LOADIMP_LDO_DIGIp2	:	out std_logic;
		RDIV_DIGIp2						:	out std_logic_vector(7 downto 0);
		SPDUP_LDO_DIGIp2			:	out std_logic;
		PD_LDO_SPIBUF :	out std_logic;
		EN_LOADIMP_LDO_SPIBUF :	out std_logic;
		BYP_LDO_SPIBUF  :	out std_logic;
		SPDUP_LDO_SPIBUF  :	out std_logic;
		
		-- BIST
		bsigt		: in std_logic_vector(22 downto 0);	-- SXT BIST signature
		bsigr		: in std_logic_vector(22 downto 0);	-- SXR BIST signature
		bsigc		: in std_logic_vector(22 downto 0);	-- CGEN BIST signature
		bstate	: in std_logic;											-- State of BIST
		bstart	: out std_logic;										-- Sart BIST
		bent		: out std_logic;										-- BIST enable for SXT
		benr		: out std_logic;										-- BIST enable for SXR
		benc		: out std_logic;										-- BIST enable for CGEN

    -- Clock delay buffer related
    cdsn_txatsp   : out std_logic;
    cdsn_txbtsp   : out std_logic;
    cdsn_rxatsp   : out std_logic;
    cdsn_rxbtsp   : out std_logic;
    cdsn_txalml   : out std_logic;
    cdsn_txblml   : out std_logic;
    cdsn_rxalml   : out std_logic;
    cdsn_rxblml   : out std_logic;
    cdsn_mclk2    : out std_logic;
    cdsn_mclk1    : out std_logic;
	 
    cds_txatsp    :	out std_logic_vector(3 downto 0);
    cds_txbtsp    :	out std_logic_vector(3 downto 0);
    cds_rxatsp    :	out std_logic_vector(3 downto 0);
    cds_rxbtsp    :	out std_logic_vector(3 downto 0);
	 
    cds_txalml    :	out std_logic_vector(3 downto 0);
    cds_txblml    :	out std_logic_vector(3 downto 0);
    cds_rxalml    :	out std_logic_vector(3 downto 0);
    cds_rxblml    :	out std_logic_vector(3 downto 0);

    cds_mclk2    :	out std_logic_vector(3 downto 0);
    cds_mclk1    :	out std_logic_vector(3 downto 0);
	
	EN_SDM_TSTO_SXR, EN_SDM_TSTO_SXT:	out std_logic;

		-- SPARE
		spare0: out std_logic_vector(15 downto 0);
		spare1: out std_logic_vector(15 downto 0);
		spare2: out std_logic_vector(15 downto 0);
		spare3: out std_logic_vector(15 downto 0)

	);
end component;

-- ----------------------------------------------------------------------------
component atrxcfg
	port (
		-- Address and location of this module
		-- These signals will be hard wired at the top level
		maddress: in std_logic_vector(3 downto 0);
	
		-- Serial port A IOs
		sdin: in std_logic; 	-- Data in
		sclk: in std_logic; 	-- Data clock
		sen: in std_logic;	-- Enable signal (active low)
		sdout: out std_logic; 	-- Data out
		oen: out std_logic;			-- Enable for data out
	
		-- Signals coming from the pins or top level serial interface
		hreset: in std_logic; 	-- Hard reset signal, resets everything
		clk: in std_logic;	-- Master clock (40MHz), drives shadow register
		
		--=== Control lines ===--
		
		-- MIMO channel select
		--msid: in std_logic;				-- MIMO/SISO identification. From PAD.
		mimo_en: in std_logic; 	-- 
		bnaid: in std_logic; 		-- A/B ID: 1: B, 0: A

		
		-- Soft enables
		stxen: in std_logic;
		srxen: in std_logic;
		
	
		-- TRF control lines
		CDC_I_TRF, CDC_Q_TRF:	out std_logic_vector(3 downto 0);
		--
		LOBIASN_TXM_TRF				: out std_logic_vector(4 downto 0);
		LOBIASP_TXX_TRF				: out std_logic_vector(4 downto 0);
		--
		GCAS_GNDREF_TXPAD_TRF	: out std_logic;
		ICT_LIN_TXPAD_TRF			: out std_logic_vector(4 downto 0);
		ICT_MAIN_TXPAD_TRF		: out std_logic_vector(4 downto 0);
		VGCAS_TXPAD_TRF				: out std_logic_vector(4 downto 0);
		--
		SEL_BAND1_TRF					: out std_logic;
		SEL_BAND2_TRF					: out std_logic;
		F_TXPAD_TRF						: out std_logic_vector(2 downto 0);
		L_LOOPB_TXPAD_TRF			: out std_logic_vector(1 downto 0);
		LOSS_LIN_TXPAD_TRF		: out std_logic_vector(4 downto 0);
		LOSS_MAIN_TXPAD_TRF		: out std_logic_vector(4 downto 0);
		EN_LOOPB_TXPAD_TRF		: out std_logic;
		--
		EN_LOWBWLOMX_TMX_TRF	: out std_logic;
		EN_NEXTTX_TRF					: out std_logic;
		EN_AMPHF_PDET_TRF			: out std_logic_vector(1 downto 0);
		LOADR_PDET_TRF				: out std_logic_vector(1 downto 0);

		PD_PDET_TRF						: out std_logic;
		PD_TLOBUF_TRF					: out std_logic;
		PD_TXPAD_TRF					: out std_logic;


		-- TBB control lines
		RESRV_TBB	: out std_logic_vector(5 downto 0);
		--
		TSTIN_TBB	: out std_logic_vector(1 downto 0);
		BYPLADDER_TBB		: out std_logic;
		CCAL_LPFLAD_TBB	: out std_logic_vector(4 downto 0);
		RCAL_LPFS5_TBB	: out std_logic_vector(7 downto 0);
		--
		RCAL_LPFH_TBB		: out std_logic_vector(7 downto 0);
		RCAL_LPFLAD_TBB	: out std_logic_vector(7 downto 0);
		--
		CG_IAMP_TBB					: out std_logic_vector(5 downto 0);
		ICT_IAMP_FRP_TBB    : out std_logic_vector(4 downto 0);
		ICT_IAMP_GG_FRP_TBB : out std_logic_vector(4 downto 0);
		--
		ICT_LPFH_F_TBB		: out std_logic_vector(4 downto 0);
		ICT_LPFLAD_F_TBB  : out std_logic_vector(4 downto 0);
		ICT_LPFLAD_PT_TBB : out std_logic_vector(4 downto 0);
		--
		ICT_LPFS5_F_TBB		: out std_logic_vector(4 downto 0);
		ICT_LPFS5_PT_TBB	: out std_logic_vector(4 downto 0);
		ICT_LPF_H_PT_TBB	: out std_logic_vector(4 downto 0);
		--
		STATPULSE_TBB		: out std_logic;
		LOOPB_TBB				: out std_logic_vector(2 downto 0);
		PD_LPFH_TBB			: out std_logic;
		PD_LPFIAMP_TBB	: out std_logic;
		PD_LPFLAD_TBB		: out std_logic;
		PD_LPFS5_TBB		: out std_logic;
		PD_TBB					: out std_logic;


		-- RFE control lines
		RCOMP_TIA_RFE	: out std_logic_vector(3 downto 0);
		RFB_TIA_RFE	: out std_logic_vector(4 downto 0);
		--
		G_LNA_RFE			: out std_logic_vector(3 downto 0);
		G_RXLOOPB_RFE	: out std_logic_vector(3 downto 0);
		G_TIA_RFE			: out std_logic_vector(1 downto 0);
		--
		CAP_RXMXO_RFE	: out std_logic_vector(4 downto 0);
		CCOMP_TIA_RFE	: out std_logic_vector(3 downto 0);
		CFB_TIA_RFE		: out std_logic_vector(11 downto 0);
		CGSIN_LNA_RFE	: out std_logic_vector(4 downto 0);
		--
		ICT_LNACMO_RFE	: out std_logic_vector(4 downto 0);
		ICT_LNA_RFE     : out std_logic_vector(4 downto 0);
		ICT_LODC_RFE    : out std_logic_vector(4 downto 0);
		--
		ICT_LOOPB_RFE		: out std_logic_vector(4 downto 0);
		ICT_TIAMAIN_RFE	: out std_logic_vector(4 downto 0);
		ICT_TIAOUT_RFE	: out std_logic_vector(4 downto 0);
		--
		DCOFFI_RFE	: out std_logic_vector(6 downto 0);
		DCOFFQ_RFE	: out std_logic_vector(6 downto 0);
		--
		SEL_PATH_RFE	: out std_logic_vector(1 downto 0);
		EN_DCOFF_RXFE_RFE	: out std_logic;
		EN_INSHSW_H_RFE		: out std_logic;
		EN_INSHSW_LB1_RFE	: out std_logic;
		EN_INSHSW_LB2_RFE	: out std_logic;
		EN_INSHSW_L_RFE		: out std_logic;
		EN_INSHSW_W_RFE		: out std_logic;
		EN_NEXTRX_RFE			: out std_logic;
		--
		CDC_I_RFE:	out std_logic_vector(3 downto 0);
		CDC_Q_RFE:	out std_logic_vector(3 downto 0);
		
		PD_LNA_RFE: 	out std_logic;
		PD_RLOOPB_1_RFE		: out std_logic;
		PD_RLOOPB_2_RFE		: out std_logic;
		PD_MXLOBUF_RFE		: out std_logic;
		PD_QGEN_RFE				: out std_logic;
		PD_RSSI_RFE				: out std_logic;
		PD_TIA_RFE				: out std_logic;

		-- RBB control lines 
		RESRV_RBB	: out std_logic_vector(6 downto 0);
		--
		INPUT_CTL_PGA_RBB	: out std_logic_vector(2 downto 0);
		RCC_CTL_PGA_RBB		: out std_logic_vector(4 downto 0);
		C_CTL_PGA_RBB			: out std_logic_vector(7 downto 0);
		--
		OSW_PGA_RBB			: out std_logic;
		ICT_PGA_OUT_RBB	: out std_logic_vector(4 downto 0);
		ICT_PGA_IN_RBB	: out std_logic_vector(4 downto 0);
		G_PGA_RBB				: out std_logic_vector(4 downto 0);
		--
		ICT_LPF_IN_RBB		: out std_logic_vector(4 downto 0);
		ICT_LPF_OUT_RBB		: out std_logic_vector(4 downto 0);
		--
		RCC_CTL_LPFL_RBB	: out std_logic_vector(2 downto 0);
		C_CTL_LPFL_RBB		: out std_logic_vector(10 downto 0);
		--
		R_CTL_LPF_RBB		: out std_logic_vector(4 downto 0);
		RCC_CTL_LPFH_RBB: out std_logic_vector(2 downto 0);
		C_CTL_LPFH_RBB	: out std_logic_vector(7 downto 0);
		--
		EN_LB_LPFH_RBB	: out std_logic;
		EN_LB_LPFL_RBB	: out std_logic;
		PD_LPFH_RBB			: out std_logic;
		PD_LPFL_RBB			: out std_logic;
		PD_PGA_RBB			: out std_logic;
		
		-- SX control lines 
		RESRV_SX	: out std_logic_vector(4 downto 0);
		
		VCO_CMPHO_SX:	in std_logic;
		VCO_CMPLO_SX:	in std_logic;
		COARSEPLL_COMPO_SX:	in std_logic;
		COARSE_STEPDONE_SX:	in std_logic;
		
		--
		CP2_PLL_SX	: out std_logic_vector(3 downto 0);
		CP3_PLL_SX	: out std_logic_vector(3 downto 0);
		CZ_SX				: out std_logic_vector(3 downto 0);
		--
		REVPH_PFD_SX		: out std_logic;
		IOFFSET_CP_SX		: out std_logic_vector(5 downto 0);
		IPULSE_CP_SX		: out std_logic_vector(5 downto 0);
		--
		RSEL_LDO_VCO_SX		: out std_logic_vector(4 downto 0);
		CSW_VCO_SX				: out std_logic_vector(7 downto 0);
		SEL_VCO_SX				: out std_logic_vector(1 downto 0);
		COARSE_START_SX		: out std_logic;
		--
		VDIV_VCO_SX	: out std_logic_vector(7 downto 0);
		ICT_VCO_SX	: out std_logic_vector(7 downto 0);
		--
		PW_DIV2_LOCH_SX		: out std_logic_vector(2 downto 0);
		PW_DIV4_LOCH_SX		: out std_logic_vector(2 downto 0);
		DIV_LOCH_SX				: out std_logic_vector(2 downto 0);
		TST_SX_SX					: out std_logic_vector(2 downto 0);
		SEL_SDMCLK_SX			: out std_logic;
		SX_DITHER_EN_SX		: out std_logic;
		REV_SDMCLK_SX			: out std_logic;
		--
		INT_SDM_SX	: out std_logic_vector(9 downto 0);
		FRAC_SDM_SX	: out std_logic_vector(19 downto 0);
		--
		RESET_N_SX					: out std_logic;
		SPDUP_VCO_SX				: out std_logic;
		BYPLDO_VCO_SX				: out std_logic;
		EN_COARSEPLL_SX			: out std_logic;
		CURLIM_VCO_SX				: out std_logic;
		EN_DIV2_DIVPROG_SX	: out std_logic;
		EN_INTONLY_SDM_SX		: out std_logic;
		EN_SDM_CLK_SX				: out std_logic;
		PD_FBDIV_SX				: out std_logic;
		PD_LOCH_T2RBUF			: out std_logic;
		PD_CP_SX						: out std_logic;
		PD_FDIV_SX					: out std_logic;
		PD_SDM_SX						: out std_logic;
		PD_VCO_COMP_SX			: out std_logic;
		PD_VCO_SX						: out std_logic		

	);
end component;

-- ----------------------------------------------------------------------------
component lmlcfg
	port (
		-- Address and location of this module
		-- Will be hard wired at the top level
		maddress: in std_logic_vector(9 downto 0);
		mimo_en: in std_logic;	-- MIMO enable, from TOP SPI
	
		-- Serial port IOs
		sdin: in std_logic; 	-- Data in
		sclk: in std_logic; 	-- Data clock
		sen: in std_logic;	-- Enable signal (active low)
		sdout: out std_logic; 	-- Data out
		oen: out std_logic;
		sdio_InO: out std_logic;	-- SDIO direction control
		smdin: in std_logic_vector (9 downto 0);	--Inputs from other SPI modules

	
		-- Signals coming from the pins or top level serial interface
		hreset: in std_logic; 	-- Logic reset signal, resets logic cells only
		txen: in std_logic;	-- Power down all TX modules when txen=0
		rxen: in std_logic;	-- Power down all RX modules when rxen=0

		-- Version, Revision and Mask. Hardwired in layout
		ver: in std_logic_vector(4 downto 0);
		rev: in std_logic_vector(4 downto 0);
		mask: in std_logic_vector(5 downto 0);
		
		-- Clock Multiplexers
		rxwrclk_sel: out std_logic_vector(1 downto 0);
		rxrdclk_sel: out std_logic_vector(1 downto 0);
		txwrclk_sel: out std_logic_vector(1 downto 0);
		txrdclk_sel: out std_logic_vector(1 downto 0);
		txmux_sel: out std_logic_vector(1 downto 0);
		rxmux_sel: out std_logic_vector(1 downto 0);
		
		-- LML Module Enable
		mod_en: out std_logic;

		
		-- LimeLight Control lines
		-- Port1		
		lml1_aip: out std_logic_vector(1 downto 0); -- AI sample position, for RX part
		lml1_aqp: out std_logic_vector(1 downto 0); -- AQ sample position, for RX part
		lml1_bip: out std_logic_vector(1 downto 0); -- BI sample position, for RX part
		lml1_bqp: out std_logic_vector(1 downto 0); -- BQ sample position, for RX part

		lml1_s0s: out std_logic_vector(1 downto 0); -- Sample #0 source (00:ai, 01:aq, 10:bi, 11:bq), for TX part
		lml1_s1s: out std_logic_vector(1 downto 0); -- Sample #1 source (00:ai, 01:aq, 10:bi, 11:bq), for TX part
		lml1_s2s: out std_logic_vector(1 downto 0); -- Sample #2 source (00:ai, 01:aq, 10:bi, 11:bq), for TX part
		lml1_s3s: out std_logic_vector(1 downto 0); -- Sample #3 source (00:ai, 01:aq, 10:bi, 11:bq), for TX part
		
		lml1_tx_pre: out std_logic_vector(7 downto 0);  -- Wait for clock # before BB2RF burst
		lml1_tx_pst: out std_logic_vector(7 downto 0);  -- Wait for clock # after BB2RF burst
		lml1_rx_pre: out std_logic_vector(7 downto 0);  -- Wait for clock # before RF2BB burst
		lml1_rx_pst: out std_logic_vector(7 downto 0);  -- Wait for clock # after RF2BB burst

    lml1_mode: out std_logic; -- JESD207: 1; TRXIQ: 0
		lml1_txnrxiq: out std_logic;		-- TXIQ/RXIQ mode selection, when mode = '0': '1' - TXIQ, '0' - RXIQ
    lml1_fidm: out std_logic; -- WHEN mode = 0 (TRXIQ): External Frame ID mode. 

		-- Port2
		lml2_aip: out std_logic_vector(1 downto 0); -- AI sample position, for RX part
		lml2_aqp: out std_logic_vector(1 downto 0); -- AQ sample position, for RX part
		lml2_bip: out std_logic_vector(1 downto 0); -- BI sample position, for RX part
		lml2_bqp: out std_logic_vector(1 downto 0); -- BQ sample position, for RX part

		lml2_s0s: out std_logic_vector(1 downto 0); -- Sample #0 source (00:ai, 01:aq, 10:bi, 11:bq), for TX part
		lml2_s1s: out std_logic_vector(1 downto 0); -- Sample #1 source (00:ai, 01:aq, 10:bi, 11:bq), for TX part
		lml2_s2s: out std_logic_vector(1 downto 0); -- Sample #2 source (00:ai, 01:aq, 10:bi, 11:bq), for TX part
		lml2_s3s: out std_logic_vector(1 downto 0); -- Sample #3 source (00:ai, 01:aq, 10:bi, 11:bq), for TX part

		lml2_tx_pre: out std_logic_vector(7 downto 0);  -- Wait for clock # before BB2RF burst
		lml2_tx_pst: out std_logic_vector(7 downto 0);  -- Wait for clock # after BB2RF burst
		lml2_rx_pre: out std_logic_vector(7 downto 0);  -- Wait for clock # before RF2BB burst
		lml2_rx_pst: out std_logic_vector(7 downto 0);  -- Wait for clock # after RF2BB burst

    lml2_mode: out std_logic; -- JESD207: 1; TRXIQ: 0
		lml2_txnrxiq: out std_logic;		-- TXIQ/RXIQ mode selection, when mode = '0': '1' - TXIQ, '0' - RXIQ
    lml2_fidm: out std_logic; -- WHEN mode = 0 (TRXIQ): External Frame ID mode. 
		
		-- Direction control of ports
		enabledirctr1	: out std_logic;
		enabledir1		: out std_logic;
		enabledirctr2	: out std_logic;
		enabledir2		: out std_logic;
		diqdirctr1		: out std_logic;
		diqdir1				: out std_logic;
		diqdirctr2		: out std_logic;
		diqdir2				: out std_logic;
		
		-- Dividers for MCLK signals, internal signals
		fclk1inv: out std_logic;
		fclk2inv: out std_logic;
		mclk1dly: out std_logic_vector(1 downto 0);
		mclk2dly: out std_logic_vector(1 downto 0);
		rxdiven: out std_logic;
		txdiven: out std_logic;
		mclk1src: out std_logic_vector(1 downto 0);
		mclk2src: out std_logic_vector(1 downto 0);
		rxclkdivider: out std_logic_vector(7 downto 0);  -- 
		txclkdivider: out std_logic_vector(7 downto 0);  -- 
		
		-- Control lines for pads 
		sen_pe 	: out std_logic;
		sclk_pe : out std_logic;
		sdo_pe 	: out std_logic;
		sdio_pe : out std_logic;
		sdio_ds : out std_logic;
		scl_ds	: out std_logic;
		scl_pe	: out std_logic;
		sda_ds	: out std_logic;
		sda_pe	: out std_logic;
		rxclk_pe: out std_logic;
		txclk_pe: out std_logic;
	
		mclk1_pe				: out std_logic;
		fclk1_pe				: out std_logic;
		txnrx1_pe				: out std_logic;
		iq_sel_en_1_pe	: out std_logic;
		diq1_pe				: out std_logic;
		diq1_ds				: out std_logic;
		mclk2_pe				: out std_logic;
		fclk2_pe				: out std_logic;
		txnrx2_pe				: out std_logic;
		iq_sel_en_2_pe	: out std_logic;
		diq2_pe				: out std_logic;
		diq2_ds				: out std_logic;
		
		mimo_en_A		: out std_logic;
		mimo_en_B		: out std_logic;
		txen_A			: out std_logic;
		txen_B			: out std_logic;
		rxen_A			: out std_logic;
		rxen_B			: out std_logic;
		srst_txfifo	: out std_logic;
		srst_rxfifo	: out std_logic;
		mrst_rx_A		: out std_logic;
		lrst_rx_A		: out std_logic;
		mrst_rx_B		: out std_logic;
		lrst_rx_B		: out std_logic;
		mrst_tx_A		: out std_logic;
		lrst_tx_A		: out std_logic;
		mrst_tx_B		: out std_logic;
		lrst_tx_B		: out std_logic;
		
		mimo_nen		: in std_logic	-- From PAD. 0: MIMO; 1: SISO.

	);
end component;

-- ----------------------------------------------------------------------------
component achipcfg
	port (
		-- Address and location of this module
		-- These signals will be hard wired at the top level
		maddress_top:	in std_logic_vector(3 downto 0);
		maddress_atrx:	in std_logic_vector(3 downto 0);
	
		-- Serial port A IOs
		sdin:	in std_logic; 	-- Data in
		sclk:	in std_logic; 	-- Data clock
		sen:	in std_logic;	-- Enable signal (active low)
		sdout:	out std_logic; 	-- Data out
		--oen:	out std_logic;			-- Enable for data out
		--spim_sdout:	in std_logic_vector (13 downto 0);	--Inputs from other SPI modules connected
		--sddir:	out std_logic;	-- SDIO direction control
	
		-- Signals coming from the pins or top level serial interface
		hreset:	in std_logic; 	-- Hard reset signal, resets everything
		clk:	in std_logic;	-- Master clock (40MHz), drives shadow register
		bclk:	in std_logic;	-- BIST clock
		
		--=== Control lines ===--
		
		-- MIMO channel select
		mimo1en:	in std_logic;
		mimo2en:	in std_logic;
		
		-- Soft enables
		stxen1:	in std_logic;
		stxen2:	in std_logic;
		srxen1:	in std_logic;
		srxen2:	in std_logic;
		
		--============================= FROM TOP CONFIGURATION =============================--
		-- AFE control lines
		ISEL_DAC_AFE:	out std_logic_vector(2 downto 0);
		MODE_INTERLEAVE_AFE:	out std_logic;
		MUX_AFE_1:		out std_logic_vector(1 downto 0);
		MUX_AFE_2:		out std_logic_vector(1 downto 0);
		PD_AFE:			out std_logic;
		PD_RX_AFE1:		out std_logic;
		PD_RX_AFE2:		out std_logic;
		PD_TX_AFE1:		out std_logic;
		PD_TX_AFE2:		out std_logic;
		
		-- BIAS control lines
		RESRV_BIAS:	out std_logic_vector(10 downto 0);
		MUX_BIAS_OUT:	out std_logic_vector(1 downto 0);
		RP_CALIB_BIAS:	out std_logic_vector(4 downto 0);
		PD_FRP_BIAS:	out std_logic;
		PD_F_BIAS:	out std_logic;
		PD_PTRP_BIAS:	out std_logic;
		PD_PT_BIAS:	out std_logic;
		PD_BIAS_MASTER:	out std_logic;
		
		-- XBUF control lines
		SLFB_XBUF_RX:	out std_logic;
		SLFB_XBUF_TX:	out std_logic;
		BYP_XBUF_RX:	out std_logic;
		BYP_XBUF_TX:	out std_logic;
		EN_OUT2_XBUF_TX:	out std_logic;
		EN_TBUFIN_XBUF_RX:	out std_logic;
		PD_XBUF_RX:		out std_logic;
		PD_XBUF_TX:		out std_logic;

		-- CLKGEN control lines	
		SDM_TSTO_CGEN:		in std_logic_vector(13 downto 0);		
		RESRV_CGN:			out std_logic_vector(3 downto 1);
		
		VCO_CMPHO_CGEN:		in std_logic;
		VCO_CMPLO_CGEN:		in std_logic;
		COARSEPLL_COMPO_CGEN:	in std_logic;
		COARSE_STEPDONE_CGEN:	in std_logic;
		
		REV_CLKDAC_CGEN:	out std_logic;
		REV_CLKADC_CGEN:	out std_logic;

		CP2_CLKGEN:		out std_logic_vector(3 downto 0);
		CP3_CLKGEN:		out std_logic_vector(3 downto 0);
		CZ_CLKGEN:		out std_logic_vector(3 downto 0);

		ICT_VCO_CGEN:	out std_logic_vector(4 downto 0);
		CSW_VCO_CGEN:	out std_logic_vector(7 downto 0);
		COARSE_START_CGEN:	out std_logic;

		REVPH_PFD_CGEN:	out std_logic;
		IOFFSET_CP_CGEN:	out std_logic_vector(5 downto 0);
		IPULSE_CP_CGEN:	out std_logic_vector(5 downto 0);

		CLKH_OV_CLKL_CLKGN:	out std_logic_vector(1 downto 0);
		DIV_OUTCH_CLKGEN:	out std_logic_vector(7 downto 0);
		TST_CLKGEN:		out std_logic_vector(2 downto 0);

		REV_SDMCLK_CGEN:	out std_logic;
		SEL_SDMCLK_CGEN:	out std_logic;
		SX_DITHER_EN_CGEN:	out std_logic;
		INT_SDM_CGEN:	out std_logic_vector(9 downto 0);
		FRAC_SDM_CGEN:	out std_logic_vector(19 downto 0);

		SPDUP_VCO_CGEN:	out std_logic;
		RESET_N_CGEN:	out std_logic;
		EN_ADCCLKH_CLKGN:	out std_logic;
		EN_COARSE_CKLGEN:	out std_logic;
		EN_INTONLY_SDM_CGEN:	out std_logic;
		EN_SDM_CLK_CGEN:	out std_logic;
		EN_SDM_TSTO_CGEN:	out std_logic;
		PD_CP_CGEN:		out std_logic;
		PD_FDIV_FB_CGEN:	out std_logic;
		PD_FDIV_O_CGEN:	out std_logic;
		PD_SDM_CGEN:	out std_logic;
		PD_VCO_CGEN:	out std_logic;
		PD_VCO_COMP_CGEN:	out std_logic;
		
		-- LDO control lines	
		RDIV_AFE:		out std_logic_vector(7 downto 0);
		RDIV_SPIBUF:	out std_logic_vector(7 downto 0);

		RDIV_CPGN:	out std_logic_vector(7 downto 0);
		RDIV_CPSXR:	out std_logic_vector(7 downto 0);

		RDIV_CPSXT:	out std_logic_vector(7 downto 0);
		RDIV_DIG:	out std_logic_vector(7 downto 0);

		RDIV_DIGGN:	out std_logic_vector(7 downto 0);
		RDIV_DIGSXR:	out std_logic_vector(7 downto 0);

		RDIV_DIGSXT:	out std_logic_vector(7 downto 0);
		RDIV_DIVGN:	out std_logic_vector(7 downto 0);

		RDIV_DIVSXR:	out std_logic_vector(7 downto 0);
		RDIV_DIVSXT:	out std_logic_vector(7 downto 0);

		RDIV_LNA12:	out std_logic_vector(7 downto 0);
		RDIV_LNA14:	out std_logic_vector(7 downto 0);

		RDIV_MXRFE:	out std_logic_vector(7 downto 0);
		RDIV_RBB :	out std_logic_vector(7 downto 0);

		RDIV_RXBUF:	out std_logic_vector(7 downto 0);
		RDIV_TBB:	out std_logic_vector(7 downto 0);

		RDIV_TIA12:	out std_logic_vector(7 downto 0);
		RDIV_TIA14:	out std_logic_vector(7 downto 0);

		RDIV_TLOB:	out std_logic_vector(7 downto 0);
		RDIV_TPAD:	out std_logic_vector(7 downto 0);

		RDIV_TXBUF:	out std_logic_vector(7 downto 0);
		RDIV_VCOGN:	out std_logic_vector(7 downto 0);

		RDIV_VCOSXR:	out std_logic_vector(7 downto 0);
		RDIV_VCOSXT:	out std_logic_vector(7 downto 0);

		SPDUP_LDO_AFE:	out std_logic;
		SPDUP_LDO_CPGN:	out std_logic;
		SPDUP_LDO_CPSXR:	out std_logic;
		SPDUP_LDO_CPSXT:	out std_logic;
		SPDUP_LDO_DIG:	out std_logic;
		SPDUP_LDO_DIGGN:	out std_logic;
		SPDUP_LDO_DIGSXR:	out std_logic;
		SPDUP_LDO_DIGSXT:	out std_logic;
		SPDUP_LDO_DIVGN:	out std_logic;

		SPDUP_LDO_DIVSXR:	out std_logic;
		SPDUP_LDO_DIVSXT:	out std_logic;
		SPDUP_LDO_LNA12:	out std_logic;
		SPDUP_LDO_LNA14:	out std_logic;
		SPDUP_LDO_MXRFE:	out std_logic;
		SPDUP_LDO_RBB:	out std_logic;
		SPDUP_LDO_RXBUF:	out std_logic;
		SPDUP_LDO_TBB:	out std_logic;
		SPDUP_LDO_TIA12:	out std_logic;
		SPDUP_LDO_TIA14:	out std_logic;
		SPDUP_LDO_TLOB:	out std_logic;
		SPDUP_LDO_TPAD:	out std_logic;
		SPDUP_LDO_TXBUF:	out std_logic;
		SPDUP_LDO_VCOGN:	out std_logic;
		SPDUP_LDO_VCOSXR:	out std_logic;
		SPDUP_LDO_VCOSXT:	out std_logic;

		BYP_LDO_AFE:	out std_logic;
		BYP_LDO_CPGN:	out std_logic;
		BYP_LDO_CPSXR:	out std_logic;
		BYP_LDO_CPSXT:	out std_logic;
		BYP_LDO_DIG:	out std_logic;
		BYP_LDO_DIGGN:	out std_logic;
		BYP_LDO_DIGSXR:	out std_logic;
		BYP_LDO_DIGSXT:	out std_logic;
		BYP_LDO_DIVGN:	out std_logic;
		BYP_LDO_DIVSXR:	out std_logic;
		BYP_LDO_DIVSXT:	out std_logic;
		BYP_LDO_LNA12:	out std_logic;
		BYP_LDO_LNA14:	out std_logic;
		BYP_LDO_MXRFE:	out std_logic;
		BYP_LDO_RBB:	out std_logic;
		BYP_LDO_RXBUF:	out std_logic;

		BYP_LDO_TBB:	out std_logic;
		BYP_LDO_TIA12:	out std_logic;
		BYP_LDO_TIA14:	out std_logic;
		BYP_LDO_TLOB:	out std_logic;
		BYP_LDO_TPAD:	out std_logic;
		BYP_LDO_TXBUF:	out std_logic;
		BYP_LDO_VCOGN:	out std_logic;
		BYP_LDO_VCOSXR:	out std_logic;
		BYP_LDO_VCOSXT:	out std_logic;
 
		EN_LOADIMP_LDO_AFE:	out std_logic;
		EN_LOADIMP_LDO_CPGN:	out std_logic;
		EN_LOADIMP_LDO_CPSXR:	out std_logic;

		EN_LOADIMP_LDO_CPSXT:	out std_logic;
		EN_LOADIMP_LDO_DIG:	out std_logic;
		EN_LOADIMP_LDO_DIGGN:	out std_logic;
		EN_LOADIMP_LDO_DIGSXR:	out std_logic;
		EN_LOADIMP_LDO_DIGSXT:	out std_logic;
		EN_LOADIMP_LDO_DIVGN:	out std_logic;
		EN_LOADIMP_LDO_DIVSXR:	out std_logic;
		EN_LOADIMP_LDO_DIVSXT:	out std_logic;
		EN_LOADIMP_LDO_LNA12:	out std_logic;
		EN_LOADIMP_LDO_LNA14:	out std_logic;
		EN_LOADIMP_LDO_MXRFE:	out std_logic;
		EN_LOADIMP_LDO_RBB:	out std_logic;
		EN_LOADIMP_LDO_RXBUF:	out std_logic;
		EN_LOADIMP_LDO_TBB:	out std_logic;
		EN_LOADIMP_LDO_TIA12:	out std_logic;
		EN_LOADIMP_LDO_TIA14:	out std_logic;

		EN_LOADIMP_LDO_TLOB:	out std_logic;
		EN_LOADIMP_LDO_TPAD:	out std_logic;
		EN_LOADIMP_LDO_TXBUF:	out std_logic;
		EN_LOADIMP_LDO_VCOGN:	out std_logic;
		EN_LOADIMP_LDO_VCOSXR:	out std_logic;
		EN_LOADIMP_LDO_VCOSXT:	out std_logic;
		EN_LDO_AFE:	out std_logic;
		EN_LDO_CPGN:	out std_logic;
		EN_LDO_CPSXR:	out std_logic;
		EN_LDO_TLOB:	out std_logic;
		EN_LDO_TPAD:	out std_logic;
		EN_LDO_TXBUF:	out std_logic;
		EN_LDO_VCOGN:	out std_logic;
		EN_LDO_VCOSXR:	out std_logic;
		EN_LDO_VCOSXT:	out std_logic;
		EN_LDO_CPSXT:	out std_logic;

		EN_LDO_DIG:	out std_logic;
		EN_LDO_DIGGN:	out std_logic;
		EN_LDO_DIGSXR:	out std_logic;
		EN_LDO_DIGSXT:	out std_logic;
		EN_LDO_DIVGN:	out std_logic;
		EN_LDO_DIVSXR:	out std_logic;
		EN_LDO_DIVSXT:	out std_logic;
		EN_LDO_LNA12:	out std_logic;
		EN_LDO_LNA14:	out std_logic;
		EN_LDO_MXRFE:	out std_logic;
		EN_LDO_RBB:	out std_logic;
		EN_LDO_RXBUF:	out std_logic;
		EN_LDO_TBB:	out std_logic;
		EN_LDO_TIA12:	out std_logic;
		EN_LDO_TIA14:	out std_logic;
		
		BYP_LDO_DIGIp1:	out std_logic;
		pd_LDO_DIGIp1:	out std_logic;
		EN_LOADIMP_LDO_DIGIp1:	out std_logic;
		RDIV_DIGIp1:	out std_logic_vector(7 downto 0);
		SPDUP_LDO_DIGIp1:	out std_logic;
		BYP_LDO_DIGIp2:	out std_logic;
		pd_LDO_DIGIp2:	out std_logic;
		EN_LOADIMP_LDO_DIGIp2:	out std_logic;
		RDIV_DIGIp2:	out std_logic_vector(7 downto 0);
		SPDUP_LDO_DIGIp2:	out std_logic;
		PD_LDO_SPIBUF:	out std_logic;
		EN_LOADIMP_LDO_SPIBUF :	out std_logic;
		BYP_LDO_SPIBUF:	out std_logic;
		SPDUP_LDO_SPIBUF:	out std_logic;
		
		-- Clock delay buffer related
		cdsn_txatsp:	out std_logic;
		cdsn_txbtsp:	out std_logic;
		cdsn_rxatsp:	out std_logic;
		cdsn_rxbtsp:	out std_logic;
		cdsn_txalml:	out std_logic;
		cdsn_txblml:	out std_logic;
		cdsn_rxalml:	out std_logic;
		cdsn_rxblml:	out std_logic;
		cdsn_mclk2:	out std_logic;
		cdsn_mclk1:	out std_logic;
		 
		cds_txatsp:	out std_logic_vector(3 downto 0);
		cds_txbtsp:	out std_logic_vector(3 downto 0);
		cds_rxatsp:	out std_logic_vector(3 downto 0);
		cds_rxbtsp:	out std_logic_vector(3 downto 0);
		 
		cds_txalml:	out std_logic_vector(3 downto 0);
		cds_txblml:	out std_logic_vector(3 downto 0);
		cds_rxalml:	out std_logic_vector(3 downto 0);
		cds_rxblml:	out std_logic_vector(3 downto 0);

		cds_mclk2:	out std_logic_vector(3 downto 0);
		cds_mclk1:	out std_logic_vector(3 downto 0);

		-- SPARE
		spare0:	out std_logic_vector(15 downto 0);
		spare1:	out std_logic_vector(15 downto 0);
		spare2:	out std_logic_vector(15 downto 0);
		spare3:	out std_logic_vector(15 downto 0);
		
		--============================= FROM ATRX CONFIGURATION, CNANNEL 1 =============================--
		-- TRF control lines
		CDC_I_TRF_1:		out std_logic_vector(3 downto 0);
		CDC_Q_TRF_1:		out std_logic_vector(3 downto 0);
		--
		LOBIASN_TXM_TRF_1:	out std_logic_vector(4 downto 0);
		LOBIASP_TXX_TRF_1:	out std_logic_vector(4 downto 0);
		--
		GCAS_GNDREF_TXPAD_TRF_1:	out std_logic;
		ICT_LIN_TXPAD_TRF_1:	out std_logic_vector(4 downto 0);
		ICT_MAIN_TXPAD_TRF_1:	out std_logic_vector(4 downto 0);
		VGCAS_TXPAD_TRF_1:	out std_logic_vector(4 downto 0);
		--
		SEL_BAND1_TRF_1:	out std_logic;
		SEL_BAND2_TRF_1:	out std_logic;
		F_TXPAD_TRF_1:		out std_logic_vector(2 downto 0);
		L_LOOPB_TXPAD_TRF_1:	out std_logic_vector(1 downto 0);
		LOSS_LIN_TXPAD_TRF_1:	out std_logic_vector(4 downto 0);
		LOSS_MAIN_TXPAD_TRF_1:	out std_logic_vector(4 downto 0);
		EN_LOOPB_TXPAD_TRF_1:	out std_logic;
		--
		EN_LOWBWLOMX_TMX_TRF_1:	out std_logic;
		EN_NEXTTX_TRF_1:	out std_logic;
		EN_AMPHF_PDET_TRF_1:	out std_logic_vector(1 downto 0);
		LOADR_PDET_TRF_1:	out std_logic_vector(1 downto 0);

		PD_PDET_TRF_1:		out std_logic;
		PD_TLOBUF_TRF_1:	out std_logic;
		PD_TXPAD_TRF_1:		out std_logic;

		-- TBB control lines
		RESRV_TBB_1:		out std_logic_vector(5 downto 0);
		--
		TSTIN_TBB_1:		out std_logic_vector(1 downto 0);
		BYPLADDER_TBB_1:	out std_logic;
		CCAL_LPFLAD_TBB_1:	out std_logic_vector(4 downto 0);
		RCAL_LPFS5_TBB_1:	out std_logic_vector(7 downto 0);
		--
		RCAL_LPFH_TBB_1:	out std_logic_vector(7 downto 0);
		RCAL_LPFLAD_TBB_1:	out std_logic_vector(7 downto 0);
		--
		CG_IAMP_TBB_1:		out std_logic_vector(5 downto 0);
		ICT_IAMP_FRP_TBB_1:	out std_logic_vector(4 downto 0);
		ICT_IAMP_GG_FRP_TBB_1:	out std_logic_vector(4 downto 0);
		--
		ICT_LPFH_F_TBB_1:	out std_logic_vector(4 downto 0);
		ICT_LPFLAD_F_TBB_1:	out std_logic_vector(4 downto 0);
		ICT_LPFLAD_PT_TBB_1:	out std_logic_vector(4 downto 0);
		--
		ICT_LPFS5_F_TBB_1:	out std_logic_vector(4 downto 0);
		ICT_LPFS5_PT_TBB_1:	out std_logic_vector(4 downto 0);
		ICT_LPF_H_PT_TBB_1:	out std_logic_vector(4 downto 0);
		--
		STATPULSE_TBB_1:	out std_logic;
		LOOPB_TBB_1:		out std_logic_vector(2 downto 0);
		PD_LPFH_TBB_1:		out std_logic;
		PD_LPFIAMP_TBB_1:	out std_logic;
		PD_LPFLAD_TBB_1:	out std_logic;
		PD_LPFS5_TBB_1:		out std_logic;
		PD_TBB_1:			out std_logic;

		-- RFE control lines
		
		PD_LNA_RFE_1:		out std_logic;
		SEL_PATH_RFE_1:		out std_logic_vector(1 downto 0);
		
		--
		RCOMP_TIA_RFE_1:	out std_logic_vector(3 downto 0);
		RFB_TIA_RFE_1:	out std_logic_vector(4 downto 0);
		--
		G_LNA_RFE_1:	out std_logic_vector(3 downto 0);
		G_RXLOOPB_RFE_1:	out std_logic_vector(3 downto 0);
		G_TIA_RFE_1:	out std_logic_vector(1 downto 0);
		--
		CAP_RXMXO_RFE_1:	out std_logic_vector(4 downto 0);
		CCOMP_TIA_RFE_1:	out std_logic_vector(3 downto 0);
		CFB_TIA_RFE_1:	out std_logic_vector(11 downto 0);
		CGSIN_LNA_RFE_1:	out std_logic_vector(4 downto 0);
		--
		ICT_LNACMO_RFE_1:	out std_logic_vector(4 downto 0);
		ICT_LNA_RFE_1:	out std_logic_vector(4 downto 0);
		ICT_LODC_RFE_1:	out std_logic_vector(4 downto 0);
		--
		ICT_LOOPB_RFE_1:	out std_logic_vector(4 downto 0);
		ICT_TIAMAIN_RFE_1:	out std_logic_vector(4 downto 0);
		ICT_TIAOUT_RFE_1:	out std_logic_vector(4 downto 0);
		--
		DCOFFI_RFE_1:	out std_logic_vector(6 downto 0);
		DCOFFQ_RFE_1:	out std_logic_vector(6 downto 0);
		--
		EN_DCOFF_RXFE_RFE_1:	out std_logic;
		EN_INSHSW_H_RFE_1:	out std_logic;
		EN_INSHSW_LB1_RFE_1:	out std_logic;
		EN_INSHSW_LB2_RFE_1:	out std_logic;
		EN_INSHSW_L_RFE_1:	out std_logic;
		EN_INSHSW_W_RFE_1:	out std_logic;
		EN_NEXTRX_RFE_1:	out std_logic;
		--
		PD_RLOOPB_1_RFE_1:	out std_logic;
		PD_RLOOPB_2_RFE_1:	out std_logic;
		PD_MXLOBUF_RFE_1:	out std_logic;
		PD_QGEN_RFE_1:	out std_logic;
		PD_RSSI_RFE_1:	out std_logic;
		PD_TIA_RFE_1:	out std_logic;

		-- RBB control lines 
		RESRV_RBB_1:		out std_logic_vector(6 downto 0);
		--
		INPUT_CTL_PGA_RBB_1:	out std_logic_vector(2 downto 0);
		RCC_CTL_PGA_RBB_1:	out std_logic_vector(4 downto 0);
		C_CTL_PGA_RBB_1:	out std_logic_vector(7 downto 0);
		--
		OSW_PGA_RBB_1:	out std_logic;
		ICT_PGA_OUT_RBB_1:	out std_logic_vector(4 downto 0);
		ICT_PGA_IN_RBB_1:	out std_logic_vector(4 downto 0);
		G_PGA_RBB_1:	out std_logic_vector(4 downto 0);
		--
		ICT_LPF_IN_RBB_1:	out std_logic_vector(4 downto 0);
		ICT_LPF_OUT_RBB_1:	out std_logic_vector(4 downto 0);
		--
		RCC_CTL_LPFL_RBB_1:	out std_logic_vector(2 downto 0);
		C_CTL_LPFL_RBB_1:	out std_logic_vector(10 downto 0);
		--
		R_CTL_LPF_RBB_1:	out std_logic_vector(4 downto 0);
		RCC_CTL_LPFH_RBB_1:	out std_logic_vector(2 downto 0);
		C_CTL_LPFH_RBB_1:	out std_logic_vector(7 downto 0);
		--
		EN_LB_LPFH_RBB_1:	out std_logic;
		EN_LB_LPFL_RBB_1:	out std_logic;
		PD_LPFH_RBB_1:	out std_logic;
		PD_LPFL_RBB_1:	out std_logic;
		PD_PGA_RBB_1:	out std_logic;
		
		-- SX control lines 
		RESRVE_SXR:		out std_logic_vector(4 downto 0);

		-- aditional, instead resrv
		PD_FBDIV_SXR:	out std_logic; 
		PD_FBDIV_SXT:	out std_logic;
		CDC_I_RFE_1:	out std_logic_vector(3 downto 0);
		CDC_Q_RFE_1:	out std_logic_vector(3 downto 0);
		CDC_I_RFE_2:	out std_logic_vector(3 downto 0);
		CDC_Q_RFE_2:	out std_logic_vector(3 downto 0);

		--
		VCO_CMPHO_SXR:	in std_logic;
		VCO_CMPLO_SXR:	in std_logic;
		COARSEPLL_COMPO_SXR:	in std_logic;
		COARSE_STEPDONE_SXR:	in std_logic;
		
		SDM_TSTO_SXR:	in std_logic_vector(13 downto 0);

		--
		CP2_PLL_SXR:	out std_logic_vector(3 downto 0);
		CP3_PLL_SXR:	out std_logic_vector(3 downto 0);
		CZ_SXR:		out std_logic_vector(3 downto 0);
		--
		REVPH_PFD_SXR:	out std_logic;
		IOFFSET_CP_SXR:	out std_logic_vector(5 downto 0);
		IPULSE_CP_SXR:	out std_logic_vector(5 downto 0);
		--
		RSEL_LDO_VCO_SXR:	out std_logic_vector(4 downto 0);
		CSW_VCO_SXR:	out std_logic_vector(7 downto 0);
		SEL_VCO_SXR:	out std_logic_vector(1 downto 0);
		COARSE_START_SXR:	out std_logic;
		--
		VDIV_VCO_SXR:	out std_logic_vector(7 downto 0);
		ICT_VCO_SXR:	out std_logic_vector(7 downto 0);
		--
		PW_DIV2_LOCH_SXR:	out std_logic_vector(2 downto 0);
		PW_DIV4_LOCH_SXR:	out std_logic_vector(2 downto 0);
		DIV_LOCH_SXR:	out std_logic_vector(2 downto 0);
		TST_SX_SXR:		out std_logic_vector(2 downto 0);
		SEL_SDMCLK_SXR:	out std_logic;
		SX_DITHER_EN_SXR:	out std_logic;
		REV_SDMCLK_SXR:	out std_logic;
		--
		INT_SDM_SXR:	out std_logic_vector(9 downto 0);
		FRAC_SDM_SXR:	out std_logic_vector(19 downto 0);
		--
		RESET_N_SXR:	out std_logic;
		SPDUP_VCO_SXR:	out std_logic;
		BYPLDO_VCO_SXR:	out std_logic;
		EN_COARSEPLL_SXR:	out std_logic;
		CURLIM_VCO_SXR:	out std_logic;
		EN_DIV2_DIVPROG_SXR:	out std_logic;
		EN_INTONLY_SDM_SXR:	out std_logic;
		EN_SDM_CLK_SXR:	out std_logic;
		EN_SDM_TSTO_SXR:	out std_logic;
		PD_CP_SXR:		out std_logic;
		PD_FDIV_SXR:	out std_logic;
		PD_SDM_SXR:		out std_logic;
		PD_VCO_COMP_SXR:	out std_logic;
		PD_VCO_SXR:		out std_logic;
		
		--============================= FROM ATRX CONFIGURATION, CNANNEL 2 =============================--
		-- TRF control lines
		CDC_I_TRF_2:	out std_logic_vector(3 downto 0);
		CDC_Q_TRF_2:	out std_logic_vector(3 downto 0);
		--
		LOBIASN_TXM_TRF_2:	out std_logic_vector(4 downto 0);
		LOBIASP_TXX_TRF_2:	out std_logic_vector(4 downto 0);
		--
		GCAS_GNDREF_TXPAD_TRF_2:	out std_logic;
		ICT_LIN_TXPAD_TRF_2:	out std_logic_vector(4 downto 0);
		ICT_MAIN_TXPAD_TRF_2:	out std_logic_vector(4 downto 0);
		VGCAS_TXPAD_TRF_2:	out std_logic_vector(4 downto 0);
		--
		SEL_BAND1_TRF_2:	out std_logic;
		SEL_BAND2_TRF_2:	out std_logic;
		F_TXPAD_TRF_2:	out std_logic_vector(2 downto 0);
		L_LOOPB_TXPAD_TRF_2:	out std_logic_vector(1 downto 0);
		LOSS_LIN_TXPAD_TRF_2:	out std_logic_vector(4 downto 0);
		LOSS_MAIN_TXPAD_TRF_2:	out std_logic_vector(4 downto 0);
		EN_LOOPB_TXPAD_TRF_2:	out std_logic;
		--
		EN_LOWBWLOMX_TMX_TRF_2:	out std_logic;
		EN_NEXTTX_TRF_2:	out std_logic;
		EN_AMPHF_PDET_TRF_2:	out std_logic_vector(1 downto 0);
		LOADR_PDET_TRF_2:	out std_logic_vector(1 downto 0);

		PD_PDET_TRF_2:	out std_logic;
		PD_TLOBUF_TRF_2:	out std_logic;
		PD_TXPAD_TRF_2:	out std_logic;


		-- TBB control lines
		RESRV_TBB_2:	out std_logic_vector(5 downto 0);
		--
		TSTIN_TBB_2:	out std_logic_vector(1 downto 0);
		BYPLADDER_TBB_2:	out std_logic;
		CCAL_LPFLAD_TBB_2:	out std_logic_vector(4 downto 0);
		RCAL_LPFS5_TBB_2:	out std_logic_vector(7 downto 0);
		--
		RCAL_LPFH_TBB_2:	out std_logic_vector(7 downto 0);
		RCAL_LPFLAD_TBB_2:	out std_logic_vector(7 downto 0);
		--
		CG_IAMP_TBB_2:	out std_logic_vector(5 downto 0);
		ICT_IAMP_FRP_TBB_2:	out std_logic_vector(4 downto 0);
		ICT_IAMP_GG_FRP_TBB_2:	out std_logic_vector(4 downto 0);
		--
		ICT_LPFH_F_TBB_2:	out std_logic_vector(4 downto 0);
		ICT_LPFLAD_F_TBB_2:	out std_logic_vector(4 downto 0);
		ICT_LPFLAD_PT_TBB_2:	out std_logic_vector(4 downto 0);
		--
		ICT_LPFS5_F_TBB_2:	out std_logic_vector(4 downto 0);
		ICT_LPFS5_PT_TBB_2:	out std_logic_vector(4 downto 0);
		ICT_LPF_H_PT_TBB_2:	out std_logic_vector(4 downto 0);
		--
		STATPULSE_TBB_2:	out std_logic;
		LOOPB_TBB_2:	out std_logic_vector(2 downto 0);
		PD_LPFH_TBB_2:	out std_logic;
		PD_LPFIAMP_TBB_2:	out std_logic;
		PD_LPFLAD_TBB_2:	out std_logic;
		PD_LPFS5_TBB_2:	out std_logic;
		PD_TBB_2:		out std_logic;

		-- RFE control lines
		
		PD_LNA_RFE_2:		out std_logic;
		SEL_PATH_RFE_2:		out std_logic_vector(1 downto 0);
		
		--
		
		RCOMP_TIA_RFE_2:	out std_logic_vector(3 downto 0);
		RFB_TIA_RFE_2:	out std_logic_vector(4 downto 0);
		--
		G_LNA_RFE_2:	out std_logic_vector(3 downto 0);
		G_RXLOOPB_RFE_2:	out std_logic_vector(3 downto 0);
		G_TIA_RFE_2:	out std_logic_vector(1 downto 0);
		--
		CAP_RXMXO_RFE_2:	out std_logic_vector(4 downto 0);
		CCOMP_TIA_RFE_2:	out std_logic_vector(3 downto 0);
		CFB_TIA_RFE_2:	out std_logic_vector(11 downto 0);
		CGSIN_LNA_RFE_2:	out std_logic_vector(4 downto 0);
		--
		ICT_LNACMO_RFE_2:	out std_logic_vector(4 downto 0);
		ICT_LNA_RFE_2:	out std_logic_vector(4 downto 0);
		ICT_LODC_RFE_2:	out std_logic_vector(4 downto 0);
		--
		ICT_LOOPB_RFE_2:	out std_logic_vector(4 downto 0);
		ICT_TIAMAIN_RFE_2:	out std_logic_vector(4 downto 0);
		ICT_TIAOUT_RFE_2:	out std_logic_vector(4 downto 0);
		--
		DCOFFI_RFE_2:	out std_logic_vector(6 downto 0);
		DCOFFQ_RFE_2:	out std_logic_vector(6 downto 0);
		--
		EN_DCOFF_RXFE_RFE_2:	out std_logic;
		EN_INSHSW_H_RFE_2:	out std_logic;
		EN_INSHSW_LB1_RFE_2:	out std_logic;
		EN_INSHSW_LB2_RFE_2:	out std_logic;
		EN_INSHSW_L_RFE_2:	out std_logic;
		EN_INSHSW_W_RFE_2:	out std_logic;
		EN_NEXTRX_RFE_2:	out std_logic;
		--
		PD_RLOOPB_1_RFE_2:	out std_logic;
		PD_RLOOPB_2_RFE_2:	out std_logic;
		PD_MXLOBUF_RFE_2:	out std_logic;
		PD_QGEN_RFE_2:	out std_logic;
		PD_RSSI_RFE_2:	out std_logic;
		PD_TIA_RFE_2:	out std_logic;

		-- RBB control lines 
		RESRV_RBB_2:	out std_logic_vector(6 downto 0);
		--
		INPUT_CTL_PGA_RBB_2:	out std_logic_vector(2 downto 0);
		RCC_CTL_PGA_RBB_2:	out std_logic_vector(4 downto 0);
		C_CTL_PGA_RBB_2:	out std_logic_vector(7 downto 0);
		--
		OSW_PGA_RBB_2:	out std_logic;
		ICT_PGA_OUT_RBB_2:	out std_logic_vector(4 downto 0);
		ICT_PGA_IN_RBB_2:	out std_logic_vector(4 downto 0);
		G_PGA_RBB_2:	out std_logic_vector(4 downto 0);
		--
		ICT_LPF_IN_RBB_2:	out std_logic_vector(4 downto 0);
		ICT_LPF_OUT_RBB_2:	out std_logic_vector(4 downto 0);
		--
		RCC_CTL_LPFL_RBB_2:	out std_logic_vector(2 downto 0);
		C_CTL_LPFL_RBB_2:	out std_logic_vector(10 downto 0);
		--
		R_CTL_LPF_RBB_2:	out std_logic_vector(4 downto 0);
		RCC_CTL_LPFH_RBB_2:	out std_logic_vector(2 downto 0);
		C_CTL_LPFH_RBB_2:	out std_logic_vector(7 downto 0);
		--
		EN_LB_LPFH_RBB_2:	out std_logic;
		EN_LB_LPFL_RBB_2:	out std_logic;
		PD_LPFH_RBB_2:	out std_logic;
		PD_LPFL_RBB_2:	out std_logic;
		PD_PGA_RBB_2:	out std_logic;
		
		-- SX control lines 
		RESRV_SXT:		out std_logic;
		
		--
		VCO_CMPHO_SXT:	in std_logic;
		VCO_CMPLO_SXT:	in std_logic;
		COARSEPLL_COMPO_SXT:	in std_logic;
		COARSE_STEPDONE_SXT:	in std_logic;
		
		SDM_TSTO_SXT:	in std_logic_vector(13 downto 0);
		
		--
		CP2_PLL_SXT:	out std_logic_vector(3 downto 0);
		CP3_PLL_SXT:	out std_logic_vector(3 downto 0);
		CZ_SXT:		out std_logic_vector(3 downto 0);
		--
		REVPH_PFD_SXT:	out std_logic;
		IOFFSET_CP_SXT:	out std_logic_vector(5 downto 0);
		IPULSE_CP_SXT:	out std_logic_vector(5 downto 0);
		--
		RSEL_LDO_VCO_SXT:	out std_logic_vector(4 downto 0);
		CSW_VCO_SXT:	out std_logic_vector(7 downto 0);
		SEL_VCO_SXT:	out std_logic_vector(1 downto 0);
		COARSE_START_SXT:	out std_logic;
		--
		VDIV_VCO_SXT:	out std_logic_vector(7 downto 0);
		ICT_VCO_SXT:	out std_logic_vector(7 downto 0);
		--
		PW_DIV2_LOCH_SXT:	out std_logic_vector(2 downto 0);
		PW_DIV4_LOCH_SXT:	out std_logic_vector(2 downto 0);
		DIV_LOCH_SXT:	out std_logic_vector(2 downto 0);
		TST_SX_SXT:		out std_logic_vector(2 downto 0);
		SEL_SDMCLK_SXT:	out std_logic;
		SX_DITHER_EN_SXT:	out std_logic;
		REV_SDMCLK_SXT:	out std_logic;
		--
		INT_SDM_SXT:	out std_logic_vector(9 downto 0);
		FRAC_SDM_SXT:	out std_logic_vector(19 downto 0);
		--
		RESET_N_SXT:	out std_logic;
		SPDUP_VCO_SXT:	out std_logic;
		BYPLDO_VCO_SXT:	out std_logic;
		EN_COARSEPLL_SXT:	out std_logic;
		CURLIM_VCO_SXT:	out std_logic;
		EN_DIV2_DIVPROG_SXT:	out std_logic;
		EN_INTONLY_SDM_SXT:	out std_logic;
		EN_SDM_CLK_SXT:	out std_logic;
		EN_SDM_TSTO_SXT:	out std_logic;
		PD_LOCH_T2RBUF:	out std_logic;
		PD_CP_SXT:		out std_logic;
		PD_FDIV_SXT:	out std_logic;
		PD_SDM_SXT:		out std_logic;
		PD_VCO_COMP_SXT:	out std_logic;
		PD_VCO_SXT:		out std_logic
	);
end component;

-- ----------------------------------------------------------------------------
component acbufl
	port (
	------------------------------------------	
	-- connects to spi modulle

	-- AFE control lines
	MUX_AFE_1_i:	in std_logic_vector(1 downto 0);
	MUX_AFE_2_i:	in std_logic_vector(1 downto 0);
	PD_AFE_i:	in std_logic;

	-- BIAS control lines
	RESRV_BIAS_i:	in std_logic_vector(10 downto 0);
	MUX_BIAS_OUT_i:	in std_logic_vector(1 downto 0);
	RP_CALIB_BIAS_i:	in std_logic_vector(4 downto 0);
	PD_FRP_BIAS_i:	in std_logic;
	PD_F_BIAS_i:	in std_logic;
	PD_PTRP_BIAS_i:	in std_logic;
	PD_PT_BIAS_i:	in std_logic;
	PD_BIAS_MASTER_i:	in std_logic;

	-- XBUF control lines
	SLFB_XBUF_TX_i:	in std_logic;
	BYP_XBUF_TX_i:	in std_logic;
	EN_OUT2_XBUF_TX_i:	in std_logic;
	PD_XBUF_TX_i:	in std_logic;

	-- CLKGEN control lines	
		
	-- LDO control lines	
	RDIV_CPGN_i:	in std_logic_vector(7 downto 0);
	RDIV_CPSXT_i:	in std_logic_vector(7 downto 0);
	RDIV_DIG_i:	in std_logic_vector(7 downto 0);
	RDIV_DIGGN_i:	in std_logic_vector(7 downto 0);
	RDIV_DIGSXT_i:	in std_logic_vector(7 downto 0);
	RDIV_DIVGN_i:	in std_logic_vector(7 downto 0);
	RDIV_DIVSXT_i:	in std_logic_vector(7 downto 0);
	RDIV_TBB_i:	in std_logic_vector(7 downto 0);
	RDIV_TLOB_i:	in std_logic_vector(7 downto 0);
	RDIV_TPAD_i:	in std_logic_vector(7 downto 0);
	RDIV_TXBUF_i:	in std_logic_vector(7 downto 0);
	RDIV_VCOGN_i:	in std_logic_vector(7 downto 0);
	RDIV_VCOSXT_i:	in std_logic_vector(7 downto 0);
	SPDUP_LDO_CPGN_i:	in std_logic;
	SPDUP_LDO_CPSXT_i:	in std_logic;
	SPDUP_LDO_DIG_i:	in std_logic;
	SPDUP_LDO_DIGGN_i:	in std_logic;
	SPDUP_LDO_DIGSXT_i:	in std_logic;
	SPDUP_LDO_DIVGN_i:	in std_logic;
	SPDUP_LDO_DIVSXT_i:	in std_logic;
	SPDUP_LDO_TBB_i:	in std_logic;
	SPDUP_LDO_TLOB_i:	in std_logic;
	SPDUP_LDO_TPAD_i:	in std_logic;
	SPDUP_LDO_TXBUF_i:	in std_logic;
	SPDUP_LDO_VCOGN_i:	in std_logic;
	SPDUP_LDO_VCOSXT_i:	in std_logic;
	BYP_LDO_CPGN_i:	in std_logic;
	BYP_LDO_CPSXT_i:	in std_logic;
	BYP_LDO_DIG_i:	in std_logic;
	BYP_LDO_DIGGN_i:	in std_logic;
	BYP_LDO_DIGSXT_i:	in std_logic;
	BYP_LDO_DIVGN_i:	in std_logic;
	BYP_LDO_DIVSXT_i:	in std_logic;
	BYP_LDO_TBB_i:	in std_logic;
	BYP_LDO_TLOB_i:	in std_logic;
	BYP_LDO_TPAD_i:	in std_logic;
	BYP_LDO_TXBUF_i:	in std_logic;
	BYP_LDO_VCOGN_i:	in std_logic;
	BYP_LDO_VCOSXT_i:	in std_logic;
	EN_LOADIMP_LDO_CPGN_i:	in std_logic;
	EN_LOADIMP_LDO_CPSXT_i:	in std_logic;
	EN_LOADIMP_LDO_DIG_i:	in std_logic;
	EN_LOADIMP_LDO_DIGGN_i:	in std_logic;
	EN_LOADIMP_LDO_DIGSXT_i:	in std_logic;
	EN_LOADIMP_LDO_DIVGN_i:	in std_logic;
	EN_LOADIMP_LDO_DIVSXT_i:	in std_logic;
	EN_LOADIMP_LDO_TBB_i:	in std_logic;
	EN_LOADIMP_LDO_TLOB_i:	in std_logic;
	EN_LOADIMP_LDO_TPAD_i:	in std_logic;
	EN_LOADIMP_LDO_TXBUF_i:	in std_logic;
	EN_LOADIMP_LDO_VCOGN_i:	in std_logic;
	EN_LOADIMP_LDO_VCOSXT_i:	in std_logic;
	EN_LDO_CPGN_i:	in std_logic;
	EN_LDO_TLOB_i:	in std_logic;
	EN_LDO_TPAD_i:	in std_logic;
	EN_LDO_TXBUF_i:	in std_logic;
	EN_LDO_VCOGN_i:	in std_logic;
	EN_LDO_VCOSXT_i:	in std_logic;
	EN_LDO_CPSXT_i:	in std_logic;
	EN_LDO_DIG_i:	in std_logic;
	EN_LDO_DIGGN_i:	in std_logic;
	EN_LDO_DIGSXT_i:	in std_logic;
	EN_LDO_DIVGN_i:	in std_logic;
	EN_LDO_DIVSXT_i:	in std_logic;
	EN_LDO_TBB_i:	in std_logic;


	--============================= FROM ATRX CONFIGURATION, CNANNEL 1 =============================--
	-- TRF control lines
	LOBIASN_TXM_TRF_1_i:	in std_logic_vector(4 downto 0);
	LOBIASP_TXX_TRF_1_i:	in std_logic_vector(4 downto 0);
	--
	GCAS_GNDREF_TXPAD_TRF_1_i:	in std_logic;
	ICT_LIN_TXPAD_TRF_1_i:	in std_logic_vector(4 downto 0);
	ICT_MAIN_TXPAD_TRF_1_i:	in std_logic_vector(4 downto 0);
	VGCAS_TXPAD_TRF_1_i:	in std_logic_vector(4 downto 0);
	--
	SEL_BAND1_TRF_1_i:	in std_logic;
	SEL_BAND2_TRF_1_i:	in std_logic;
	F_TXPAD_TRF_1_i:	in std_logic_vector(2 downto 0);
	L_LOOPB_TXPAD_TRF_1_i:	in std_logic_vector(1 downto 0);
	LOSS_LIN_TXPAD_TRF_1_i:	in std_logic_vector(4 downto 0);
	LOSS_MAIN_TXPAD_TRF_1_i:	in std_logic_vector(4 downto 0);
	EN_LOOPB_TXPAD_TRF_1_i:	in std_logic;
	--
	EN_LOWBWLOMX_TMX_TRF_1_i:	in std_logic;
	EN_NEXTTX_TRF_1_i:	in std_logic;
	EN_AMPHF_PDET_TRF_1_i:	in std_logic_vector(1 downto 0);
	LOADR_PDET_TRF_1_i:	in std_logic_vector(1 downto 0);

	PD_PDET_TRF_1_i:	in std_logic;
	PD_TLOBUF_TRF_1_i:	in std_logic;
	PD_TXPAD_TRF_1_i:	in std_logic;


	-- TBB control lines
	RESRV_TBB_1_i:	in std_logic_vector(5 downto 0);
	--
	TSTIN_TBB_1_i:	in std_logic_vector(1 downto 0);
	BYPLADDER_TBB_1_i:	in std_logic;
	CCAL_LPFLAD_TBB_1_i:	in std_logic_vector(4 downto 0);
	RCAL_LPFS5_TBB_1_i:	in std_logic_vector(7 downto 0);
	--
	RCAL_LPFH_TBB_1_i:	in std_logic_vector(7 downto 0);
	RCAL_LPFLAD_TBB_1_i:	in std_logic_vector(7 downto 0);
	--
	CG_IAMP_TBB_1_i:	in std_logic_vector(5 downto 0);
	ICT_IAMP_FRP_TBB_1_i:	in std_logic_vector(4 downto 0);
	ICT_IAMP_GG_FRP_TBB_1_i:	in std_logic_vector(4 downto 0);
	--
	ICT_LPFH_F_TBB_1_i:	in std_logic_vector(4 downto 0);
	ICT_LPFLAD_F_TBB_1_i:	in std_logic_vector(4 downto 0);
	ICT_LPFLAD_PT_TBB_1_i:	in std_logic_vector(4 downto 0);
	--
	ICT_LPFS5_F_TBB_1_i:	in std_logic_vector(4 downto 0);
	ICT_LPFS5_PT_TBB_1_i:	in std_logic_vector(4 downto 0);
	ICT_LPF_H_PT_TBB_1_i:	in std_logic_vector(4 downto 0);
	--
	STATPULSE_TBB_1_i:	in std_logic;
	LOOPB_TBB_1_i:	in std_logic_vector(2 downto 0);
	PD_LPFH_TBB_1_i:	in std_logic;
	PD_LPFIAMP_TBB_1_i:	in std_logic;
	PD_LPFLAD_TBB_1_i:	in std_logic;
	PD_LPFS5_TBB_1_i:	in std_logic;
	PD_TBB_1_i:	in std_logic;


	-- RFE control lines

	RCOMP_TIA_RFE_1_i:	in std_logic_vector(3 downto 0);
	RFB_TIA_RFE_1_i:	in std_logic_vector(4 downto 0);
	--
	G_LNA_RFE_1_i:	in std_logic_vector(3 downto 0);
	G_RXLOOPB_RFE_1_i:	in std_logic_vector(3 downto 0);
	G_TIA_RFE_1_i:	in std_logic_vector(1 downto 0);
	--
	CAP_RXMXO_RFE_1_i:	in std_logic_vector(4 downto 0);
	CCOMP_TIA_RFE_1_i:	in std_logic_vector(3 downto 0);
	CFB_TIA_RFE_1_i:	in std_logic_vector(11 downto 0);
	CGSIN_LNA_RFE_1_i:	in std_logic_vector(4 downto 0);
	--
	ICT_LNACMO_RFE_1_i:	in std_logic_vector(4 downto 0);
	ICT_LNA_RFE_1_i:	in std_logic_vector(4 downto 0);
	ICT_LODC_RFE_1_i:	in std_logic_vector(4 downto 0);
	--
	ICT_LOOPB_RFE_1_i:	in std_logic_vector(4 downto 0);
	ICT_TIAMAIN_RFE_1_i:	in std_logic_vector(4 downto 0);
	ICT_TIAOUT_RFE_1_i:	in std_logic_vector(4 downto 0);
	--
	DCOFFI_RFE_1_i:	in std_logic_vector(6 downto 0);
	DCOFFQ_RFE_1_i:	in std_logic_vector(6 downto 0);
	--
	EN_DCOFF_RXFE_RFE_1_i:	in std_logic;
	EN_INSHSW_H_RFE_1_i:	in std_logic;
	EN_INSHSW_LB1_RFE_1_i:	in std_logic;
	EN_INSHSW_LB2_RFE_1_i:	in std_logic;
	EN_INSHSW_L_RFE_1_i:	in std_logic;
	EN_INSHSW_W_RFE_1_i:	in std_logic;
	EN_NEXTRX_RFE_1_i:	in std_logic;
	--
	PD_RLOOPB_1_RFE_1_i:	in std_logic;
	PD_RLOOPB_2_RFE_1_i:	in std_logic;
	PD_MXLOBUF_RFE_1_i:	in std_logic;
	PD_QGEN_RFE_1_i:	in std_logic;
	PD_RSSI_RFE_1_i:	in std_logic;
	PD_TIA_RFE_1_i:	in std_logic;

	-- RBB control lines 
	RESRV_RBB_1_i:	in std_logic_vector(6 downto 0);
	--
	INPUT_CTL_PGA_RBB_1_i:	in std_logic_vector(2 downto 0);
	RCC_CTL_PGA_RBB_1_i:	in std_logic_vector(4 downto 0);
	C_CTL_PGA_RBB_1_i:	in std_logic_vector(7 downto 0);
	--
	OSW_PGA_RBB_1_i:	in std_logic;
	ICT_PGA_OUT_RBB_1_i:	in std_logic_vector(4 downto 0);
	ICT_PGA_IN_RBB_1_i:	in std_logic_vector(4 downto 0);
	G_PGA_RBB_1_i:	in std_logic_vector(4 downto 0);
	--
	ICT_LPF_IN_RBB_1_i:	in std_logic_vector(4 downto 0);
	ICT_LPF_OUT_RBB_1_i:	in std_logic_vector(4 downto 0);
	--
	RCC_CTL_LPFL_RBB_1_i:	in std_logic_vector(2 downto 0);
	C_CTL_LPFL_RBB_1_i:	in std_logic_vector(10 downto 0);
	--
	R_CTL_LPF_RBB_1_i:	in std_logic_vector(4 downto 0);
	RCC_CTL_LPFH_RBB_1_i:	in std_logic_vector(2 downto 0);
	C_CTL_LPFH_RBB_1_i:	in std_logic_vector(7 downto 0);
	--
	EN_LB_LPFH_RBB_1_i:	in std_logic;
	EN_LB_LPFL_RBB_1_i:	in std_logic;
	PD_LPFH_RBB_1_i:	in std_logic;
	PD_LPFL_RBB_1_i:	in std_logic;
	PD_PGA_RBB_1_i:	in std_logic;
	
	-- SX control lines 
	RESRVE_SXR_i:	in std_logic_vector(4 downto 0);

	--
	VCO_CMPHO_SXR_o:	out std_logic;
	VCO_CMPLO_SXR_o:	out std_logic;
	COARSEPLL_COMPO_SXR_o:	out std_logic;
	COARSE_STEPDONE_SXR_o:	out std_logic;
	SDM_TSTO_SXR_o:	out std_logic_vector(13 downto 0);

	--
	CP2_PLL_SXR_i:	in std_logic_vector(3 downto 0);
	CP3_PLL_SXR_i:	in std_logic_vector(3 downto 0);
	CZ_SXR_i:	in std_logic_vector(3 downto 0);
	--
	REVPH_PFD_SXR_i:	in std_logic;
	IOFFSET_CP_SXR_i:	in std_logic_vector(5 downto 0);
	IPULSE_CP_SXR_i:	in std_logic_vector(5 downto 0);
	--
	RSEL_LDO_VCO_SXR_i:	in std_logic_vector(4 downto 0);
	CSW_VCO_SXR_i:	in std_logic_vector(7 downto 0);
	SEL_VCO_SXR_i:	in std_logic_vector(1 downto 0);
	COARSE_START_SXR_i:	in std_logic;
	--
	VDIV_VCO_SXR_i:	in std_logic_vector(7 downto 0);
	ICT_VCO_SXR_i:	in std_logic_vector(7 downto 0);
	--
	PW_DIV2_LOCH_SXR_i:	in std_logic_vector(2 downto 0);
	PW_DIV4_LOCH_SXR_i:	in std_logic_vector(2 downto 0);
	DIV_LOCH_SXR_i:	in std_logic_vector(2 downto 0);
	TST_SX_SXR_i:	in std_logic_vector(2 downto 0);
	SEL_SDMCLK_SXR_i:	in std_logic;
	SX_DITHER_EN_SXR_i:	in std_logic;
	REV_SDMCLK_SXR_i:	in std_logic;
	--
	INT_SDM_SXR_i:	in std_logic_vector(9 downto 0);
	FRAC_SDM_SXR_i:	in std_logic_vector(19 downto 0);
	--
	RESET_N_SXR_i:	in std_logic;
	SPDUP_VCO_SXR_i:	in std_logic;
	BYPLDO_VCO_SXR_i:	in std_logic;
	EN_COARSEPLL_SXR_i:	in std_logic;
	CURLIM_VCO_SXR_i:	in std_logic;
	EN_DIV2_DIVPROG_SXR_i:	in std_logic;
	EN_INTONLY_SDM_SXR_i:	in std_logic;
	EN_SDM_CLK_SXR_i:	in std_logic;
	EN_SDM_TSTO_SXR_i:	in std_logic;
	PD_CP_SXR_i:	in std_logic;
	PD_FDIV_SXR_i:	in std_logic;
	PD_SDM_SXR_i:	in std_logic;
	PD_VCO_COMP_SXR_i:	in std_logic;
	PD_VCO_SXR_i:	in std_logic;


	--============================= FROM ATRX CONFIGURATION, CNANNEL 2 =============================--
	-- TRF control lines
	LOBIASN_TXM_TRF_2_i:	in std_logic_vector(4 downto 0);
	LOBIASP_TXX_TRF_2_i:	in std_logic_vector(4 downto 0);
	--
	GCAS_GNDREF_TXPAD_TRF_2_i:	in std_logic;
	ICT_LIN_TXPAD_TRF_2_i:	in std_logic_vector(4 downto 0);
	ICT_MAIN_TXPAD_TRF_2_i:	in std_logic_vector(4 downto 0);
	VGCAS_TXPAD_TRF_2_i:	in std_logic_vector(4 downto 0);
	--
	SEL_BAND1_TRF_2_i:	in std_logic;
	SEL_BAND2_TRF_2_i:	in std_logic;
	F_TXPAD_TRF_2_i:	in std_logic_vector(2 downto 0);
	L_LOOPB_TXPAD_TRF_2_i:	in std_logic_vector(1 downto 0);
	LOSS_LIN_TXPAD_TRF_2_i:	in std_logic_vector(4 downto 0);
	LOSS_MAIN_TXPAD_TRF_2_i:	in std_logic_vector(4 downto 0);
	EN_LOOPB_TXPAD_TRF_2_i:	in std_logic;
	--
	EN_LOWBWLOMX_TMX_TRF_2_i:	in std_logic;
	EN_NEXTTX_TRF_2_i:	in std_logic;
	EN_AMPHF_PDET_TRF_2_i:	in std_logic_vector(1 downto 0);
	LOADR_PDET_TRF_2_i:	in std_logic_vector(1 downto 0);

	PD_PDET_TRF_2_i:	in std_logic;
	PD_TLOBUF_TRF_2_i:	in std_logic;
	PD_TXPAD_TRF_2_i:	in std_logic;


	-- TBB control lines
	RESRV_TBB_2_i:	in std_logic_vector(5 downto 0);
	--
	TSTIN_TBB_2_i:	in std_logic_vector(1 downto 0);
	BYPLADDER_TBB_2_i:	in std_logic;
	CCAL_LPFLAD_TBB_2_i:	in std_logic_vector(4 downto 0);
	RCAL_LPFS5_TBB_2_i:	in std_logic_vector(7 downto 0);
	--
	RCAL_LPFH_TBB_2_i:	in std_logic_vector(7 downto 0);
	RCAL_LPFLAD_TBB_2_i:	in std_logic_vector(7 downto 0);
	--
	CG_IAMP_TBB_2_i:	in std_logic_vector(5 downto 0);
	ICT_IAMP_FRP_TBB_2_i:	in std_logic_vector(4 downto 0);
	ICT_IAMP_GG_FRP_TBB_2_i:	in std_logic_vector(4 downto 0);
	--
	ICT_LPFH_F_TBB_2_i:	in std_logic_vector(4 downto 0);
	ICT_LPFLAD_F_TBB_2_i:	in std_logic_vector(4 downto 0);
	ICT_LPFLAD_PT_TBB_2_i:	in std_logic_vector(4 downto 0);
	--
	ICT_LPFS5_F_TBB_2_i:	in std_logic_vector(4 downto 0);
	ICT_LPFS5_PT_TBB_2_i:	in std_logic_vector(4 downto 0);
	ICT_LPF_H_PT_TBB_2_i:	in std_logic_vector(4 downto 0);
	--
	STATPULSE_TBB_2_i:	in std_logic;
	LOOPB_TBB_2_i:	in std_logic_vector(2 downto 0);
	PD_LPFH_TBB_2_i:	in std_logic;
	PD_LPFIAMP_TBB_2_i:	in std_logic;
	PD_LPFLAD_TBB_2_i:	in std_logic;
	PD_LPFS5_TBB_2_i:	in std_logic;
	PD_TBB_2_i:	in std_logic;


	-- RFE control lines
	RCOMP_TIA_RFE_2_i:	in std_logic_vector(3 downto 0);
	RFB_TIA_RFE_2_i:	in std_logic_vector(4 downto 0);
	--
	G_LNA_RFE_2_i:	in std_logic_vector(3 downto 0);
	G_RXLOOPB_RFE_2_i:	in std_logic_vector(3 downto 0);
	G_TIA_RFE_2_i:	in std_logic_vector(1 downto 0);
	--
	CAP_RXMXO_RFE_2_i:	in std_logic_vector(4 downto 0);
	CCOMP_TIA_RFE_2_i:	in std_logic_vector(3 downto 0);
	CFB_TIA_RFE_2_i:	in std_logic_vector(11 downto 0);
	CGSIN_LNA_RFE_2_i:	in std_logic_vector(4 downto 0);
	--
	ICT_LNACMO_RFE_2_i:	in std_logic_vector(4 downto 0);
	ICT_LNA_RFE_2_i:	in std_logic_vector(4 downto 0);
	ICT_LODC_RFE_2_i:	in std_logic_vector(4 downto 0);
	--
	ICT_LOOPB_RFE_2_i:	in std_logic_vector(4 downto 0);
	ICT_TIAMAIN_RFE_2_i:	in std_logic_vector(4 downto 0);
	ICT_TIAOUT_RFE_2_i:	in std_logic_vector(4 downto 0);
	--
	DCOFFI_RFE_2_i:	in std_logic_vector(6 downto 0);
	DCOFFQ_RFE_2_i:	in std_logic_vector(6 downto 0);
	--
	EN_DCOFF_RXFE_RFE_2_i:	in std_logic;
	EN_INSHSW_H_RFE_2_i:	in std_logic;
	EN_INSHSW_LB1_RFE_2_i:	in std_logic;
	EN_INSHSW_LB2_RFE_2_i:	in std_logic;
	EN_INSHSW_L_RFE_2_i:	in std_logic;
	EN_INSHSW_W_RFE_2_i:	in std_logic;
	EN_NEXTRX_RFE_2_i:	in std_logic;
	--
	PD_RLOOPB_1_RFE_2_i:	in std_logic;
	PD_RLOOPB_2_RFE_2_i:	in std_logic;
	PD_MXLOBUF_RFE_2_i:	in std_logic;
	PD_QGEN_RFE_2_i:	in std_logic;
	PD_RSSI_RFE_2_i:	in std_logic;
	PD_TIA_RFE_2_i:	in std_logic;

	-- RBB control lines 
	RESRV_RBB_2_i:	in std_logic_vector(6 downto 0);
	--
	INPUT_CTL_PGA_RBB_2_i:	in std_logic_vector(2 downto 0);
	RCC_CTL_PGA_RBB_2_i:	in std_logic_vector(4 downto 0);
	C_CTL_PGA_RBB_2_i:	in std_logic_vector(7 downto 0);
	--
	OSW_PGA_RBB_2_i:	in std_logic;
	ICT_PGA_OUT_RBB_2_i:	in std_logic_vector(4 downto 0);
	ICT_PGA_IN_RBB_2_i:	in std_logic_vector(4 downto 0);
	G_PGA_RBB_2_i:	in std_logic_vector(4 downto 0);
	--
	ICT_LPF_IN_RBB_2_i:	in std_logic_vector(4 downto 0);
	ICT_LPF_OUT_RBB_2_i:	in std_logic_vector(4 downto 0);
	--
	RCC_CTL_LPFL_RBB_2_i:	in std_logic_vector(2 downto 0);
	C_CTL_LPFL_RBB_2_i:	in std_logic_vector(10 downto 0);
	--
	R_CTL_LPF_RBB_2_i:	in std_logic_vector(4 downto 0);
	RCC_CTL_LPFH_RBB_2_i:	in std_logic_vector(2 downto 0);
	C_CTL_LPFH_RBB_2_i:	in std_logic_vector(7 downto 0);
	--
	EN_LB_LPFH_RBB_2_i:	in std_logic;
	EN_LB_LPFL_RBB_2_i:	in std_logic;
	PD_LPFH_RBB_2_i:	in std_logic;
	PD_LPFL_RBB_2_i:	in std_logic;
	PD_PGA_RBB_2_i:	in std_logic;

	-- SX control lines 
	RESRV_SXT_i:	in std_logic;
	VCO_CMPHO_SXT_o:	out std_logic;
	VCO_CMPLO_SXT_o:	out std_logic;
	COARSEPLL_COMPO_SXT_o:	out std_logic;
	COARSE_STEPDONE_SXT_o:	out std_logic;
	--SDM_TSTO_SXT_o:	out std_logic_vector(13 downto 0);
	--
	CP2_PLL_SXT_i:	in std_logic_vector(3 downto 0);
	CP3_PLL_SXT_i:	in std_logic_vector(3 downto 0);
	CZ_SXT_i:	in std_logic_vector(3 downto 0);
	--
	REVPH_PFD_SXT_i:	in std_logic;
	IOFFSET_CP_SXT_i:	in std_logic_vector(5 downto 0);
	IPULSE_CP_SXT_i:	in std_logic_vector(5 downto 0);
	--
	RSEL_LDO_VCO_SXT_i:	in std_logic_vector(4 downto 0);
	CSW_VCO_SXT_i:	in std_logic_vector(7 downto 0);
	SEL_VCO_SXT_i:	in std_logic_vector(1 downto 0);
	COARSE_START_SXT_i:	in std_logic;
	--
	VDIV_VCO_SXT_i:	in std_logic_vector(7 downto 0);
	ICT_VCO_SXT_i:	in std_logic_vector(7 downto 0);
	--
	PW_DIV2_LOCH_SXT_i:	in std_logic_vector(2 downto 0);
	PW_DIV4_LOCH_SXT_i:	in std_logic_vector(2 downto 0);
	DIV_LOCH_SXT_i:	in std_logic_vector(2 downto 0);
	TST_SX_SXT_i:	in std_logic_vector(2 downto 0);
	SEL_SDMCLK_SXT_i:	in std_logic;
	SX_DITHER_EN_SXT_i:	in std_logic;
	REV_SDMCLK_SXT_i:	in std_logic;
	--
	INT_SDM_SXT_i:	in std_logic_vector(9 downto 0);
	FRAC_SDM_SXT_i:	in std_logic_vector(19 downto 0);
	--
	RESET_N_SXT_i:	in std_logic;
	SPDUP_VCO_SXT_i:	in std_logic;
	BYPLDO_VCO_SXT_i:	in std_logic;
	EN_COARSEPLL_SXT_i:	in std_logic;
	CURLIM_VCO_SXT_i:	in std_logic;
	EN_DIV2_DIVPROG_SXT_i:	in std_logic;
	EN_INTONLY_SDM_SXT_i:	in std_logic;
	EN_SDM_CLK_SXT_i:	in std_logic;
	EN_SDM_TSTO_SXT_i:	in std_logic;
	PD_LOCH_T2RBUF_i:	in std_logic;
	PD_CP_SXT_i:	in std_logic;
	PD_FDIV_SXT_i:	in std_logic;
	PD_SDM_SXT_i:	in std_logic;
	PD_VCO_COMP_SXT_i:	in std_logic;
	PD_VCO_SXT_i:	in std_logic;
	
	-- aditional, instead resrv
	PD_FBDIV_SXR_i:	in std_logic; 
	PD_FBDIV_SXT_i:	in std_logic;

	CDC_I_RFE_1_i:	in std_logic_vector(3 downto 0);
	CDC_Q_RFE_1_i:	in std_logic_vector(3 downto 0);
	CDC_I_RFE_2_i:	in std_logic_vector(3 downto 0);
	CDC_Q_RFE_2_i:	in std_logic_vector(3 downto 0);

	CDC_I_TRF_1_i:	in std_logic_vector(3 downto 0);
	CDC_Q_TRF_1_i:	in std_logic_vector(3 downto 0);

	CDC_I_TRF_2_i:	in std_logic_vector(3 downto 0);
	CDC_Q_TRF_2_i:	in std_logic_vector(3 downto 0);
	
	
	------------------------------------------
	-- connects to other modulles
	
	-- AFE control lines
	MUX_AFE_1:	out std_logic_vector(1 downto 0);
	MUX_AFE_2:	out std_logic_vector(1 downto 0);
	PD_AFE:	out std_logic;

	-- BIAS control lines
	RESRV_BIAS:	out std_logic_vector(10 downto 0);
	MUX_BIAS_OUT:	out std_logic_vector(1 downto 0);
	RP_CALIB_BIAS:	out std_logic_vector(4 downto 0);
	PD_FRP_BIAS:	out std_logic;
	PD_F_BIAS:	out std_logic;
	PD_PTRP_BIAS:	out std_logic;
	PD_PT_BIAS:	out std_logic;
	PD_BIAS_MASTER:	out std_logic;

	-- XBUF control lines
	SLFB_XBUF_TX:	out std_logic;
	BYP_XBUF_TX:	out std_logic;
	EN_OUT2_XBUF_TX:	out std_logic;
	PD_XBUF_TX:	out std_logic;

	-- CLKGEN control lines	
		
	-- LDO control lines	
	RDIV_CPGN:	out std_logic_vector(7 downto 0);
	RDIV_CPSXT:	out std_logic_vector(7 downto 0);
	RDIV_DIG :	out std_logic_vector(7 downto 0);
	RDIV_DIGGN:	out std_logic_vector(7 downto 0);
	RDIV_DIGSXT:	out std_logic_vector(7 downto 0);
	RDIV_DIVGN :	out std_logic_vector(7 downto 0);
	RDIV_DIVSXT :	out std_logic_vector(7 downto 0);
	RDIV_TBB:	out std_logic_vector(7 downto 0);
	RDIV_TLOB:	out std_logic_vector(7 downto 0);
	RDIV_TPAD:	out std_logic_vector(7 downto 0);
	RDIV_TXBUF:	out std_logic_vector(7 downto 0);
	RDIV_VCOGN:	out std_logic_vector(7 downto 0);
	RDIV_VCOSXT:	out std_logic_vector(7 downto 0);
	SPDUP_LDO_CPGN:	out std_logic;
	SPDUP_LDO_CPSXT:	out std_logic;
	SPDUP_LDO_DIG:	out std_logic;
	SPDUP_LDO_DIGGN:	out std_logic;
	SPDUP_LDO_DIGSXT:	out std_logic;
	SPDUP_LDO_DIVGN:	out std_logic;
	SPDUP_LDO_DIVSXT:	out std_logic;
	SPDUP_LDO_TBB:	out std_logic;
	SPDUP_LDO_TLOB:	out std_logic;
	SPDUP_LDO_TPAD:	out std_logic;
	SPDUP_LDO_TXBUF:	out std_logic;
	SPDUP_LDO_VCOGN:	out std_logic;
	SPDUP_LDO_VCOSXT:	out std_logic;
	BYP_LDO_CPGN:	out std_logic;
	BYP_LDO_CPSXT:	out std_logic;
	BYP_LDO_DIG:	out std_logic;
	BYP_LDO_DIGGN:	out std_logic;
	BYP_LDO_DIGSXT:	out std_logic;
	BYP_LDO_DIVGN:	out std_logic;
	BYP_LDO_DIVSXT:	out std_logic;
	BYP_LDO_TBB:	out std_logic;
	BYP_LDO_TLOB:	out std_logic;
	BYP_LDO_TPAD:	out std_logic;
	BYP_LDO_TXBUF:	out std_logic;
	BYP_LDO_VCOGN:	out std_logic;
	BYP_LDO_VCOSXT:	out std_logic;
	EN_LOADIMP_LDO_CPGN:	out std_logic;
	EN_LOADIMP_LDO_CPSXT:	out std_logic;
	EN_LOADIMP_LDO_DIG:	out std_logic;
	EN_LOADIMP_LDO_DIGGN:	out std_logic;
	EN_LOADIMP_LDO_DIGSXT:	out std_logic;
	EN_LOADIMP_LDO_DIVGN:	out std_logic;
	EN_LOADIMP_LDO_DIVSXT:	out std_logic;
	EN_LOADIMP_LDO_TBB:	out std_logic;
	EN_LOADIMP_LDO_TLOB:	out std_logic;
	EN_LOADIMP_LDO_TPAD:	out std_logic;
	EN_LOADIMP_LDO_TXBUF:	out std_logic;
	EN_LOADIMP_LDO_VCOGN:	out std_logic;
	EN_LOADIMP_LDO_VCOSXT:	out std_logic;
	EN_LDO_CPGN:	out std_logic;
	EN_LDO_TLOB:	out std_logic;
	EN_LDO_TPAD:	out std_logic;
	EN_LDO_TXBUF:	out std_logic;
	EN_LDO_VCOGN:	out std_logic;
	EN_LDO_VCOSXT:	out std_logic;
	EN_LDO_CPSXT:	out std_logic;
	EN_LDO_DIG:	out std_logic;
	EN_LDO_DIGGN:	out std_logic;
	EN_LDO_DIGSXT:	out std_logic;
	EN_LDO_DIVGN:	out std_logic;
	EN_LDO_DIVSXT:	out std_logic;
	EN_LDO_TBB:	out std_logic;


	--============================= FROM ATRX CONFIGURATION, CNANNEL 1 =============================--
	-- TRF control lines
	LOBIASN_TXM_TRF_1:	out std_logic_vector(4 downto 0);
	LOBIASP_TXX_TRF_1:	out std_logic_vector(4 downto 0);
	--
	GCAS_GNDREF_TXPAD_TRF_1:	out std_logic;
	ICT_LIN_TXPAD_TRF_1:	out std_logic_vector(4 downto 0);
	ICT_MAIN_TXPAD_TRF_1:	out std_logic_vector(4 downto 0);
	VGCAS_TXPAD_TRF_1:	out std_logic_vector(4 downto 0);
	--
	SEL_BAND1_TRF_1:	out std_logic;
	SEL_BAND2_TRF_1:	out std_logic;
	F_TXPAD_TRF_1:	out std_logic_vector(2 downto 0);
	L_LOOPB_TXPAD_TRF_1:	out std_logic_vector(1 downto 0);
	LOSS_LIN_TXPAD_TRF_1:	out std_logic_vector(4 downto 0);
	LOSS_MAIN_TXPAD_TRF_1:	out std_logic_vector(4 downto 0);
	EN_LOOPB_TXPAD_TRF_1:	out std_logic;
	--
	EN_LOWBWLOMX_TMX_TRF_1:	out std_logic;
	EN_NEXTTX_TRF_1:	out std_logic;
	EN_AMPHF_PDET_TRF_1:	out std_logic_vector(1 downto 0);
	LOADR_PDET_TRF_1:	out std_logic_vector(1 downto 0);

	PD_PDET_TRF_1:	out std_logic;
	PD_TLOBUF_TRF_1:	out std_logic;
	PD_TXPAD_TRF_1:	out std_logic;


	-- TBB control lines
	RESRV_TBB_1:	out std_logic_vector(5 downto 0);
	--
	TSTIN_TBB_1:	out std_logic_vector(1 downto 0);
	BYPLADDER_TBB_1:	out std_logic;
	CCAL_LPFLAD_TBB_1:	out std_logic_vector(4 downto 0);
	RCAL_LPFS5_TBB_1:	out std_logic_vector(7 downto 0);
	--
	RCAL_LPFH_TBB_1:	out std_logic_vector(7 downto 0);
	RCAL_LPFLAD_TBB_1:	out std_logic_vector(7 downto 0);
	--
	CG_IAMP_TBB_1:	out std_logic_vector(5 downto 0);
	ICT_IAMP_FRP_TBB_1:	out std_logic_vector(4 downto 0);
	ICT_IAMP_GG_FRP_TBB_1:	out std_logic_vector(4 downto 0);
	--
	ICT_LPFH_F_TBB_1:	out std_logic_vector(4 downto 0);
	ICT_LPFLAD_F_TBB_1:	out std_logic_vector(4 downto 0);
	ICT_LPFLAD_PT_TBB_1:	out std_logic_vector(4 downto 0);
	--
	ICT_LPFS5_F_TBB_1:	out std_logic_vector(4 downto 0);
	ICT_LPFS5_PT_TBB_1:	out std_logic_vector(4 downto 0);
	ICT_LPF_H_PT_TBB_1:	out std_logic_vector(4 downto 0);
	--
	STATPULSE_TBB_1:	out std_logic;
	LOOPB_TBB_1:	out std_logic_vector(2 downto 0);
	PD_LPFH_TBB_1:	out std_logic;
	PD_LPFIAMP_TBB_1:	out std_logic;
	PD_LPFLAD_TBB_1:	out std_logic;
	PD_LPFS5_TBB_1:	out std_logic;
	PD_TBB_1:	out std_logic;


	-- RFE control lines

	RCOMP_TIA_RFE_1:	out std_logic_vector(3 downto 0);
	RFB_TIA_RFE_1:	out std_logic_vector(4 downto 0);
	--
	G_LNA_RFE_1:	out std_logic_vector(3 downto 0);
	G_RXLOOPB_RFE_1:	out std_logic_vector(3 downto 0);
	G_TIA_RFE_1:	out std_logic_vector(1 downto 0);
	--
	CAP_RXMXO_RFE_1:	out std_logic_vector(4 downto 0);
	CCOMP_TIA_RFE_1:	out std_logic_vector(3 downto 0);
	CFB_TIA_RFE_1:	out std_logic_vector(11 downto 0);
	CGSIN_LNA_RFE_1:	out std_logic_vector(4 downto 0);
	--
	ICT_LNACMO_RFE_1:	out std_logic_vector(4 downto 0);
	ICT_LNA_RFE_1:	out std_logic_vector(4 downto 0);
	ICT_LODC_RFE_1:	out std_logic_vector(4 downto 0);
	--
	ICT_LOOPB_RFE_1:	out std_logic_vector(4 downto 0);
	ICT_TIAMAIN_RFE_1:	out std_logic_vector(4 downto 0);
	ICT_TIAOUT_RFE_1:	out std_logic_vector(4 downto 0);
	--
	DCOFFI_RFE_1:	out std_logic_vector(6 downto 0);
	DCOFFQ_RFE_1:	out std_logic_vector(6 downto 0);
	--
	EN_DCOFF_RXFE_RFE_1:	out std_logic;
	EN_INSHSW_H_RFE_1:	out std_logic;
	EN_INSHSW_LB1_RFE_1:	out std_logic;
	EN_INSHSW_LB2_RFE_1:	out std_logic;
	EN_INSHSW_L_RFE_1:	out std_logic;
	EN_INSHSW_W_RFE_1:	out std_logic;
	EN_NEXTRX_RFE_1:	out std_logic;
	--
	PD_RLOOPB_1_RFE_1:	out std_logic;
	PD_RLOOPB_2_RFE_1:	out std_logic;
	PD_MXLOBUF_RFE_1:	out std_logic;
	PD_QGEN_RFE_1:	out std_logic;
	PD_RSSI_RFE_1:	out std_logic;
	PD_TIA_RFE_1:	out std_logic;

	-- RBB control lines 
	RESRV_RBB_1:	out std_logic_vector(6 downto 0);
	--
	INPUT_CTL_PGA_RBB_1:	out std_logic_vector(2 downto 0);
	RCC_CTL_PGA_RBB_1:	out std_logic_vector(4 downto 0);
	C_CTL_PGA_RBB_1:	out std_logic_vector(7 downto 0);
	--
	OSW_PGA_RBB_1:	out std_logic;
	ICT_PGA_OUT_RBB_1:	out std_logic_vector(4 downto 0);
	ICT_PGA_IN_RBB_1:	out std_logic_vector(4 downto 0);
	G_PGA_RBB_1:	out std_logic_vector(4 downto 0);
	--
	ICT_LPF_IN_RBB_1:	out std_logic_vector(4 downto 0);
	ICT_LPF_OUT_RBB_1:	out std_logic_vector(4 downto 0);
	--
	RCC_CTL_LPFL_RBB_1:	out std_logic_vector(2 downto 0);
	C_CTL_LPFL_RBB_1:	out std_logic_vector(10 downto 0);
	--
	R_CTL_LPF_RBB_1:	out std_logic_vector(4 downto 0);
	RCC_CTL_LPFH_RBB_1:	out std_logic_vector(2 downto 0);
	C_CTL_LPFH_RBB_1:	out std_logic_vector(7 downto 0);
	--
	EN_LB_LPFH_RBB_1:	out std_logic;
	EN_LB_LPFL_RBB_1:	out std_logic;
	PD_LPFH_RBB_1:	out std_logic;
	PD_LPFL_RBB_1:	out std_logic;
	PD_PGA_RBB_1:	out std_logic;

	-- SX control lines 
	RESRVE_SXR:	out std_logic_vector(4 downto 0);

	--
	VCO_CMPHO_SXR:		in std_logic;
	VCO_CMPLO_SXR:		in std_logic;
	COARSEPLL_COMPO_SXR:	in std_logic;
	COARSE_STEPDONE_SXR:	in std_logic;
	SDM_TSTO_SXR:	in std_logic_vector(13 downto 0);

	--
	CP2_PLL_SXR:	out std_logic_vector(3 downto 0);
	CP3_PLL_SXR:	out std_logic_vector(3 downto 0);
	CZ_SXR:	out std_logic_vector(3 downto 0);
	--
	REVPH_PFD_SXR:	out std_logic;
	IOFFSET_CP_SXR:	out std_logic_vector(5 downto 0);
	IPULSE_CP_SXR:	out std_logic_vector(5 downto 0);
	--
	RSEL_LDO_VCO_SXR:	out std_logic_vector(4 downto 0);
	CSW_VCO_SXR:	out std_logic_vector(7 downto 0);
	SEL_VCO_SXR:	out std_logic_vector(1 downto 0);
	COARSE_START_SXR:	out std_logic;
	--
	VDIV_VCO_SXR:	out std_logic_vector(7 downto 0);
	ICT_VCO_SXR:	out std_logic_vector(7 downto 0);
	--
	PW_DIV2_LOCH_SXR:	out std_logic_vector(2 downto 0);
	PW_DIV4_LOCH_SXR:	out std_logic_vector(2 downto 0);
	DIV_LOCH_SXR:	out std_logic_vector(2 downto 0);
	TST_SX_SXR:	out std_logic_vector(2 downto 0);
	SEL_SDMCLK_SXR:	out std_logic;
	SX_DITHER_EN_SXR:	out std_logic;
	REV_SDMCLK_SXR:	out std_logic;
	--
	INT_SDM_SXR:	out std_logic_vector(9 downto 0);
	FRAC_SDM_SXR:	out std_logic_vector(19 downto 0);
	--
	RESET_N_SXR:	out std_logic;
	SPDUP_VCO_SXR:	out std_logic;
	BYPLDO_VCO_SXR:	out std_logic;
	EN_COARSEPLL_SXR:	out std_logic;
	CURLIM_VCO_SXR:	out std_logic;
	EN_DIV2_DIVPROG_SXR:	out std_logic;
	EN_INTONLY_SDM_SXR:	out std_logic;
	EN_SDM_CLK_SXR:	out std_logic;
	EN_SDM_TSTO_SXR:	out std_logic;
	PD_CP_SXR:	out std_logic;
	PD_FDIV_SXR:	out std_logic;
	PD_SDM_SXR:	out std_logic;
	PD_VCO_COMP_SXR:	out std_logic;
	PD_VCO_SXR:	out std_logic;


	--============================= FROM ATRX CONFIGURATION, CNANNEL 2 =============================--
	-- TRF control lines
	LOBIASN_TXM_TRF_2:	out std_logic_vector(4 downto 0);
	LOBIASP_TXX_TRF_2:	out std_logic_vector(4 downto 0);
	--
	GCAS_GNDREF_TXPAD_TRF_2:	out std_logic;
	ICT_LIN_TXPAD_TRF_2:	out std_logic_vector(4 downto 0);
	ICT_MAIN_TXPAD_TRF_2:	out std_logic_vector(4 downto 0);
	VGCAS_TXPAD_TRF_2:	out std_logic_vector(4 downto 0);
	--
	SEL_BAND1_TRF_2:	out std_logic;
	SEL_BAND2_TRF_2:	out std_logic;
	F_TXPAD_TRF_2:	out std_logic_vector(2 downto 0);
	L_LOOPB_TXPAD_TRF_2:	out std_logic_vector(1 downto 0);
	LOSS_LIN_TXPAD_TRF_2:	out std_logic_vector(4 downto 0);
	LOSS_MAIN_TXPAD_TRF_2:	out std_logic_vector(4 downto 0);
	EN_LOOPB_TXPAD_TRF_2:	out std_logic;
	--
	EN_LOWBWLOMX_TMX_TRF_2:	out std_logic;
	EN_NEXTTX_TRF_2:	out std_logic;
	EN_AMPHF_PDET_TRF_2:	out std_logic_vector(1 downto 0);
	LOADR_PDET_TRF_2:	out std_logic_vector(1 downto 0);

	PD_PDET_TRF_2:	out std_logic;
	PD_TLOBUF_TRF_2:	out std_logic;
	PD_TXPAD_TRF_2:	out std_logic;


	-- TBB control lines
	RESRV_TBB_2:	out std_logic_vector(5 downto 0);
	--
	TSTIN_TBB_2:	out std_logic_vector(1 downto 0);
	BYPLADDER_TBB_2:	out std_logic;
	CCAL_LPFLAD_TBB_2:	out std_logic_vector(4 downto 0);
	RCAL_LPFS5_TBB_2:	out std_logic_vector(7 downto 0);
	--
	RCAL_LPFH_TBB_2:	out std_logic_vector(7 downto 0);
	RCAL_LPFLAD_TBB_2:	out std_logic_vector(7 downto 0);
	--
	CG_IAMP_TBB_2:	out std_logic_vector(5 downto 0);
	ICT_IAMP_FRP_TBB_2:	out std_logic_vector(4 downto 0);
	ICT_IAMP_GG_FRP_TBB_2:	out std_logic_vector(4 downto 0);
	--
	ICT_LPFH_F_TBB_2:	out std_logic_vector(4 downto 0);
	ICT_LPFLAD_F_TBB_2:	out std_logic_vector(4 downto 0);
	ICT_LPFLAD_PT_TBB_2:	out std_logic_vector(4 downto 0);
	--
	ICT_LPFS5_F_TBB_2:	out std_logic_vector(4 downto 0);
	ICT_LPFS5_PT_TBB_2:	out std_logic_vector(4 downto 0);
	ICT_LPF_H_PT_TBB_2:	out std_logic_vector(4 downto 0);
	--
	STATPULSE_TBB_2:	out std_logic;
	LOOPB_TBB_2:	out std_logic_vector(2 downto 0);
	PD_LPFH_TBB_2:	out std_logic;
	PD_LPFIAMP_TBB_2:	out std_logic;
	PD_LPFLAD_TBB_2:	out std_logic;
	PD_LPFS5_TBB_2:	out std_logic;
	PD_TBB_2:	out std_logic;


	-- RFE control lines
	RCOMP_TIA_RFE_2:	out std_logic_vector(3 downto 0);
	RFB_TIA_RFE_2:	out std_logic_vector(4 downto 0);
	--
	G_LNA_RFE_2:	out std_logic_vector(3 downto 0);
	G_RXLOOPB_RFE_2:	out std_logic_vector(3 downto 0);
	G_TIA_RFE_2:	out std_logic_vector(1 downto 0);
	--
	CAP_RXMXO_RFE_2:	out std_logic_vector(4 downto 0);
	CCOMP_TIA_RFE_2:	out std_logic_vector(3 downto 0);
	CFB_TIA_RFE_2:	out std_logic_vector(11 downto 0);
	CGSIN_LNA_RFE_2:	out std_logic_vector(4 downto 0);
	--
	ICT_LNACMO_RFE_2:	out std_logic_vector(4 downto 0);
	ICT_LNA_RFE_2:	out std_logic_vector(4 downto 0);
	ICT_LODC_RFE_2:	out std_logic_vector(4 downto 0);
	--
	ICT_LOOPB_RFE_2:	out std_logic_vector(4 downto 0);
	ICT_TIAMAIN_RFE_2:	out std_logic_vector(4 downto 0);
	ICT_TIAOUT_RFE_2:	out std_logic_vector(4 downto 0);
	--
	DCOFFI_RFE_2:	out std_logic_vector(6 downto 0);
	DCOFFQ_RFE_2:	out std_logic_vector(6 downto 0);
	--
	EN_DCOFF_RXFE_RFE_2:	out std_logic;
	EN_INSHSW_H_RFE_2:	out std_logic;
	EN_INSHSW_LB1_RFE_2:	out std_logic;
	EN_INSHSW_LB2_RFE_2:	out std_logic;
	EN_INSHSW_L_RFE_2:	out std_logic;
	EN_INSHSW_W_RFE_2:	out std_logic;
	EN_NEXTRX_RFE_2:	out std_logic;
	--
	PD_RLOOPB_1_RFE_2:	out std_logic;
	PD_RLOOPB_2_RFE_2:	out std_logic;
	PD_MXLOBUF_RFE_2:	out std_logic;
	PD_QGEN_RFE_2:	out std_logic;
	PD_RSSI_RFE_2:	out std_logic;
	PD_TIA_RFE_2:	out std_logic;

	-- RBB control lines 
	RESRV_RBB_2:	out std_logic_vector(6 downto 0);
	--
	INPUT_CTL_PGA_RBB_2:	out std_logic_vector(2 downto 0);
	RCC_CTL_PGA_RBB_2:	out std_logic_vector(4 downto 0);
	C_CTL_PGA_RBB_2:	out std_logic_vector(7 downto 0);
	--
	OSW_PGA_RBB_2:	out std_logic;
	ICT_PGA_OUT_RBB_2:	out std_logic_vector(4 downto 0);
	ICT_PGA_IN_RBB_2:	out std_logic_vector(4 downto 0);
	G_PGA_RBB_2:	out std_logic_vector(4 downto 0);
	--
	ICT_LPF_IN_RBB_2:	out std_logic_vector(4 downto 0);
	ICT_LPF_OUT_RBB_2:	out std_logic_vector(4 downto 0);
	--
	RCC_CTL_LPFL_RBB_2:	out std_logic_vector(2 downto 0);
	C_CTL_LPFL_RBB_2:	out std_logic_vector(10 downto 0);
	--
	R_CTL_LPF_RBB_2:	out std_logic_vector(4 downto 0);
	RCC_CTL_LPFH_RBB_2:	out std_logic_vector(2 downto 0);
	C_CTL_LPFH_RBB_2:	out std_logic_vector(7 downto 0);
	--
	EN_LB_LPFH_RBB_2:	out std_logic;
	EN_LB_LPFL_RBB_2:	out std_logic;
	PD_LPFH_RBB_2:	out std_logic;
	PD_LPFL_RBB_2:	out std_logic;
	PD_PGA_RBB_2:	out std_logic;

	-- SX control lines 
	RESRV_SXT:	out std_logic;
	VCO_CMPHO_SXT:		in std_logic;
	VCO_CMPLO_SXT:		in std_logic;
	COARSEPLL_COMPO_SXT:	in std_logic;
	COARSE_STEPDONE_SXT:	in std_logic;
	--SDM_TSTO_SXT:	in std_logic_vector(13 downto 0);
	--
	CP2_PLL_SXT:	out std_logic_vector(3 downto 0);
	CP3_PLL_SXT:	out std_logic_vector(3 downto 0);
	CZ_SXT:	out std_logic_vector(3 downto 0);
	--
	REVPH_PFD_SXT:	out std_logic;
	IOFFSET_CP_SXT:	out std_logic_vector(5 downto 0);
	IPULSE_CP_SXT:	out std_logic_vector(5 downto 0);
	--
	RSEL_LDO_VCO_SXT:	out std_logic_vector(4 downto 0);
	CSW_VCO_SXT:	out std_logic_vector(7 downto 0);
	SEL_VCO_SXT:	out std_logic_vector(1 downto 0);
	COARSE_START_SXT:	out std_logic;
	--
	VDIV_VCO_SXT:	out std_logic_vector(7 downto 0);
	ICT_VCO_SXT:	out std_logic_vector(7 downto 0);
	--
	PW_DIV2_LOCH_SXT:	out std_logic_vector(2 downto 0);
	PW_DIV4_LOCH_SXT:	out std_logic_vector(2 downto 0);
	DIV_LOCH_SXT:	out std_logic_vector(2 downto 0);
	TST_SX_SXT:	out std_logic_vector(2 downto 0);
	SEL_SDMCLK_SXT:	out std_logic;
	SX_DITHER_EN_SXT:	out std_logic;
	REV_SDMCLK_SXT:	out std_logic;
	--
	INT_SDM_SXT:	out std_logic_vector(9 downto 0);
	FRAC_SDM_SXT:	out std_logic_vector(19 downto 0);
	--
	RESET_N_SXT:	out std_logic;
	SPDUP_VCO_SXT:	out std_logic;
	BYPLDO_VCO_SXT:	out std_logic;
	EN_COARSEPLL_SXT:	out std_logic;
	CURLIM_VCO_SXT:	out std_logic;
	EN_DIV2_DIVPROG_SXT:	out std_logic;
	EN_INTONLY_SDM_SXT:	out std_logic;
	EN_SDM_CLK_SXT:	out std_logic;
	EN_SDM_TSTO_SXT:	out std_logic;
	PD_LOCH_T2RBUF:	out std_logic;
	PD_CP_SXT:	out std_logic;
	PD_FDIV_SXT:	out std_logic;
	PD_SDM_SXT:	out std_logic;
	PD_VCO_COMP_SXT:	out std_logic;
	PD_VCO_SXT:	out std_logic;
	
	-- aditional, instead resrv
	PD_FBDIV_SXR:	out std_logic; 
	PD_FBDIV_SXT:	out std_logic;

	CDC_I_RFE_1:	out std_logic_vector(3 downto 0);
	CDC_Q_RFE_1:	out std_logic_vector(3 downto 0);
	CDC_I_RFE_2:	out std_logic_vector(3 downto 0);
	CDC_Q_RFE_2:	out std_logic_vector(3 downto 0);

	CDC_I_TRF_1:	out std_logic_vector(3 downto 0);
	CDC_Q_TRF_1:	out std_logic_vector(3 downto 0);

	CDC_I_TRF_2:	out std_logic_vector(3 downto 0);
	CDC_Q_TRF_2:	out std_logic_vector(3 downto 0)

	);
end component;

-- ----------------------------------------------------------------------------
component acbufr
	port (
	------------------------------------------	
	-- connects to spi modulle
	
	BYP_LDO_AFE_i:	in std_logic;
	BYP_LDO_CPSXR_i:	in std_logic;
	BYP_LDO_DIGSXR_i:	in std_logic;
	BYP_LDO_DIVSXR_i:	in std_logic;
	BYP_LDO_LNA12_i:	in std_logic;
	BYP_LDO_LNA14_i:	in std_logic;
	BYP_LDO_MXRFE_i:	in std_logic;
	BYP_LDO_RBB_i:	in std_logic;
	BYP_LDO_RXBUF_i:	in std_logic;
	BYP_LDO_TIA12_i:	in std_logic;
	BYP_LDO_TIA14_i:	in std_logic;
	BYP_LDO_VCOSXR_i:	in std_logic;
	BYP_XBUF_RX_i:	in std_logic;
	CLKH_OV_CLKL_CLKGN_i:	in std_logic_vector(1 downto 0);
	COARSEPLL_COMPO_CGEN_o:	out std_logic;
	COARSE_START_CGEN_i:	in std_logic;
	COARSE_STEPDONE_CGEN_o:	out std_logic;
	CP2_CLKGEN_i:	in std_logic_vector(3 downto 0);
	CP3_CLKGEN_i:	in std_logic_vector(3 downto 0);
	CZ_CLKGEN_i:	in std_logic_vector(3 downto 0);
	CSW_VCO_CGEN_i:	in std_logic_vector(7 downto 0);
	DIV_OUTCH_CLKGEN_i:	in std_logic_vector(7 downto 0);
	EN_ADCCLKH_CLKGN_i:	in std_logic;
	EN_COARSE_CKLGEN_i:	in std_logic;
	EN_INTONLY_SDM_CGEN_i:	in std_logic;
	EN_LDO_AFE_i:	in std_logic;
	EN_LDO_CPSXR_i:	in std_logic;
	EN_LDO_DIGSXR_i:	in std_logic;
	EN_LDO_DIVSXR_i:	in std_logic;
	EN_LDO_LNA12_i:	in std_logic;
	EN_LDO_LNA14_i:	in std_logic;
	EN_LDO_MXRFE_i:	in std_logic;
	EN_LDO_RBB_i:	in std_logic;
	EN_LDO_RXBUF_i:	in std_logic;
	EN_LDO_TIA12_i:	in std_logic;
	EN_LDO_TIA14_i:	in std_logic;
	EN_LDO_VCOSXR_i:	in std_logic;
	EN_LOADIMP_LDO_AFE_i:	in std_logic;
	EN_LOADIMP_LDO_CPSXR_i:	in std_logic;
	EN_LOADIMP_LDO_DIGSXR_i:	in std_logic;
	EN_LOADIMP_LDO_DIVSXR_i:	in std_logic;
	EN_LOADIMP_LDO_LNA12_i:	in std_logic;
	EN_LOADIMP_LDO_LNA14_i:	in std_logic;
	EN_LOADIMP_LDO_MXRFE_i:	in std_logic;
	EN_LOADIMP_LDO_RBB_i:	in std_logic;
	EN_LOADIMP_LDO_RXBUF_i:	in std_logic;
	EN_LOADIMP_LDO_TIA12_i:	in std_logic;
	EN_LOADIMP_LDO_TIA14_i:	in std_logic;
	EN_LOADIMP_LDO_VCOSXR_i:	in std_logic;
	EN_SDM_CLK_CGEN_i:	in std_logic;
	EN_SDM_TSTO_CGEN_i:	in std_logic;
	EN_TBUFIN_XBUF_RX_i:	in std_logic;
	FRAC_SDM_CGEN_i:	in std_logic_vector(19 downto 0);
	ICT_VCO_CGEN_i:	in std_logic_vector(4 downto 0);
	INT_SDM_CGEN_i:	in std_logic_vector(9 downto 0);
	IOFFSET_CP_CGEN_i:	in std_logic_vector(5 downto 0);
	IPULSE_CP_CGEN_i:	in std_logic_vector(5 downto 0);
	ISEL_DAC_AFE_i:	in std_logic_vector(2 downto 0);
	MODE_INTERLEAVE_AFE_i:	in std_logic;
	PD_CP_CGEN_i:	in std_logic;
	PD_FDIV_FB_CGEN_i:	in std_logic;
	PD_FDIV_O_CGEN_i:	in std_logic;
	PD_LNA_RFE_1_i:	in std_logic;
	PD_LNA_RFE_2_i:	in std_logic;
	PD_RX_AFE1_i:	in std_logic;
	PD_RX_AFE2_i:	in std_logic;
	PD_SDM_CGEN_i:	in std_logic;
	PD_TX_AFE1_i:	in std_logic;
	PD_TX_AFE2_i:	in std_logic;
	PD_VCO_CGEN_i:	in std_logic;
	PD_VCO_COMP_CGEN_i:	in std_logic;
	PD_XBUF_RX_i:	in std_logic;
	RDIV_AFE_i:	in std_logic_vector(7 downto 0);
	RDIV_CPSXR_i:	in std_logic_vector(7 downto 0);
	RDIV_DIGSXR_i:	in std_logic_vector(7 downto 0);
	RDIV_DIVSXR_i:	in std_logic_vector(7 downto 0);
	RDIV_LNA12_i:	in std_logic_vector(7 downto 0);
	RDIV_LNA14_i:	in std_logic_vector(7 downto 0);
	RDIV_MXRFE_i:	in std_logic_vector(7 downto 0);
	RDIV_RBB_i:	in std_logic_vector(7 downto 0);
	RDIV_RXBUF_i:	in std_logic_vector(7 downto 0);
	RDIV_TIA12_i:	in std_logic_vector(7 downto 0);
	RDIV_TIA14_i:	in std_logic_vector(7 downto 0);
	RDIV_VCOSXR_i:	in std_logic_vector(7 downto 0);
	RESET_N_CGEN_i:	in std_logic;
	RESRV_CGN_i:	in std_logic_vector(3 downto 1);
	REVPH_PFD_CGEN_i:	in std_logic;
	REV_CLKADC_CGEN_i:	in std_logic;
	REV_CLKDAC_CGEN_i:	in std_logic;
	REV_SDMCLK_CGEN_i:	in std_logic;
	SDM_TSTO_CGEN_o:	out std_logic_vector(13 downto 0);	
	SEL_PATH_RFE_1_i:	in std_logic_vector(1 downto 0);
	SEL_PATH_RFE_2_i:	in std_logic_vector(1 downto 0);
	SEL_SDMCLK_CGEN_i:	in std_logic;
	SLFB_XBUF_RX_i:	in std_logic;
	SPDUP_LDO_AFE_i:	in std_logic;
	SPDUP_LDO_CPSXR_i:	in std_logic;
	SPDUP_LDO_DIGSXR_i:	in std_logic;
	SPDUP_LDO_DIVSXR_i:	in std_logic;
	SPDUP_LDO_LNA12_i:	in std_logic;
	SPDUP_LDO_LNA14_i:	in std_logic;
	SPDUP_LDO_MXRFE_i:	in std_logic;
	SPDUP_LDO_RBB_i:	in std_logic;
	SPDUP_LDO_RXBUF_i:	in std_logic;
	SPDUP_LDO_TIA12_i:	in std_logic;
	SPDUP_LDO_TIA14_i:	in std_logic;
	SPDUP_LDO_VCOSXR_i:	in std_logic;
	SPDUP_VCO_CGEN_i:	in std_logic;
	SX_DITHER_EN_CGEN_i:	in std_logic;
	TST_CLKGEN_i:	in std_logic_vector(2 downto 0);
	VCO_CMPHO_CGEN_o:	out  std_logic;
	VCO_CMPLO_CGEN_o:	out  std_logic;
	
	BYP_LDO_DIGIp1_i:	in std_logic;
	pd_LDO_DIGIp1_i:	in std_logic;
	EN_LOADIMP_LDO_DIGIp1_i:	in std_logic;
	RDIV_DIGIp1_i:	in std_logic_vector(7 downto 0);
	SPDUP_LDO_DIGIp1_i:	in std_logic;
	BYP_LDO_DIGIp2_i:	in std_logic;
	pd_LDO_DIGIp2_i:	in std_logic;
	EN_LOADIMP_LDO_DIGIp2_i:	in std_logic;
	RDIV_DIGIp2_i:	in std_logic_vector(7 downto 0);
	SPDUP_LDO_DIGIp2_i:	in std_logic;
	
	SDM_TSTO_SXT_o:	out std_logic_vector(13 downto 0);
	BYP_LDO_SPIBUF_i:	in std_logic;
	PD_LDO_SPIBUF_i:	in std_logic;
	EN_LOADIMP_LDO_SPIBUF_i:	in std_logic;
	RDIV_SPIBUF_i:	in std_logic_vector(7 downto 0);
	SPDUP_LDO_SPIBUF_i:	in std_logic;
	
	cdsn_txatsp_i   : in std_logic;
	cdsn_txbtsp_i   : in std_logic;
	cdsn_rxatsp_i   : in std_logic;
	cdsn_rxbtsp_i   : in std_logic;
	cdsn_txalml_i   : in std_logic;
	cdsn_txblml_i   : in std_logic;
	cdsn_rxalml_i   : in std_logic;
	cdsn_rxblml_i   : in std_logic;
	cdsn_mclk2_i    : in std_logic;
	cdsn_mclk1_i    : in std_logic;
	cds_txatsp_i    :	in std_logic_vector(3 downto 0);
	cds_txbtsp_i    :	in std_logic_vector(3 downto 0);
	cds_rxatsp_i    :	in std_logic_vector(3 downto 0);
	cds_rxbtsp_i    :	in std_logic_vector(3 downto 0);
	cds_txalml_i    :	in std_logic_vector(3 downto 0);
	cds_txblml_i    :	in std_logic_vector(3 downto 0);
	cds_rxalml_i    :	in std_logic_vector(3 downto 0);
	cds_rxblml_i    :	in std_logic_vector(3 downto 0);
	cds_mclk2_i    :	in std_logic_vector(3 downto 0);
	cds_mclk1_i    :	in std_logic_vector(3 downto 0);

	spare0_i:	in std_logic_vector(15 downto 0);
	spare1_i:	in std_logic_vector(15 downto 0);
	spare2_i:	in std_logic_vector(15 downto 0);
	spare3_i:	in std_logic_vector(15 downto 0);

	------------------------------------------
	-- connects to external modulles
	
	BYP_LDO_AFE:	out std_logic;
	BYP_LDO_CPSXR:	out std_logic;
	BYP_LDO_DIGSXR:	out std_logic;
	BYP_LDO_DIVSXR:	out std_logic;
	BYP_LDO_LNA12:	out std_logic;
	BYP_LDO_LNA14:	out std_logic;
	BYP_LDO_MXRFE:	out std_logic;
	BYP_LDO_RBB:	out std_logic;
	BYP_LDO_RXBUF:	out std_logic;
	BYP_LDO_TIA12:	out std_logic;
	BYP_LDO_TIA14:	out std_logic;
	BYP_LDO_VCOSXR:	out std_logic;
	BYP_XBUF_RX:	out std_logic;
	CLKH_OV_CLKL_CLKGN:	out std_logic_vector(1 downto 0);
	COARSEPLL_COMPO_CGEN:	in std_logic;
	COARSE_START_CGEN:	out std_logic;
	COARSE_STEPDONE_CGEN:	in std_logic;
	CP2_CLKGEN:	out std_logic_vector(3 downto 0);
	CP3_CLKGEN:	out std_logic_vector(3 downto 0);
	CZ_CLKGEN:	out std_logic_vector(3 downto 0);
	CSW_VCO_CGEN:	out std_logic_vector(7 downto 0);
	DIV_OUTCH_CLKGEN:	out std_logic_vector(7 downto 0);
	EN_ADCCLKH_CLKGN:	out std_logic;
	EN_COARSE_CKLGEN:	out std_logic;
	EN_INTONLY_SDM_CGEN:	out std_logic;
	EN_LDO_AFE:	out std_logic;
	EN_LDO_CPSXR:	out std_logic;
	EN_LDO_DIGSXR:	out std_logic;
	EN_LDO_DIVSXR:	out std_logic;
	EN_LDO_LNA12:	out std_logic;
	EN_LDO_LNA14:	out std_logic;
	EN_LDO_MXRFE:	out std_logic;
	EN_LDO_RBB:	out std_logic;
	EN_LDO_RXBUF:	out std_logic;
	EN_LDO_TIA12:	out std_logic;
	EN_LDO_TIA14:	out std_logic;
	EN_LDO_VCOSXR:	out std_logic;
	EN_LOADIMP_LDO_AFE:	out std_logic;
	EN_LOADIMP_LDO_CPSXR:	out std_logic;
	EN_LOADIMP_LDO_DIGSXR:	out std_logic;
	EN_LOADIMP_LDO_DIVSXR:	out std_logic;
	EN_LOADIMP_LDO_LNA12:	out std_logic;
	EN_LOADIMP_LDO_LNA14:	out std_logic;
	EN_LOADIMP_LDO_MXRFE:	out std_logic;
	EN_LOADIMP_LDO_RBB:	out std_logic;
	EN_LOADIMP_LDO_RXBUF:	out std_logic;
	EN_LOADIMP_LDO_TIA12:	out std_logic;
	EN_LOADIMP_LDO_TIA14:	out std_logic;
	EN_LOADIMP_LDO_VCOSXR:	out std_logic;
	EN_SDM_CLK_CGEN:	out std_logic;
	EN_SDM_TSTO_CGEN:	out std_logic;
	EN_TBUFIN_XBUF_RX:	out std_logic;
	FRAC_SDM_CGEN:	out std_logic_vector(19 downto 0);
	ICT_VCO_CGEN:	out std_logic_vector(4 downto 0);
	INT_SDM_CGEN:	out std_logic_vector(9 downto 0);
	IOFFSET_CP_CGEN:	out std_logic_vector(5 downto 0);
	IPULSE_CP_CGEN:	out std_logic_vector(5 downto 0);
	ISEL_DAC_AFE:	out std_logic_vector(2 downto 0);
	MODE_INTERLEAVE_AFE:	out std_logic;
	PD_CP_CGEN:	out std_logic;
	PD_FDIV_FB_CGEN:	out std_logic;
	PD_FDIV_O_CGEN:	out std_logic;
	PD_LNA_RFE_1	: out std_logic;
	PD_LNA_RFE_2	: out std_logic;
	PD_RX_AFE1:	out std_logic;
	PD_RX_AFE2:	out std_logic;
	PD_SDM_CGEN:	out std_logic;
	PD_TX_AFE1:	out std_logic;
	PD_TX_AFE2:	out std_logic;
	PD_VCO_CGEN:	out std_logic;
	PD_VCO_COMP_CGEN:	out std_logic;
	PD_XBUF_RX:	out std_logic;
	RDIV_AFE:	out std_logic_vector(7 downto 0);
	RDIV_CPSXR :	out std_logic_vector(7 downto 0);
	RDIV_DIGSXR :	out std_logic_vector(7 downto 0);
	RDIV_DIVSXR:	out std_logic_vector(7 downto 0);
	RDIV_LNA12:	out std_logic_vector(7 downto 0);
	RDIV_LNA14:	out std_logic_vector(7 downto 0);
	RDIV_MXRFE:	out std_logic_vector(7 downto 0);
	RDIV_RBB :	out std_logic_vector(7 downto 0);
	RDIV_RXBUF:	out std_logic_vector(7 downto 0);
	RDIV_TIA12:	out std_logic_vector(7 downto 0);
	RDIV_TIA14:	out std_logic_vector(7 downto 0);
	RDIV_VCOSXR:	out std_logic_vector(7 downto 0);
	RESET_N_CGEN:	out std_logic;
	RESRV_CGN:	out std_logic_vector(3 downto 1);
	REVPH_PFD_CGEN:	out std_logic;
	REV_CLKADC_CGEN: out std_logic;
	REV_CLKDAC_CGEN: out std_logic;
	REV_SDMCLK_CGEN:	out std_logic;
	SDM_TSTO_CGEN:	in std_logic_vector(13 downto 0);	
	SEL_PATH_RFE_1    : out std_logic_vector(1 downto 0);
	SEL_PATH_RFE_2    : out std_logic_vector(1 downto 0);
	SEL_SDMCLK_CGEN:	out std_logic;
	SLFB_XBUF_RX:	out std_logic;
	SPDUP_LDO_AFE:	out std_logic;
	SPDUP_LDO_CPSXR:	out std_logic;
	SPDUP_LDO_DIGSXR:	out std_logic;
	SPDUP_LDO_DIVSXR:	out std_logic;
	SPDUP_LDO_LNA12:	out std_logic;
	SPDUP_LDO_LNA14:	out std_logic;
	SPDUP_LDO_MXRFE:	out std_logic;
	SPDUP_LDO_RBB:	out std_logic;
	SPDUP_LDO_RXBUF:	out std_logic;
	SPDUP_LDO_TIA12:	out std_logic;
	SPDUP_LDO_TIA14:	out std_logic;
	SPDUP_LDO_VCOSXR:	out std_logic;
	SPDUP_VCO_CGEN:	out std_logic;
	SX_DITHER_EN_CGEN:	out std_logic;
	TST_CLKGEN:	out std_logic_vector(2 downto 0);
	VCO_CMPHO_CGEN:		in std_logic;
	VCO_CMPLO_CGEN:		in std_logic;
	
	BYP_LDO_DIGIp1:	out std_logic;
	pd_LDO_DIGIp1:	out std_logic;
	EN_LOADIMP_LDO_DIGIp1:	out std_logic;
	RDIV_DIGIp1:	out std_logic_vector(7 downto 0);
	SPDUP_LDO_DIGIp1:	out std_logic;
	BYP_LDO_DIGIp2:	out std_logic;
	pd_LDO_DIGIp2:	out std_logic;
	EN_LOADIMP_LDO_DIGIp2:	out std_logic;
	RDIV_DIGIp2:	out std_logic_vector(7 downto 0);
	SPDUP_LDO_DIGIp2:	out std_logic;
	
	SDM_TSTO_SXT:	in std_logic_vector(13 downto 0);
	BYP_LDO_SPIBUF:	out std_logic;
	PD_LDO_SPIBUF:	out std_logic;
	EN_LOADIMP_LDO_SPIBUF:	out std_logic;
	RDIV_SPIBUF:	out std_logic_vector(7 downto 0);
	SPDUP_LDO_SPIBUF:	out std_logic;
	
	cdsn_txatsp   : out std_logic;
	cdsn_txbtsp   : out std_logic;
	cdsn_rxatsp   : out std_logic;
	cdsn_rxbtsp   : out std_logic;
	cdsn_txalml   : out std_logic;
	cdsn_txblml   : out std_logic;
	cdsn_rxalml   : out std_logic;
	cdsn_rxblml   : out std_logic;
	cdsn_mclk2    : out std_logic;
	cdsn_mclk1    : out std_logic;
	cds_txatsp    :	out std_logic_vector(3 downto 0);
	cds_txbtsp    :	out std_logic_vector(3 downto 0);
	cds_rxatsp    :	out std_logic_vector(3 downto 0);
	cds_rxbtsp    :	out std_logic_vector(3 downto 0);
	cds_txalml    :	out std_logic_vector(3 downto 0);
	cds_txblml    :	out std_logic_vector(3 downto 0);
	cds_rxalml    :	out std_logic_vector(3 downto 0);
	cds_rxblml    :	out std_logic_vector(3 downto 0);
	cds_mclk2    :	out std_logic_vector(3 downto 0);
	cds_mclk1    :	out std_logic_vector(3 downto 0);

	spare0:	out std_logic_vector(15 downto 0);
	spare1:	out std_logic_vector(15 downto 0);
	spare2:	out std_logic_vector(15 downto 0);
	spare3:	out std_logic_vector(15 downto 0)

	);
end component;


-- ----------------------------------------------------------------------------
component txtspcfg 
	port (
		-- Address and location of this module
		-- Will be hard wired at the top level
		maddress: in std_logic_vector(9 downto 0);
		mimo_en: in std_logic;	-- MIMO enable, from TOP SPI
	
		-- Serial port IOs
		sdin: in std_logic; 	-- Data in
		sclk: in std_logic; 	-- Data clock
		sen: in std_logic;	-- Enable signal (active low)
		sdout: out std_logic; 	-- Data out
	
		-- Signals coming from the pins or top level serial interface
		lreset: in std_logic; 	-- Logic reset signal, resets logic cells only
		mreset: in std_logic; 	-- Memory reset signal, resets configuration memory only
		txen: in std_logic;	-- Power down all modules when txen=0
		
		oen: out std_logic;
		
		-- Control lines		
		en		: out std_logic;
		stateo: out std_logic_vector(5 downto 0);
		gcorri: out std_logic_vector(10 downto 0);
		gcorrq: out std_logic_vector(10 downto 0);
		iqcorr: out std_logic_vector(11 downto 0);
		dccorri: out std_logic_vector(7 downto 0);
		dccorrq: out std_logic_vector(7 downto 0);
		ovr: out std_logic_vector(2 downto 0);	--HBI interpolation ratio 
		gfir1l: out std_logic_vector(2 downto 0);		--Length of GPFIR1
		gfir1n: out std_logic_vector(7 downto 0);		--Clock division ratio of GPFIR1
		gfir2l: out std_logic_vector(2 downto 0);		--Length of GPFIR2
		gfir2n: out std_logic_vector(7 downto 0);		--Clock division ratio of GPFIR2
		gfir3l: out std_logic_vector(2 downto 0);		--Length of GPFIR3
		gfir3n: out std_logic_vector(7 downto 0);		--Clock division ratio of GPFIR3
		dc_reg: out std_logic_vector(15 downto 0);	--DC level to drive DACI
		insel: out std_logic;
		ph_byp: out std_logic;
		gc_byp: out std_logic;
		gfir1_byp: out std_logic;
		gfir2_byp: out std_logic;
		gfir3_byp: out std_logic;
		dc_byp: out std_logic;
		isinc_byp: out std_logic;
		cmix_sc: out std_logic;
		cmix_byp: out std_logic;
		cmix_gain: out std_logic_vector(1 downto 0);
		
		bstart: out std_logic;			-- BIST start flag
		bstate: in std_logic;				-- BIST state flag
		bsigi: in std_logic_vector(22 downto 0);	-- BIST signature, channel I
		bsigq: in std_logic_vector(22 downto 0); 	-- BIST signature, channel Q
		

		tsgfcw		:out std_logic_vector(8 downto 7);
		tsgdcldq	: out std_logic;
		tsgdcldi	: out std_logic;
		tsgswapiq	: out std_logic;
		tsgmode		: out std_logic;
		tsgfc			: out std_logic


	);
end component;

-- ----------------------------------------------------------------------------
component rxtspcfg 
	port (
		-- Address and location of this module
		-- These signals will be hard wired at the top level
		maddress: in std_logic_vector(9 downto 0);
		mimo_en: in std_logic;	-- MIMO enable, from TOP SPI
	
		-- Serial port A IOs
		sdin: in std_logic; 	-- Data in
		sclk: in std_logic; 	-- Data clock
		sen: in std_logic;	-- Enable signal (active low)
		sdout: out std_logic; 	-- Data out
	
		-- Signals coming from the pins or top level serial interface
		lreset: in std_logic; 	-- Logic reset signal, resets logic cells only
		mreset: in std_logic; 	-- Memory reset signal, resets configuration memory only
		rxen: in std_logic;	-- Power down all modules when rxen=0
		capd: in std_logic_vector(31 downto 0);	-- Captured data
		
		oen: out std_logic;
		
		en		: buffer std_logic;
		stateo: out std_logic_vector(5 downto 0);

		gcorri: out std_logic_vector(10 downto 0);
		gcorrq: out std_logic_vector(10 downto 0);
		iqcorr: out std_logic_vector(11 downto 0);
		dccorr_avg: out std_logic_vector(2 downto 0);
		ovr: out std_logic_vector(2 downto 0);	--HBD decimation ratio
		gfir1l: out std_logic_vector(2 downto 0);		--Length of GPFIR1
		gfir1n: out std_logic_vector(7 downto 0);		--Clock division ratio of GPFIR1
		gfir2l: out std_logic_vector(2 downto 0);		--Length of GPFIR2
		gfir2n: out std_logic_vector(7 downto 0);		--Clock division ratio of GPFIR2
		gfir3l: out std_logic_vector(2 downto 0);		--Length of GPFIR3
		gfir3n: out std_logic_vector(7 downto 0);		--Clock division ratio of GPFIR3
		insel: out std_logic;
		agc_k: out std_logic_vector(17 downto 0);
		agc_adesired: out std_logic_vector(11 downto 0);
		agc_avg: out std_logic_vector(11 downto 0);
		agc_mode: out std_logic_vector(1 downto 0);
		gc_byp: out std_logic;
		ph_byp: out std_logic;
		dc_byp: out std_logic;
		agc_byp: out std_logic;
		gfir1_byp: out std_logic;
		gfir2_byp: out std_logic;
		gfir3_byp: out std_logic;
		cmix_byp: out std_logic;
		cmix_sc: out std_logic;
		cmix_gain: out std_logic_vector(1 downto 0);

		bstart: out std_logic;			-- BIST start flag
		capture: out std_logic;
		capsel: out std_logic_vector(1 downto 0);
		
		tsgfcw		: out std_logic_vector(8 downto 7);
		tsgdcldq	: out std_logic;
		tsgdcldi	: out std_logic;
		tsgswapiq	: out std_logic;
		tsgmode		: out std_logic;
		tsgfc			:out std_logic;
		dc_reg: out std_logic_vector(15 downto 0)	--DC level to drive DAC

	);
end component;
	
end mcfg_components;


