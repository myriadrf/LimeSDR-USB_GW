library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity clock_gen is
  generic(
    CLK_MHZ : integer := 1000);
  port(
    clk_out    : out std_logic;
    clk_out_2x : out std_logic;
    clk_out_3x : out std_logic);

end entity;

architecture rtl of clock_gen is
  signal clks : std_logic_vector(2 downto 0);
begin  -- architecture rtl

  process
  begin
    clks <= "111";
    wait for 2ns;
    clks <= "110";
    wait for 1ns;
    clks <= "100";
    wait for 1 ns;
    clks <= "101";
    wait for 2 ns;
    clks <= "010";
    wait for 2 ns;
    clks <= "011";
    wait for 1 ns;
    clks <= "001";
    wait for 1 ns;
    clks <= "000";
    wait for 2 ns;
  end process;
  clk_out    <= clks(2);
  clk_out_2x <= clks(1);
  clk_out_3x <= clks(0);

end architecture rtl;
