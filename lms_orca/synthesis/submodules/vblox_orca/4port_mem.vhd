
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

library work;
use work.utils.all;

entity ram_4port is
  generic(
    MEM_DEPTH : natural;
    MEM_WIDTH : natural;
    FAMILY    : string := "ALTERA");
  port(
    clk            : in  std_logic;
    scratchpad_clk : in  std_logic;
    reset          : in  std_logic;
    stall_012      : out std_logic;
    stall_3        : out std_logic;
                                        --read source A
    raddr0         : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    ren0           : in  std_logic;
    data_out0      : out std_logic_vector(MEM_WIDTH-1 downto 0);
                                        --read source B
    raddr1         : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    ren1           : in  std_logic;
    data_out1      : out std_logic_vector(MEM_WIDTH-1 downto 0);
                                        --write dest
    waddr2         : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    byte_en2       : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
    wen2           : in  std_logic;
    data_in2       : in  std_logic_vector(MEM_WIDTH-1 downto 0);
                                        --external slave port
    rwaddr3        : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    wen3           : in  std_logic;
    ren3           : in  std_logic;     --cannot be asserted same cycle as wen3
    byte_en3       : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
    data_in3       : in  std_logic_vector(MEM_WIDTH-1 downto 0);
    data_out3      : out std_logic_vector(MEM_WIDTH-1 downto 0));
end entity;

architecture rtl of ram_4port is
begin  -- architecture rtl

end architecture rtl;
