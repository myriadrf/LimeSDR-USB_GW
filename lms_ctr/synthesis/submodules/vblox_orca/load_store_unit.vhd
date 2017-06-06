library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library work;
use work.constants_pkg.all;


entity load_store_unit is
  generic (
    REGISTER_SIZE       : integer;
    SIGN_EXTENSION_SIZE : integer);

  port (
    clk            : in     std_logic;
    reset          : in     std_logic;
    valid          : in     std_logic;
    stall_to_lsu   : in     std_logic;
    rs1_data       : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    rs2_data       : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    instruction    : in     std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
    sign_extension : in     std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);
    stalled        : buffer std_logic;
    data_out       : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
    data_enable    : out    std_logic;
--memory-bus
    address        : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
    byte_en        : out    std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
    write_en       : buffer std_logic;
    read_en        : buffer std_logic;
    write_data     : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
    read_data      : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    ack            : in     std_logic);

end entity load_store_unit;

architecture rtl of load_store_unit is

  constant BYTE_SIZE  : std_logic_vector(2 downto 0) := "000";
  constant HALF_SIZE  : std_logic_vector(2 downto 0) := "001";
  constant WORD_SIZE  : std_logic_vector(2 downto 0) := "010";
  constant UBYTE_SIZE : std_logic_vector(2 downto 0) := "100";
  constant UHALF_SIZE : std_logic_vector(2 downto 0) := "101";

  constant STORE_INSTR : std_logic_vector(6 downto 0) := "0100011";
  constant LOAD_INSTR  : std_logic_vector(6 downto 0) := "0000011";

  alias base_address : std_logic_vector(REGISTER_SIZE-1 downto 0) is rs1_data;
  alias source_data  : std_logic_vector(REGISTER_SIZE-1 downto 0) is rs2_data;

  signal fun3         : std_logic_vector(2 downto 0);
  signal latched_fun3 : std_logic_vector(2 downto 0);
  signal opcode       : std_logic_vector(6 downto 0);
  signal imm          : std_logic_vector(11 downto 0);

  signal address_unaligned : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal alignment         : std_logic_vector(1 downto 0);

  signal w0 : std_logic_vector(7 downto 0);
  signal w1 : std_logic_vector(7 downto 0);
  signal w2 : std_logic_vector(7 downto 0);
  signal w3 : std_logic_vector(7 downto 0);

  --individual register byte
  signal r0           : std_logic_vector(7 downto 0);
  signal r1           : std_logic_vector(7 downto 0);
  signal r2           : std_logic_vector(7 downto 0);
  signal r3           : std_logic_vector(7 downto 0);
  signal fixed_data   : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal latched_data : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal expecting_r_ack : std_logic;
  signal expecting_w_ack : std_logic;
  signal expecting_ack   : std_logic;
  signal write_instr     : boolean;
  signal read_instr      : boolean;
begin

  --prepare memory signals
  opcode <= instruction(6 downto 0);
  fun3   <= instruction(14 downto 12);

  write_instr <= opcode = STORE_INSTR and valid = '1';
  read_instr  <= opcode = LOAD_INSTR and valid = '1';

  write_en <= valid when write_instr and stall_to_lsu = '0' else '0';
  read_en  <= valid when read_instr and stall_to_lsu = '0'  else '0';

  imm <= instruction(31 downto 25) & instruction(11 downto 7) when instruction(5) = '1'
         else instruction(31 downto 20);

  address_unaligned <= std_logic_vector(unsigned(sign_extension(REGISTER_SIZE-12-1 downto 0) &
                                                 imm)+unsigned(base_address));
  --set the byte enables correctly, (Remember little endian)
  byte_en <= "0001" when fun3 = BYTE_SIZE and address_unaligned(1 downto 0) = "00" else
             "0010" when fun3 = BYTE_SIZE and address_unaligned(1 downto 0) = "01" else
             "0100" when fun3 = BYTE_SIZE and address_unaligned(1 downto 0) = "10" else
             "1000" when fun3 = BYTE_SIZE and address_unaligned(1 downto 0) = "11" else
             "0011" when fun3 = HALF_SIZE and address_unaligned(1 downto 0) = "00" else
             "1100" when fun3 = HALF_SIZE and address_unaligned(1 downto 0) = "10" else
             "1111";

  --move bytes around to be placed at correct address

  w3 <= source_data(7 downto 0) when address_unaligned(1 downto 0) = "11" else
        source_data(15 downto 8) when address_unaligned(1 downto 0) = "10" else
        source_data(31 downto 24);
  w2 <= source_data(7 downto 0) when address_unaligned(1 downto 0) = "10" else
        source_data(23 downto 16);
  w1 <= source_data(7 downto 0) when address_unaligned(1 downto 0) = "01" else
        source_data(15 downto 8);
  w0 <= source_data(7 downto 0);


  --little endian
  write_data <= w3 & w2 & w1 & w0;
  --align to word boundary
  address    <= address_unaligned(REGISTER_SIZE-1 downto 2) & "00";

  stalled <= '1' when ((expecting_r_ack and not ack) = '1') or ((expecting_w_ack and not ack) = '1' and (read_instr or write_instr)) else '0';

  expecting_ack <= expecting_r_ack or expecting_w_ack;

  --outputs, all of these assignments should happen on the rising edge,
  -- they should only depend on latched signals
  latched_inputs : process(clk)
  begin
    if rising_edge(clk) then
      --expecting w ack
      if expecting_ack = '0' or ack = '1' then
        alignment    <= address_unaligned(1 downto 0);
        latched_fun3 <= fun3;
      end if;
      if expecting_r_ack = '1' and ack = '1' then
        expecting_r_ack <= '0';
      end if;
      if read_en = '1' then
        expecting_r_ack <= '1';
      end if;
      --expecting w ack
      if expecting_w_ack = '1' and ack = '1'  then
        expecting_w_ack <= '0';
      end if;
      if write_en = '1' then
        expecting_w_ack <= '1';
      end if;

      if reset = '1' then
        expecting_r_ack <= '0';
        expecting_w_ack <= '0';
      end if;
    end if;
  end process;

  --sort the read data into to correct byte in the register
  r3 <= read_data(31 downto 24);
  r2 <= read_data(23 downto 16);
  r1 <= read_data(15 downto 8) when alignment = "00" else
        read_data(31 downto 24);
  r0 <= read_data(7 downto 0) when alignment = "00" else
        read_data(15 downto 8)  when alignment = "01" else
        read_data(23 downto 16) when alignment = "10" else
        read_data(31 downto 24);

  --zero/sign extend the read data
  with latched_fun3 select
    fixed_data <=
    std_logic_vector(resize(signed(r0), REGISTER_SIZE))      when BYTE_SIZE,
    std_logic_vector(resize(signed(r1 & r0), REGISTER_SIZE)) when HALF_SIZE,
    x"000000"&r0                                             when UBYTE_SIZE,
    x"0000"&r1 & r0                                          when UHALF_SIZE,
    r3 &r2 & r1 & r0                                         when others;

  data_enable <= ack and expecting_r_ack;
  data_out    <= fixed_data;

end architecture;
