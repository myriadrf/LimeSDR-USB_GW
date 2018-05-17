-- ----------------------------------------------------------------------------
-- FILE:          pllcfg_pkg.vhd
-- DESCRIPTION:   Package for fpgacfg module
-- DATE:          11:13 AM Friday, May 11, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Package declaration
-- ----------------------------------------------------------------------------
package pllcfg_pkg is
   
   -- Outputs from the 
   type t_FROM_PLLCFG is record
      -- PLL Configuratioin Related
      phcfg_start       : std_logic; --
      pllcfg_start      : std_logic; --
      pllrst_start      : std_logic; --
      phcfg_updn        : std_logic; --
      cnt_ind           : std_logic_vector(4 downto 0); --
      pll_ind           : std_logic_vector(4 downto 0); --
      phcfg_mode        : std_logic;
      phcfg_tst         : std_logic;
    
      cnt_phase         : std_logic_vector(15 downto 0); --
      --pllcfg_bs       : out std_logic_vector(3 downto 0); -- (for Cyclone V)
      chp_curr          : std_logic_vector(2 downto 0); --
      pllcfg_vcodiv     : std_logic; --
      pllcfg_lf_res     : std_logic_vector(4 downto 0); -- (for Cyclone IV)
      pllcfg_lf_cap     : std_logic_vector(1 downto 0); -- (for cyclone IV)
         
      m_odddiv          : std_logic; --
      m_byp             : std_logic; --
      n_odddiv          : std_logic; --
      n_byp             : std_logic; --
      
      c0_odddiv         : std_logic; --
      c0_byp            : std_logic; --
      c1_odddiv         : std_logic; --
      c1_byp            : std_logic; --
      c2_odddiv         : std_logic; --
      c2_byp            : std_logic; --
      c3_odddiv         : std_logic; --
      c3_byp            : std_logic; --
      c4_odddiv         : std_logic; --
      c4_byp            : std_logic; --
      --c5_odddiv       : std_logic; --
      --c5_byp          : std_logic; --
      --c6_odddiv       : std_logic; --
      --c6_byp          : std_logic; --
      --c7_odddiv       : std_logic; --
      --c7_byp          : std_logic; --
      --c8_odddiv       : std_logic; --
      --c8_byp          : std_logic; --
      --c9_odddiv       : std_logic; --
      --c9_byp          : std_logic; --
      n_cnt             : std_logic_vector(15 downto 0); -- 
      m_cnt             : std_logic_vector(15 downto 0); -- 
      --m_frac          : std_logic_vector(31 downto 0); -- 
      c0_cnt            : std_logic_vector(15 downto 0); -- 
      c1_cnt            : std_logic_vector(15 downto 0); -- 
      c2_cnt            : std_logic_vector(15 downto 0); -- 
      c3_cnt            : std_logic_vector(15 downto 0); -- 
      c4_cnt            : std_logic_vector(15 downto 0); -- 
      --c5_cnt          : std_logic_vector(15 downto 0); -- 
      --c6_cnt          : std_logic_vector(15 downto 0); -- 
      --c7_cnt          : std_logic_vector(15 downto 0); -- 
      --c8_cnt          : std_logic_vector(15 downto 0); -- 
      --c9_cnt          : std_logic_vector(15 downto 0) --
      auto_phcfg_smpls  : std_logic_vector(15 downto 0);
      auto_phcfg_step   : std_logic_vector(15 downto 0);
   end record t_FROM_PLLCFG;
  
   -- Inputs to the .
   type t_TO_PLLCFG is record
      -- Status Inputs
      pllcfg_busy    : std_logic;
      pllcfg_done    : std_logic;
      phcfg_done     : std_logic;
      phcfg_error    : std_logic;
      -- PLL Lock flags
      pll_lock       : std_logic_vector(15 downto 0);
   end record t_TO_PLLCFG;
   

      
end package pllcfg_pkg;