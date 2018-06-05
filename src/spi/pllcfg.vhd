-- ----------------------------------------------------------------------------
-- FILE:pllcfg.vhd
-- DESCRIPTION:Serial configuration interface to control FPGA PLLs
-- DATE:Mar 29, 20016
-- AUTHOR(s):Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;
use work.pllcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pllcfg is
   port (
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress       : in std_logic_vector(9 downto 0);
      mimo_en        : in std_logic; -- MIMO enable, from TOP SPI (always 1)
      
      -- Serial port A IOs
      sdinA          : in std_logic; -- Data in
      sclkA          : in std_logic; -- Data clock
      senA           : in std_logic; -- Enable signal (active low)
      sdoutA         : out std_logic; -- Data out
      
      oenA           : out std_logic; -- NC
      
      -- Serial port B IOs
      sdinB          : in std_logic; -- Data in
      sclkB          : in std_logic; -- Data clock
      senB           : in std_logic;-- Enable signal (active low)
      sdoutB         : out std_logic; -- Data out
      
      oenB           : out std_logic; -- NC
      
      -- Signals coming from the pins or top level serial interface
      lreset         : in std_logic; -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset         : in std_logic; -- Memory reset signal, resets configuration memory only (use only one reset)
      
      to_pllcfg      : in t_TO_PLLCFG;
      from_pllcfg    : out t_FROM_PLLCFG

);
end pllcfg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture pllcfg_arch of pllcfg is

signal inst_regA     : std_logic_vector(15 downto 0);-- Instruction register
signal inst_regA_en  : std_logic;

signal din_regA      : std_logic_vector(15 downto 0);-- Data in register
signal din_regA_en   : std_logic;

signal dout_regA     : std_logic_vector(15 downto 0);-- Data out register
signal dout_regA_sen, dout_regA_len: std_logic;

signal inst_regB     : std_logic_vector(15 downto 0);-- Instruction register
signal inst_regB_en  : std_logic;

signal din_regB      : std_logic_vector(15 downto 0);-- Data in register
signal din_regB_en   : std_logic;

signal dout_regB     : std_logic_vector(15 downto 0);-- Data out register
signal dout_regB_sen, dout_regB_len: std_logic;


signal mem: marray32x16;-- Config memory
signal mem_weA: std_logic;
signal mem_weB: std_logic;

signal oeA, oeB: std_logic;-- Tri state buffers control


-- Components
use work.mcfg_components.mcfg32wm_fsm;
for all: mcfg32wm_fsm use entity work.mcfg32wm_fsm(mcfg32wm_fsm_arch);

begin
-- ---------------------------------------------------------------------------------------------
-- Finite state machines
-- ---------------------------------------------------------------------------------------------
fsmA: mcfg32wm_fsm 
   port map( 
      address        => maddress, 
      mimo_en        => mimo_en, 
      inst_reg       => inst_regA, 
      sclk           => sclkA, 
      sen            => senA, 
      reset          => lreset, 
      inst_reg_en    => inst_regA_en, 
      din_reg_en     => din_regA_en, 
      dout_reg_sen   => dout_regA_sen, 
      dout_reg_len   => dout_regA_len, 
      mem_we         => mem_weA, 
      oe             => oeA, 
      stateo         => open
      );

fsmB: mcfg32wm_fsm 
   port map( 
      address        => maddress, 
      mimo_en        => mimo_en, 
      inst_reg       => inst_regB, 
      sclk           => sclkB, 
      sen            => senB, 
      reset          => lreset,
      inst_reg_en    => inst_regB_en, 
      din_reg_en     => din_regB_en, 
      dout_reg_sen   => dout_regB_sen,
      dout_reg_len   => dout_regB_len, 
      mem_we         => mem_weB, 
      oe             => oeB, 
      stateo         => open
   );

-- ---------------------------------------------------------------------------------------------
-- Instruction registers
-- ---------------------------------------------------------------------------------------------
inst_reg_procA: process(sclkA, lreset)
   variable i: integer;
begin
   if lreset = '0' then
      inst_regA <= (others => '0');
   elsif sclkA'event and sclkA = '1' then
      if inst_regA_en = '1' then
         for i in 15 downto 1 loop
            inst_regA(i) <= inst_regA(i-1);
         end loop;
         inst_regA(0) <= sdinA;
      end if;
   end if;
end process inst_reg_procA;

inst_reg_procB: process(sclkB, lreset)
   variable i: integer;
begin
   if lreset = '0' then
      inst_regB <= (others => '0');
   elsif sclkB'event and sclkB = '1' then
      if inst_regB_en = '1' then
         for i in 15 downto 1 loop
            inst_regB(i) <= inst_regB(i-1);
         end loop;
         inst_regB(0) <= sdinB;
      end if;
   end if;
end process inst_reg_procB;


-- ---------------------------------------------------------------------------------------------
-- Data input registers
-- ---------------------------------------------------------------------------------------------
din_reg_procA: process(sclkA, lreset)
   variable i: integer;
begin
   if lreset = '0' then
      din_regA <= (others => '0');
   elsif sclkA'event and sclkA = '1' then
      if din_regA_en = '1' then
         for i in 15 downto 1 loop
            din_regA(i) <= din_regA(i-1);
         end loop;
         din_regA(0) <= sdinA;
      end if;
   end if;
end process din_reg_procA;

din_reg_procB: process(sclkB, lreset)
   variable i: integer;
begin
   if lreset = '0' then
      din_regB <= (others => '0');
   elsif sclkB'event and sclkB = '1' then
      if din_regB_en = '1' then
         for i in 15 downto 1 loop
            din_regB(i) <= din_regB(i-1);
         end loop;
         din_regB(0) <= sdinB;
      end if;
   end if;
end process din_reg_procB;

-- ---------------------------------------------------------------------------------------------
-- Data output registers
-- ---------------------------------------------------------------------------------------------
dout_reg_procA: process(sclkA, lreset)
   variable i: integer;
begin
   if lreset = '0' then
      dout_regA <= (others => '0');
   elsif sclkA'event and sclkA = '0' then
      -- Shift operation
      if dout_regA_sen = '1' then
         for i in 15 downto 1 loop
            dout_regA(i) <= dout_regA(i-1);
         end loop;
      dout_regA(0) <= dout_regA(15);
      -- Load operation
      elsif dout_regA_len = '1' then
         dout_regA <= mem(to_integer(unsigned(inst_regA(4 downto 0))));
      end if;      
   end if;
end process dout_reg_procA;

-- Tri state buffer to connect multiple serial interfaces in parallel
--sdout <= dout_reg(7) when oe = '1' else 'Z';

--sdout <= dout_reg(7);
--oen <= oe;

sdoutA   <= dout_regA(15) and oeA;
oenA     <= oeA;


dout_reg_procB: process(sclkB, lreset)
   variable i: integer;
begin
   if lreset = '0' then
      dout_regB <= (others => '0');
   elsif sclkB'event and sclkB = '0' then
      -- Shift operation
      if dout_regB_sen = '1' then
         for i in 15 downto 1 loop
            dout_regB(i) <= dout_regB(i-1);
         end loop;
         dout_regB(0) <= dout_regB(15);
      -- Load operation
      elsif dout_regB_len = '1' then
         dout_regB <= mem(to_integer(unsigned(inst_regB(4 downto 0))));
      end if;      
   end if;
end process dout_reg_procB;

sdoutB   <= dout_regB(15) and oeB;
oenB     <= oeB;

-- ---------------------------------------------------------------------------------------------
-- Configuration memory
-- --------------------------------------------------------------------------------------------- 
ram: process(sclkA, mreset)
begin
-- Defaults
   if mreset = '0' then

      mem(0)   <= "0000000000000000"; -- 16 free, RESERVED[15:0]
      mem(1)   <= "0000000000000001"; -- 14 free, UNUSED[11:0], PHCFG_ERROR, PHCFG_DONE, BUSY (Read Only), DONE (Read Only)
      mem(2)   <= "0000000000000000"; -- 0  free, PLL_LOCK[15:0] (Read Only)
      mem(3)   <= "0000000000000000"; -- 2  free, UNUSED, PHCFG_MODE, PHCFG_UpDn, CNT_IND[4:0], PLL_IND[4:0], PLLRST_START, PHCFG_START, PLLCFG_START
      mem(4)   <= "0000000000000000"; -- 0  free, CNT_PHASE[15:0]
      mem(5)   <= "0000000111110000"; -- 1  free, UNUSED, PLLCFG_BS[3:0] (for Cyclone V), CHP_CURR[2:0], PLLCFG_VCODIV, PLLCFG_LF_RES[4:0] (for Cyclone IV), PLLCFG_LF_CAP[1:0] (for Cyclone IV)
      mem(6)   <= "0000000000001010"; -- 12 free, M_ODDDIV, M_BYP, N_ODDDIV, N_BYP
      mem(7)   <= "1010101010101010"; -- 0  free,  C7_ODDDIV,  C7_BYP,  C6_ODDDIV,  C6_BYP,  C5_ODDDIV,  C5_BYP,  C4_ODDDIV,  C4_BYP,  C3_ODDDIV,  C3_BYP,  C2_ODDDIV,  C2_BYP, C1_ODDDIV, C1_BYP, C0_ODDDIV, C0_BYP
      mem(8)   <= "1010101010101010"; -- 0  free, C15_ODDDIV, C15_BYP, C14_ODDDIV, C14_BYP, C13_ODDDIV, C13_BYP, C12_ODDDIV, C12_BYP, C11_ODDDIV, C11_BYP, C10_ODDDIV, C10_BYP, C9_ODDDIV, C9_BYP, C8_ODDDIV, C8_BYP
      mem(9)   <= "1010101010101010"; -- 0  free, RESERVED_FOR_C_COUNTER_ODDIV_AND_BYP
      mem(10)  <= "0000000000000000"; -- 0  free, N_HCNT[15:8], N_LCNT[7:0]
      mem(11)  <= "0000000000000000"; -- 0  free, M_HCNT[15:8], M_LCNT[7:0]
      mem(12)  <= "0000000000000000"; -- 0  free, M_FRAC[15:0]
      mem(13)  <= "0000000000000000"; -- 0  free, M_FRAC[31:16]
      mem(14)  <= "0000000000000000"; -- 0  free, C0_HCNT[15:8], C0_LCNT[7:0]
      mem(15)  <= "0000000000000000"; -- 0  free, C1_HCNT[15:8], C1_LCNT[7:0]
      mem(16)  <= "0000000000000000"; -- 0  free, C2_HCNT[15:8], C2_LCNT[7:0]
      mem(17)  <= "0000000000000000"; -- 0  free, C3_HCNT[15:8], C3_LCNT[7:0]
      mem(18)  <= "0000000000000000"; -- 0  free, C4_HCNT[15:8], C4_LCNT[7:0]
      mem(19)  <= "0000000000000000"; -- 0  free, C5_HCNT[15:8], C5_LCNT[7:0]
      mem(20)  <= "0000000000000000"; -- 0  free, C6_HCNT[15:8], C6_LCNT[7:0]
      mem(21)  <= "0000000000000000"; -- 0  free, C7_HCNT[15:8], C7_LCNT[7:0]
      mem(22)  <= "0000000000000000"; -- 0  free, C8_HCNT[15:8], C8_LCNT[7:0]
      mem(23)  <= "0000000000000000"; -- 0  free, C9_HCNT[15:8], C9_LCNT[7:0]
      --mem(24)-mem(29) reserved for C10-C15 counters
      mem(30)  <= "0000111111111111"; -- 0  free, auto_phcfg_smpls[15:0]
      mem(31)  <= "0000000000000010"; -- 0  free, auto_phcfg_step
      
         
   elsif sclkA'event and sclkA = '1' then
      if mem_weA = '1' then
         mem(to_integer(unsigned(inst_regA(4 downto 0)))) <= din_regA(14 downto 0) & sdinA;
      end if;

      -- Capture read-only values from the pins
      if dout_regA_len = '0' then
         for_lop : for i in 4 to 15 loop
            mem(1)(i) <= '0';  
         end loop;
         mem(1)(3 downto 0)<= to_pllcfg.phcfg_error & to_pllcfg.phcfg_done & to_pllcfg.pllcfg_busy & to_pllcfg.pllcfg_done;
         mem(2)  <= to_pllcfg.pll_lock;
      end if;
   end if;
end process ram;

-- ---------------------------------------------------------------------------------------------
-- Decoding logic, output assignments
-- ---------------------------------------------------------------------------------------------
from_pllcfg.phcfg_tst         <= mem(3)(15);   
from_pllcfg.phcfg_mode        <= mem(3)(14);
from_pllcfg.phcfg_updn        <= mem(3)(13);
from_pllcfg.cnt_ind           <= mem(3)(12 downto 8);
from_pllcfg.pll_ind           <= mem(3)(7 downto 3);
from_pllcfg.pllrst_start      <= mem(3)(2);
from_pllcfg.phcfg_start       <= mem(3)(1);
from_pllcfg.pllcfg_start      <= mem(3)(0);
   
from_pllcfg.cnt_phase         <= mem(4);
-- 
--from_pllcfg.pllcfg_bs       <= mem(5)(14 downto 11);
from_pllcfg.chp_curr          <= mem(5)(10 downto 8);
from_pllcfg.pllcfg_vcodiv     <= mem(5)(7);
from_pllcfg.pllcfg_lf_res     <= mem(5)(6 downto 2);
from_pllcfg.pllcfg_lf_cap     <= mem(5)(1 downto 0);
-- 
from_pllcfg.m_odddiv          <= mem(6)(3);
from_pllcfg.m_byp             <= mem(6)(2);
from_pllcfg.n_odddiv          <= mem(6)(1);
from_pllcfg.n_byp             <= mem(6)(0);


from_pllcfg.c0_byp            <= mem(7)(0);
from_pllcfg.c0_odddiv         <= mem(7)(1);
from_pllcfg.c1_byp            <= mem(7)(2);
from_pllcfg.c1_odddiv         <= mem(7)(3);
from_pllcfg.c2_byp            <= mem(7)(4);
from_pllcfg.c2_odddiv         <= mem(7)(5);
from_pllcfg.c3_byp            <= mem(7)(6);
from_pllcfg.c3_odddiv         <= mem(7)(7);
from_pllcfg.c4_byp            <= mem(7)(8);
from_pllcfg.c4_odddiv         <= mem(7)(9);
--from_pllcfg.c5_byp          <= mem(7)(10);
--from_pllcfg.c5_odddiv       <= mem(7)(11);
--from_pllcfg.c6_byp          <= mem(7)(12);
--from_pllcfg.c6_odddiv       <= mem(7)(13);
--from_pllcfg.c7_byp          <= mem(7)(14);
--from_pllcfg.c7_odddiv       <= mem(7)(15);
--from_pllcfg.c8_byp          <= mem(8)(0);
--from_pllcfg.c8_odddiv       <= mem(8)(1);
--from_pllcfg.c9_byp          <= mem(8)(2);
--from_pllcfg.c9_odddiv       <= mem(8)(3);
--
from_pllcfg.n_cnt             <= mem(10);
from_pllcfg.m_cnt             <= mem(11);
--from_pllcfg.m_frac          <= mem(13) & mem(12);
from_pllcfg.c0_cnt            <= mem(14); 
from_pllcfg.c1_cnt            <= mem(15); 
from_pllcfg.c2_cnt            <= mem(16);
from_pllcfg.c3_cnt            <= mem(17);
from_pllcfg.c4_cnt            <= mem(18);
--from_pllcfg.c5_cnt          <= mem(19);
--from_pllcfg.c6_cnt          <= mem(20);
--from_pllcfg.c7_cnt          <= mem(21);
--from_pllcfg.c8_cnt          <= mem(22);
--from_pllcfg.c9_cnt          <= mem(23);

from_pllcfg.auto_phcfg_smpls  <= mem(30);
from_pllcfg.auto_phcfg_step   <= mem(31);


end pllcfg_arch;
