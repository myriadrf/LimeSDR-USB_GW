-- ----------------------------------------------------------------------------	
-- FILE: 	pllcfg_top.vhd
-- DESCRIPTION:	pllcfg_top
-- DATE:	Apr 05, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pllcfg_top is
	generic (n_pll	: integer :=2
	);
  port (
			--input ports 
		sdinA			: in std_logic; 	-- Data in
		sclkA			: in std_logic; 	-- Data clock
		senA			: in std_logic;	-- Enable signal (active low)
		sdoutA		: out std_logic; 	-- Data out
		oenA			: out std_logic;  -- NC		
			-- Serial port B IOs
		sdinB			: in std_logic; 	-- Data in
		sclkB			: in std_logic; 	-- Data clock
		senB			: in std_logic;	-- Enable signal (active low)
		sdoutB		: out std_logic; 	-- Data out
		oenB			: out std_logic;  -- NC		
			-- Signals coming from the pins or top level serial interface
		lreset		: in std_logic; 	-- Logic reset signal, resets logic cells only  (use only one reset)
		mreset		: in std_logic; 	-- Memory reset signal, resets configuration memory only (use only one reset)
			-- Status Inputs
		pllcfg_busy	: in std_logic_vector(n_pll-1 downto 0);
		pllcfg_done	: in std_logic_vector(n_pll-1 downto 0);	
			-- PLL Lock flags
		pll_lock		: in std_logic_vector(n_pll-1 downto 0);	
			-- PLL Configuratioin Related
      phcfg_mode  : out std_logic;
      phcfg_tst   : out std_logic;
		phcfg_start	: out std_logic_vector(n_pll-1 downto 0); --
		pllcfg_start: out std_logic_vector(n_pll-1 downto 0); --
		pllrst_start: out std_logic_vector(n_pll-1 downto 0); --
		phcfg_updn	: out std_logic; --
		cnt_ind		: out std_logic_vector(4 downto 0); --
		cnt_phase	: out std_logic_vector(15 downto 0); --
		pllcfg_data	: out std_logic_vector(143 downto 0);
      auto_phcfg_done   : in std_logic_vector(n_pll-1 downto 0);
      auto_phcfg_err    : in std_logic_vector(n_pll-1 downto 0);
      auto_phcfg_smpls  : out std_logic_vector(15 downto 0);
      auto_phcfg_step   : out std_logic_vector(15 downto 0)
        
        );
end pllcfg_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pllcfg_top is
--declare signals,  components here
signal pll_ind			: std_logic_vector(4 downto 0);
signal chp_curr 		: std_logic_vector(2 downto 0);
signal pllcfg_vcodiv	:  std_logic;
signal pllcfg_lf_res	:  std_logic_vector(4 downto 0); 
signal pllcfg_lf_cap	:  std_logic_vector(1 downto 0); 
signal m_odddiv		:  std_logic; --
signal m_byp			:  std_logic; --
signal n_odddiv		:  std_logic; --
signal n_byp			:  std_logic; --
signal c0_odddiv		:  std_logic; --
signal c0_byp			:  std_logic; --
signal c1_odddiv		:  std_logic; --
signal c1_byp			:  std_logic; --
signal c2_odddiv		:  std_logic; --
signal c2_byp			:  std_logic; --
signal c3_odddiv		:  std_logic; --
signal c3_byp			:  std_logic; --
signal c4_odddiv		:  std_logic; --
signal c4_byp			:  std_logic; --
--signal c5_odddiv		:  std_logic; --
--signal c5_byp			:  std_logic; --
--signal c6_odddiv		:  std_logic; --
--signal c6_byp			:  std_logic; --
--signal c7_odddiv		:  std_logic; --
--signal c7_byp			:  std_logic; --
--signal c8_odddiv		:  std_logic; --
--signal c8_byp			:  std_logic; --
--signal c9_odddiv		:  std_logic; --
--signal c9_byp			:  std_logic; --	
signal n_cnt			:  std_logic_vector(15 downto 0); -- 
signal m_cnt			:  std_logic_vector(15 downto 0); -- 
signal m_frac			:  std_logic_vector(31 downto 0); -- 
signal c0_cnt			:  std_logic_vector(15 downto 0); -- 
signal c1_cnt			:  std_logic_vector(15 downto 0); -- 
signal c2_cnt			:  std_logic_vector(15 downto 0); -- 
signal c3_cnt			:  std_logic_vector(15 downto 0); -- 
signal c4_cnt			:  std_logic_vector(15 downto 0); -- 
--signal c5_cnt			:  std_logic_vector(15 downto 0); -- 
--signal c6_cnt			:  std_logic_vector(15 downto 0); -- 
--signal c7_cnt			:  std_logic_vector(15 downto 0); -- 
--signal c8_cnt			:  std_logic_vector(15 downto 0); -- 
--signal c9_cnt			:  std_logic_vector(15 downto 0) -- 


signal pllcfg_busy_bit	: std_logic;
signal pllcfg_busy_vect	: std_logic_vector(15 downto 0);

signal pllcfg_done_bit	: std_logic;
signal pllcfg_done_vect	: std_logic_vector(15 downto 0);

signal auto_phcfg_done_bit	   : std_logic;
signal auto_phcfg_done_vect	: std_logic_vector(15 downto 0);

signal auto_phcfg_err_bit	   : std_logic;
signal auto_phcfg_err_vect	   : std_logic_vector(15 downto 0);

signal pll_lock_vect		: std_logic_vector(15 downto 0);

signal phcfg_start_vect	: std_logic_vector(15 downto 0);
signal pllcfg_start_vect: std_logic_vector(15 downto 0);
signal pllrst_start_vect: std_logic_vector(15 downto 0);

signal phcfg_start_bit	: std_logic;
signal pllcfg_start_bit	: std_logic;
signal pllrst_start_bit	: std_logic;

signal pllcfg_data_rev	: std_logic_vector(143 downto 0);

  
begin

pllcfg_busy_vect(n_pll-1 downto 0)<=pllcfg_busy;
pllcfg_busy_vect(15 downto n_pll)<=(others=>'0');

pllcfg_done_vect(n_pll-1 downto 0)<=pllcfg_done;
pllcfg_done_vect(15 downto n_pll)<=(others=>'0');

auto_phcfg_done_vect(n_pll-1 downto 0)<=auto_phcfg_done;
auto_phcfg_done_vect(15 downto n_pll)<=(others=>'0');

auto_phcfg_err_vect(n_pll-1 downto 0)<=auto_phcfg_err;
auto_phcfg_err_vect(15 downto n_pll)<=(others=>'0');

pll_lock_vect(n_pll-1 downto 0)<=pll_lock;
pll_lock_vect(15 downto n_pll)<=(others=>'0');

process(pll_ind, pllcfg_busy_vect, pllcfg_done_vect) begin
	pllcfg_busy_bit<=pllcfg_busy_vect(to_integer(unsigned(pll_ind)));
	pllcfg_done_bit<=pllcfg_done_vect(to_integer(unsigned(pll_ind)));
end process;

process(pll_ind, auto_phcfg_done_vect, auto_phcfg_err_vect) begin
	auto_phcfg_done_bit  <=auto_phcfg_done_vect(to_integer(unsigned(pll_ind)));
	auto_phcfg_err_bit   <=auto_phcfg_err_vect(to_integer(unsigned(pll_ind)));
end process;


process(pll_ind, phcfg_start_bit) begin
	phcfg_start_vect<=(others=>'0');
	phcfg_start_vect(to_integer(unsigned(pll_ind)))<=phcfg_start_bit;
end process;

process(pll_ind, pllcfg_start_bit) begin
	pllcfg_start_vect<=(others=>'0');
	pllcfg_start_vect(to_integer(unsigned(pll_ind)))<=pllcfg_start_bit;
end process;

process(pll_ind, pllrst_start_bit) begin
	pllrst_start_vect<=(others=>'0');
	pllrst_start_vect(to_integer(unsigned(pll_ind)))<=pllrst_start_bit;
end process;


phcfg_start  <= phcfg_start_vect(n_pll-1 downto 0);
pllcfg_start <= pllcfg_start_vect(n_pll-1 downto 0);
pllrst_start <= pllrst_start_vect(n_pll-1 downto 0);





pllcfg_inst	: entity work.pllcfg
port map (
		maddress			=> "0000000001",
		mimo_en			=> '1',
		sdinA				=> sdinA,
		sclkA				=> sclkA,
		senA				=> senA,
		sdoutA			=> sdoutA,
		oenA				=> oenA,
		sdinB				=> sdinB,
		sclkB				=> sclkB,
		senB				=> senB,
		sdoutB			=> sdoutB,
		oenB				=> oenB,
		lreset			=> lreset,
		mreset			=> mreset,
		pllcfg_busy 	=> pllcfg_busy_bit,
		pllcfg_done 	=> pllcfg_done_bit,
      phcfg_done     => auto_phcfg_done_bit,
      phcfg_error    => auto_phcfg_err_bit,
		pll_lock			=> pll_lock_vect,
		phcfg_start 	=> phcfg_start_bit,
		pllcfg_start 	=> pllcfg_start_bit,
		pllrst_start 	=> pllrst_start_bit,
		phcfg_updn 		=> phcfg_updn,
		cnt_ind			=> cnt_ind,
		pll_ind			=> pll_ind,
      phcfg_mode     => phcfg_mode,
      phcfg_tst      => phcfg_tst, 
		cnt_phase 		=> cnt_phase,		
--		pllcfg_bs		=> open, 
		chp_curr			=> chp_curr, 
		pllcfg_vcodiv	=> pllcfg_vcodiv,
		pllcfg_lf_res	=> pllcfg_lf_res,
		pllcfg_lf_cap	=> pllcfg_lf_cap,	
		m_odddiv			=> m_odddiv,
		m_byp				=> m_byp,
		n_odddiv			=> n_odddiv,
		n_byp				=> n_byp,
		c0_odddiv		=> c0_odddiv,
		c0_byp			=> c0_byp,
		c1_odddiv		=> c1_odddiv,
		c1_byp			=> c1_byp,
		c2_odddiv		=> c2_odddiv,
		c2_byp			=> c2_byp,
		c3_odddiv		=> c3_odddiv,
		c3_byp			=> c3_byp,
		c4_odddiv		=> c4_odddiv,
		c4_byp			=> c4_byp,
--		c5_odddiv		=> c5_odddiv,
--		c5_byp			=> c5_byp,
--		c6_odddiv		=> c6_odddiv,
--		c6_byp			=> c6_byp,
--		c7_odddiv		=> c7_odddiv,
--		c7_byp			=> c7_byp,
--		c8_odddiv		=> c8_odddiv,
--		c8_byp			=> c8_byp,
--		c9_odddiv		=> c9_odddiv,
--		c9_byp			=> c9_byp,	
		n_cnt				=> n_cnt,
		m_cnt				=> m_cnt,
--		m_frac			=> m_frac,
		c0_cnt			=> c0_cnt,
		c1_cnt			=> c1_cnt,
		c2_cnt			=> c2_cnt,
		c3_cnt			=> c3_cnt,
		c4_cnt			=> c4_cnt,
--		c5_cnt			=> c5_cnt, 
--		c6_cnt			=> c6_cnt, 
--		c7_cnt			=> c7_cnt,
--		c8_cnt			=> c8_cnt,
--		c9_cnt			=> c9_cnt,
      auto_phcfg_smpls  => auto_phcfg_smpls,
      auto_phcfg_step   => auto_phcfg_step 
);


pllcfg_data_rev<=		  "00" & pllcfg_lf_cap & pllcfg_lf_res  & pllcfg_vcodiv  & "00000" & chp_curr &
	                     n_byp 		& n_cnt (15  downto 8) & --N
                        n_odddiv 	& n_cnt (7 downto 0) &
                        
                        m_byp 		& m_cnt (15  downto 8) & --M 
                        m_odddiv 	& m_cnt (7 downto 0) &
                        
                        c0_byp 		& c0_cnt (15 downto 8) & --c0
                      	c0_odddiv 	& c0_cnt (7  downto 0) &
                      	 
                      	c1_byp 		& c1_cnt (15 downto 8) & --c1
                       	c1_odddiv 	& c1_cnt (7  downto 0) & 
                        
                        c2_byp 		& c2_cnt (15 downto 8) & --c2
                        c2_odddiv 	& c2_cnt (7  downto 0) &
                        
                        c3_byp 		& c3_cnt (15 downto 8) & --c3
                        c3_odddiv 	& c3_cnt (7  downto 0) &
  
                        c4_byp 		& c4_cnt (15 downto 8) & --c4
                        c4_odddiv 	& c4_cnt (7  downto 0) ;
								
								
for_lop : for i in 0 to 143 generate
   pllcfg_data(i) <= pllcfg_data_rev(143-i);  
end generate;								
  
end arch;




