library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.rv_components.all;
use work.constants_pkg.all;
entity decode is
  generic(
    REGISTER_SIZE       : positive;
    SIGN_EXTENSION_SIZE : positive;
    PIPELINE_STAGES     : natural range 1 to 2);
  port(
    clk   : in std_logic;
    reset : in std_logic;
    stall : in std_logic;

    flush       : in std_logic;
    instruction : in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
    valid_input : in std_logic;
    --writeback signals
    wb_sel      : in std_logic_vector(REGISTER_NAME_SIZE -1 downto 0);
    wb_data     : in std_logic_vector(REGISTER_SIZE -1 downto 0);
    wb_enable   : in std_logic;
    wb_valid    : in std_logic;

    --output signals
    rs1_data       : out    std_logic_vector(REGISTER_SIZE -1 downto 0);
    rs2_data       : out    std_logic_vector(REGISTER_SIZE -1 downto 0);
    sign_extension : out    std_logic_vector(SIGN_EXTENSION_SIZE -1 downto 0);
    --inputs just for carrying to next pipeline stage
    br_taken_in    : in     std_logic;
    pc_curr_in     : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    br_taken_out   : out    std_logic;
    pc_curr_out    : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
    instr_out      : buffer std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
    subseq_instr   : out    std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
    subseq_valid   : out    std_logic;
    valid_output   : out    std_logic;
    decode_flushed : out    std_logic);
end;

architecture rtl of decode is
  signal rs1   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
  signal rs2   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
  signal rs1_p : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
  signal rs2_p : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);

  signal rs1_reg : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal outreg1 : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal rs2_reg : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal outreg2 : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal br_taken_latch : std_logic;
  signal pc_next_latch  : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal pc_curr_latch  : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal instr_latch    : std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
  signal valid_latch    : std_logic;


  signal i_rd  : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
  signal i_rs1 : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
  signal i_rs2 : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);

  signal il_rd     : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
  signal il_rs1    : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
  signal il_rs2    : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
  signal il_opcode : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
begin

  register_file_1 : component register_file
    generic map (
      REGISTER_SIZE      => REGISTER_SIZE,
      REGISTER_NAME_SIZE => REGISTER_NAME_SIZE)
    port map(
      clk         => clk,
      valid_input => valid_input,
      rs1_sel     => rs1,
      rs2_sel     => rs2,
      wb_sel      => wb_sel,
      wb_data     => wb_data,
      wb_enable   => wb_enable,
      wb_valid    => wb_valid,
      rs1_data    => rs1_reg,
      rs2_data    => rs2_reg
      );
  two_cycle : if PIPELINE_STAGES = 2 generate
    rs1 <= instruction(REGISTER_RS1'range) when stall = '0' else instr_latch(REGISTER_RS1'range);
    rs2 <= instruction(REGISTER_RS2'range) when stall = '0' else instr_latch(REGISTER_RS2'range);

    rs1_p <= instr_latch(REGISTER_RS1'range) when stall = '0' else instr_out(REGISTER_RS1'range);
    rs2_p <= instr_latch(REGISTER_RS2'range) when stall = '0' else instr_out(REGISTER_RS2'range);

    decode_flushed <= not (valid_input or valid_latch);

    decode_stage : process (clk, reset) is
    begin  -- process decode_stage
      if rising_edge(clk) then          -- rising clock edge
        if not stall = '1' then
          sign_extension <= std_logic_vector(
            resize(signed(instr_latch(INSTRUCTION_SIZE-1 downto INSTRUCTION_SIZE-1)),
                   SIGN_EXTENSION_SIZE));
          br_taken_latch <= br_taken_in;
          PC_curr_latch  <= PC_curr_in;
          instr_latch    <= instruction;
          valid_latch    <= valid_input;

          br_taken_out <= br_taken_latch;
          pc_curr_out  <= PC_curr_latch;
          instr_out    <= instr_latch;
          valid_output <= valid_latch;

        end if;

        if wb_sel = rs1_p and wb_enable = '1' and wb_valid = '1' then
          outreg1 <= wb_data;
        elsif stall = '0' then
          outreg1 <= rs1_reg;
        end if;
        if wb_sel = rs2_p and wb_enable = '1' and wb_valid = '1' then
          outreg2 <= wb_data;
        elsif stall = '0' then
          outreg2 <= rs2_reg;
        end if;

        if reset = '1' or flush = '1' then
          valid_output <= '0';
          valid_latch  <= '0';
        end if;
      end if;
    end process decode_stage;
    subseq_instr <= instr_latch;
    subseq_valid <= valid_latch;
    rs1_data     <= outreg1;
    rs2_data     <= outreg2;
  end generate two_cycle;


  one_cycle : if PIPELINE_STAGES = 1 generate
    rs1 <= instruction(19 downto 15) when stall = '0' else instr_out(19 downto 15);
    rs2 <= instruction(24 downto 20) when stall = '0' else instr_out(24 downto 20);

    decode_flushed <= not valid_input;
    decode_stage : process (clk, reset) is
    begin  -- process decode_stage
      if rising_edge(clk) then          -- rising clock edge
        if not stall = '1' then
          sign_extension <= std_logic_vector(
            resize(signed(instruction(INSTRUCTION_SIZE-1 downto INSTRUCTION_SIZE-1)),
                   SIGN_EXTENSION_SIZE));
          br_taken_out <= br_taken_in;
          PC_curr_out  <= PC_curr_in;
          instr_out    <= instruction;
          valid_output <= valid_input;
        end if;


        if reset = '1' or flush = '1' then
          valid_output <= '0';
        end if;
      end if;
    end process decode_stage;
    subseq_instr <= instruction;
    subseq_valid <= valid_input;
    rs1_data     <= rs1_reg;
    rs2_data     <= rs2_reg;
  end generate one_cycle;

end architecture;
