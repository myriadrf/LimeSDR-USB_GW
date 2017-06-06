library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library work;
use work.rv_components.all;
use work.utils.all;
use work.constants_pkg.all;

entity orca_core is

  generic (
    REGISTER_SIZE      : integer;
    RESET_VECTOR       : integer;
    MULTIPLY_ENABLE    : natural range 0 to 1;
    DIVIDE_ENABLE      : natural range 0 to 1;
    SHIFTER_MAX_CYCLES : natural;
    COUNTER_LENGTH     : natural;
    ENABLE_EXCEPTIONS  : natural;
    BRANCH_PREDICTORS  : natural;
    PIPELINE_STAGES    : natural range 4 to 5;
    NUM_EXT_INTERRUPTS : integer range 0 to 32;
    LVE_ENABLE         : natural range 0 to 1;
    SCRATCHPAD_SIZE    : integer;
    FAMILY             : string);

  port(clk            : in std_logic;
       scratchpad_clk : in std_logic;
       reset          : in std_logic;

       --avalon master bus
       core_data_address              : out std_logic_vector(REGISTER_SIZE-1 downto 0);
       core_data_byteenable           : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
       core_data_read                 : out std_logic;
       core_data_readdata             : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => 'X');
       core_data_write                : out std_logic;
       core_data_writedata            : out std_logic_vector(REGISTER_SIZE-1 downto 0);
       core_data_ack                  : in  std_logic                                  := '0';
       --avalon master bus
       core_instruction_address       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
       core_instruction_read          : out std_logic;
       core_instruction_readdata      : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => 'X');
       core_instruction_waitrequest   : in  std_logic                                  := '0';
       core_instruction_readdatavalid : in  std_logic                                  := '0';

       external_interrupts : in std_logic_vector(NUM_EXT_INTERRUPTS-1 downto 0) := (others => '0')
       );

end entity Orca_core;

architecture rtl of orca_core is
  constant SIGN_EXTENSION_SIZE : integer := 20;

  --signals going into fetch
  signal if_valid_out : std_logic;

  --signals going into decode
  signal d_instr     : std_logic_vector(INSTRUCTION_SIZE -1 downto 0);
  signal d_pc        : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal d_br_taken  : std_logic;
  signal d_valid     : std_logic;
  signal d_valid_out : std_logic;

  signal wb_data        : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal wb_sel         : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
  signal wb_en          : std_logic;
  signal wb_valid       : std_logic;
  --signals going into execute
  signal e_instr        : std_logic_vector(INSTRUCTION_SIZE -1 downto 0);
  signal e_subseq_instr : std_logic_vector(INSTRUCTION_SIZE -1 downto 0);
  signal e_subseq_valid : std_logic;
  signal e_pc           : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal e_br_taken     : std_logic;
  signal e_valid        : std_logic;
  signal e_data_ack     : std_logic;
  signal pipeline_empty : std_logic;

  signal execute_stalled : std_logic;
  signal rs1_data        : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal rs2_data        : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal sign_extension  : std_logic_vector(REGISTER_SIZE-12-1 downto 0);

  signal pipeline_flush : std_logic;

  signal data_address    : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal data_byte_en    : std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
  signal data_write_en   : std_logic;
  signal data_read_en    : std_logic;
  signal data_write_data : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal data_read_data  : std_logic_vector(REGISTER_SIZE-1 downto 0);


  signal instr_address : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal instr_data    : std_logic_vector(INSTRUCTION_SIZE-1 downto 0);

  signal instr_read_wait : std_logic;
  signal instr_read_en   : std_logic;
  signal instr_readvalid : std_logic;

  -- Interrupt lines
  signal e_interrupt_pending : std_logic;
  signal ext_int_resized     : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal branch_pred_to_instr_fetch : std_logic_vector(REGISTER_SIZE*2 + 3-1 downto 0);

  signal decode_flushed : std_logic;
  signal ifetch_next_pc : std_logic_vector(REGISTER_SIZE-1 downto 0);


begin  -- architecture rtl
  pipeline_flush <= branch_get_flush(branch_pred_to_instr_fetch);


  instr_fetch : component instruction_fetch
    generic map (
      REGISTER_SIZE     => REGISTER_SIZE,
      RESET_VECTOR      => RESET_VECTOR,
      BRANCH_PREDICTORS => BRANCH_PREDICTORS)
    port map (
      clk                => clk,
      reset              => reset,
      downstream_stalled => execute_stalled,
      interrupt_pending  => e_interrupt_pending,
      branch_pred        => branch_pred_to_instr_fetch,

      instr_out       => d_instr,
      pc_out          => d_pc,
      next_pc_out     => ifetch_next_pc,
      br_taken        => d_br_taken,
      valid_instr_out => if_valid_out,
      read_address    => instr_address,
      read_en         => instr_read_en,
      read_data       => instr_data,
      read_datavalid  => instr_readvalid,
      read_wait       => instr_read_wait);

  d_valid <= if_valid_out and not pipeline_flush;

  D : component decode
    generic map(
      REGISTER_SIZE       => REGISTER_SIZE,
      SIGN_EXTENSION_SIZE => SIGN_EXTENSION_SIZE,
      PIPELINE_STAGES     => PIPELINE_STAGES-3)
    port map(
      clk            => clk,
      reset          => reset,
      stall          => execute_stalled,
      flush          => pipeline_flush,
      instruction    => d_instr,
      valid_input    => d_valid,
      --writeback signals
      wb_sel         => wb_sel,
      wb_data        => wb_data,
      wb_enable      => wb_en,
      wb_valid       => wb_valid,
      --output signals
      rs1_data       => rs1_data,
      rs2_data       => rs2_data,
      sign_extension => sign_extension,
      --inputs just for carrying to next pipeline stage
      br_taken_in    => d_br_taken,
      pc_curr_in     => d_pc,
      br_taken_out   => e_br_taken,
      pc_curr_out    => e_pc,
      instr_out      => e_instr,
      subseq_instr   => e_subseq_instr,
      subseq_valid   => e_subseq_valid,
      valid_output   => d_valid_out,
      decode_flushed => decode_flushed);

  e_valid <= d_valid_out and not pipeline_flush;
  X : component execute
    generic map (
      REGISTER_SIZE       => REGISTER_SIZE,
      SIGN_EXTENSION_SIZE => SIGN_EXTENSION_SIZE,
      RESET_VECTOR        => RESET_VECTOR,
      MULTIPLY_ENABLE     => MULTIPLY_ENABLE = 1,
      DIVIDE_ENABLE       => DIVIDE_ENABLE = 1,
      SHIFTER_MAX_CYCLES  => SHIFTER_MAX_CYCLES,
      COUNTER_LENGTH      => COUNTER_LENGTH,
      ENABLE_EXCEPTIONS   => ENABLE_EXCEPTIONS = 1,
      SCRATCHPAD_SIZE     => CONDITIONAL(LVE_ENABLE = 1, SCRATCHPAD_SIZE, 0),
      FAMILY              => FAMILY)
    port map (
      clk                => clk,
      scratchpad_clk     => scratchpad_clk,
      reset              => reset,
      valid_input        => e_valid,
      br_taken_in        => e_br_taken,
      pc_current         => e_pc,
      instruction        => e_instr,
      subseq_instr       => e_subseq_instr,
      subseq_valid       => e_subseq_valid,
      rs1_data           => rs1_data,
      rs2_data           => rs2_data,
      sign_extension     => sign_extension,
      wb_sel             => wb_sel,
      wb_data            => wb_data,
      wb_enable          => wb_en,
      valid_output       => wb_valid,
      branch_pred        => branch_pred_to_instr_fetch,
      ifetch_next_pc     => ifetch_next_pc,
      stall_from_execute => execute_stalled,

      --Memory bus
      address   => data_address,
      byte_en   => data_byte_en,
      write_en  => data_write_en,
      read_en   => data_read_en,
      writedata => data_write_data,
      readdata  => data_read_data,
      data_ack  => e_data_ack,

      -- Interrupt lines
      external_interrupts => ext_int_resized,
      pipeline_empty      => decode_flushed,
      interrupt_pending   => e_interrupt_pending);

  ext_int_resized <= std_logic_vector(RESIZE(unsigned(external_interrupts), ext_int_resized'length));

  core_data_address    <= data_address;
  core_data_byteenable <= data_byte_en;
  core_data_read       <= data_read_en;
  core_data_write      <= data_write_en;
  core_data_writedata  <= data_write_data;

  data_read_data <= core_data_readdata;
  e_data_ack     <= core_data_ack;

  core_instruction_address <= instr_address;
  core_instruction_read    <= instr_read_en;
  instr_data               <= core_instruction_readdata;
  instr_read_wait          <= core_instruction_waitrequest;
  instr_readvalid          <= core_instruction_readdatavalid;

end architecture rtl;
