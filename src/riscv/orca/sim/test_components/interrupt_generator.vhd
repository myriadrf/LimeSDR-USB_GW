
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity interrupt_generator is
  port (
    -- inputs:
    signal address     : in  std_logic_vector (1 downto 0);
    signal chipselect  : in  std_logic;
    signal clk         : in  std_logic;
    signal reset       : in  std_logic;
    signal write       : in  std_logic;
    signal writedata   : in  std_logic_vector (31 downto 0);
    signal waitrequest : out std_logic;

    -- outputs:
    signal int_out : out std_logic);
end entity interrupt_generator;


architecture rtl of interrupt_generator is
  signal time_to_int : unsigned(writedata'range);
begin
  waitrequest <= '0';
  process(clk)
  begin
    if rising_edge(clk) then

      if time_to_int /= 0 then
        time_to_int <= time_to_int -1;
      end if;
      if write = '1' and chipselect = '1' then
        time_to_int <= unsigned(writedata);
      end if;
      if reset = '1' then
        time_to_int <= (others => '1');
      end if;
    end if;
  end process;

  int_out <= '1' when time_to_int = 0 else '0';

end rtl;
