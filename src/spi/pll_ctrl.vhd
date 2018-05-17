-- ----------------------------------------------------------------------------
-- FILE:          pll_ctrl.vhd
-- DESCRIPTION:   PLL control module
-- DATE:          3:32 PM Friday, May 11, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pllcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pll_ctrl is
   generic (
      N_PLL       : integer :=2
   );
  port (
      to_pllcfg         : out t_TO_PLLCFG;
      from_pllcfg       : in  t_FROM_PLLCFG;
         -- Status Inputs
      pllcfg_busy       : in  std_logic_vector(N_PLL-1 downto 0);
      pllcfg_done       : in  std_logic_vector(N_PLL-1 downto 0);	
         -- PLL Lock flags
      pll_lock          : in  std_logic_vector(N_PLL-1 downto 0);	
         -- PLL Configuratioin Related
      phcfg_mode        : out std_logic;
      phcfg_tst         : out std_logic;
      phcfg_start       : out std_logic_vector(N_PLL-1 downto 0); --
      pllcfg_start      : out std_logic_vector(N_PLL-1 downto 0); --
      pllrst_start      : out std_logic_vector(N_PLL-1 downto 0); --
      phcfg_updn        : out std_logic; --
      cnt_ind           : out std_logic_vector(4 downto 0); --
      cnt_phase         : out std_logic_vector(15 downto 0); --
      pllcfg_data       : out std_logic_vector(143 downto 0);
      auto_phcfg_done   : in  std_logic_vector(N_PLL-1 downto 0);
      auto_phcfg_err    : in  std_logic_vector(N_PLL-1 downto 0);
      auto_phcfg_smpls  : out std_logic_vector(15 downto 0);
      auto_phcfg_step   : out std_logic_vector(15 downto 0)
      
        );
end pll_ctrl;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pll_ctrl is
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
signal n_cnt			:  std_logic_vector(15 downto 0); -- 
signal m_cnt			:  std_logic_vector(15 downto 0); -- 
signal m_frac			:  std_logic_vector(31 downto 0); -- 
signal c0_cnt			:  std_logic_vector(15 downto 0); -- 
signal c1_cnt			:  std_logic_vector(15 downto 0); -- 
signal c2_cnt			:  std_logic_vector(15 downto 0); -- 
signal c3_cnt			:  std_logic_vector(15 downto 0); -- 
signal c4_cnt			:  std_logic_vector(15 downto 0); -- 


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

pllcfg_busy_vect(N_PLL-1 downto 0)     <= pllcfg_busy;
pllcfg_busy_vect(15 downto N_PLL)      <= (others=>'0');
   
pllcfg_done_vect(N_PLL-1 downto 0)     <= pllcfg_done;
pllcfg_done_vect(15 downto N_PLL)      <= (others=>'0');

auto_phcfg_done_vect(N_PLL-1 downto 0) <= auto_phcfg_done;
auto_phcfg_done_vect(15 downto N_PLL)  <= (others=>'0');

auto_phcfg_err_vect(N_PLL-1 downto 0)  <= auto_phcfg_err;
auto_phcfg_err_vect(15 downto N_PLL)   <= (others=>'0');

pll_lock_vect(N_PLL-1 downto 0)        <= pll_lock;
pll_lock_vect(15 downto N_PLL)         <= (others=>'0');

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


phcfg_start  <= phcfg_start_vect(N_PLL-1 downto 0);
pllcfg_start <= pllcfg_start_vect(N_PLL-1 downto 0);
pllrst_start <= pllrst_start_vect(N_PLL-1 downto 0);


to_pllcfg.pllcfg_busy   <= pllcfg_busy_bit;
to_pllcfg.pllcfg_done   <= pllcfg_done_bit;
to_pllcfg.phcfg_done    <= auto_phcfg_done_bit;
to_pllcfg.phcfg_error   <= auto_phcfg_err_bit;
to_pllcfg.pll_lock      <= pll_lock_vect;

phcfg_start_bit         <= from_pllcfg.phcfg_start;
pllcfg_start_bit        <= from_pllcfg.pllcfg_start;
pllrst_start_bit        <= from_pllcfg.pllrst_start;
phcfg_updn              <= from_pllcfg.phcfg_updn;
cnt_ind                 <= from_pllcfg.cnt_ind;
pll_ind                 <= from_pllcfg.pll_ind;
phcfg_mode              <= from_pllcfg.phcfg_mode;
phcfg_tst               <= from_pllcfg.phcfg_tst;
cnt_phase               <= from_pllcfg.cnt_phase;	 
chp_curr                <= from_pllcfg.chp_curr;
pllcfg_vcodiv           <= from_pllcfg.pllcfg_vcodiv;
pllcfg_lf_res           <= from_pllcfg.pllcfg_lf_res;
pllcfg_lf_cap           <=	from_pllcfg.pllcfg_lf_cap;
m_odddiv                <= from_pllcfg.m_odddiv;
m_byp                   <= from_pllcfg.m_byp;
n_odddiv                <= from_pllcfg.n_odddiv;
n_byp                   <= from_pllcfg.n_byp;
c0_odddiv               <= from_pllcfg.c0_odddiv;
c0_byp                  <= from_pllcfg.c0_byp;
c1_odddiv               <= from_pllcfg.c1_odddiv;
c1_byp                  <= from_pllcfg.c1_byp;
c2_odddiv               <= from_pllcfg.c2_odddiv;
c2_byp                  <= from_pllcfg.c2_byp;
c3_odddiv               <= from_pllcfg.c3_odddiv;
c3_byp                  <= from_pllcfg.c3_byp;
c4_odddiv               <= from_pllcfg.c4_odddiv;
c4_byp                  <= from_pllcfg.c4_byp;
n_cnt                   <= from_pllcfg.n_cnt;
m_cnt                   <= from_pllcfg.m_cnt;
c0_cnt                  <= from_pllcfg.c0_cnt;
c1_cnt                  <= from_pllcfg.c1_cnt;
c2_cnt                  <= from_pllcfg.c2_cnt;
c3_cnt                  <= from_pllcfg.c3_cnt;
c4_cnt                  <= from_pllcfg.c4_cnt;
auto_phcfg_smpls        <= from_pllcfg.auto_phcfg_smpls;
auto_phcfg_step         <= from_pllcfg.auto_phcfg_step;

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




