library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

library work;
use work.utils.all;
use work.constants_pkg.all;

entity lve_top is
  generic(
    REGISTER_SIZE    : natural;
    SLAVE_DATA_WIDTH : natural := 32;
    SCRATCHPAD_SIZE  : integer := 1024;
    FAMILY           : string  := "ALTERA");
  port(
    clk            : in std_logic;
    scratchpad_clk : in std_logic;
    reset          : in std_logic;
    instruction    : in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
    valid_instr    : in std_logic;
    stall_to_lve   : in std_logic;
    rs1_data       : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    rs2_data       : in std_logic_vector(REGISTER_SIZE-1 downto 0);

    slave_address  : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    slave_read_en  : in  std_logic;
    slave_write_en : in  std_logic;
    slave_byte_en  : in  std_logic_vector(SLAVE_DATA_WIDTH/8 -1 downto 0);
    slave_data_in  : in  std_logic_vector(SLAVE_DATA_WIDTH-1 downto 0);
    slave_data_out : out std_logic_vector(SLAVE_DATA_WIDTH-1 downto 0);
    slave_wait     : out std_logic;

    stall_from_lve   : out    std_logic;
    lve_data1        : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
    lve_data2        : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
    lve_source_valid : buffer std_logic;
    lve_result       : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    lve_result_valid : in     std_logic
    );
end entity;

architecture rtl of lve_top is

begin
  slave_data_out <= (others => '0');
  slave_wait     <= '0';

  stall_from_lve   <= '0';
  lve_data1        <= (others => '0');
  lve_data2        <= (others => '0');
  lve_source_valid <= '0';

end architecture;
