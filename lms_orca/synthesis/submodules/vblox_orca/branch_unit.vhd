library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.constants_pkg.all;
--use IEEE.std_logic_arith.all;

entity branch_unit is


  generic (
    REGISTER_SIZE       : integer;
    SIGN_EXTENSION_SIZE : integer);

  port (
    clk            : in  std_logic;
    stall          : in  std_logic;
    valid          : in  std_logic;
    reset          : in  std_logic;
    rs1_data       : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    rs2_data       : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    current_pc     : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    br_taken_in    : in  std_logic;
    instr          : in  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
    sign_extension : in  std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);
    less_than      : in  std_logic;
    --unconditional jumps store return address in rd, output return address
    -- on data_out lines
    data_out       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    data_out_en    : out std_logic;
    new_pc         : out std_logic_vector(REGISTER_SIZE-1 downto 0);  --next pc
    is_branch      : out std_logic;
    br_taken_out   : out std_logic;
    bad_predict    : out std_logic
    );
end entity branch_unit;


architecture latch_middle of branch_unit is

  constant OP_IMM_IMMEDIATE_SIZE : integer := 12;



  --these are one bit larget than a register
  signal op1      : signed(REGISTER_SIZE downto 0);
  signal op2      : signed(REGISTER_SIZE downto 0);
  signal sub      : signed(REGISTER_SIZE downto 0);
  signal msb_mask : std_logic;

  signal jal_imm        : unsigned(REGISTER_SIZE-1 downto 0);
  signal jalr_imm       : unsigned(REGISTER_SIZE-1 downto 0);
  signal b_imm          : unsigned(REGISTER_SIZE-1 downto 0);
  signal branch_target  : unsigned(REGISTER_SIZE-1 downto 0);
  signal nbranch_target : unsigned(REGISTER_SIZE-1 downto 0);
  signal jalr_target    : unsigned(REGISTER_SIZE-1 downto 0);
  signal jal_target     : unsigned(REGISTER_SIZE-1 downto 0);
  signal target_pc      : unsigned(REGISTER_SIZE-1 downto 0);

  signal leq_flg : std_logic;
  signal eq_flg  : std_logic;

  signal branch_taken : std_logic;

  alias func3  : std_logic_vector(2 downto 0) is instr(INSTR_FUNC3'range);
  alias opcode : std_logic_vector(6 downto 0) is instr(6 downto 0);

  signal valid_branch_instr : std_logic;
  signal br_taken_latch     : std_logic;
  signal target_pc_latch    : unsigned(REGISTER_SIZE-1 downto 0);
  signal nbranch_latch      : unsigned(REGISTER_SIZE-1 downto 0);
  signal branch_taken_latch : std_logic;
  signal data_en_latch      : std_logic;

  signal branch_taken_or_jump : std_logic;
  signal is_jal_op               : std_logic;
  signal is_jalr_op              : std_logic;
  signal is_br_op                : std_logic;
begin  -- architecture


  with func3 select
    msb_mask <=
    '0' when BLTU_OP,
    '0' when BGEU_OP,
    '1' when others;



  op1 <= signed((msb_mask and rs1_data(rs1_data'left)) & rs1_data);
  op2 <= signed((msb_mask and rs2_data(rs2_data'left)) & rs2_data);
  sub <= op1 - op2;

  eq_flg  <= '1' when op1 = op2 else '0';
  leq_flg <= less_than;

  with func3 select
    branch_taken <=
    eq_flg                 when beq_OP,
    not eq_flg             when bne_OP,
    leq_flg and not eq_flg when blt_OP,
    not leq_flg or eq_flg  when bge_OP,
    leq_flg and not eq_flg when bltu_OP,
    not leq_flg or eq_flg  when bgeu_OP,
    '0'                    when others;

  b_imm <= unsigned(sign_extension(REGISTER_SIZE-13 downto 0) &
                    instr(7) & instr(30 downto 25) &instr(11 downto 8) & "0");

  jalr_imm <= unsigned(sign_extension(REGISTER_SIZE-12-1 downto 0) &
                       instr(31 downto 21) & "0") ;
  jal_imm <= unsigned(RESIZE(signed(instr(31) & instr(19 downto 12) & instr(20) &
                                    instr(30 downto 21)&"0"),REGISTER_SIZE));

  branch_target  <= b_imm + unsigned(current_pc);
  nbranch_target <= to_unsigned(4, REGISTER_SIZE) + unsigned(current_pc);
  jalr_target    <= jalr_imm + unsigned(rs1_data);
  jal_target     <= jal_imm + unsigned(current_pc);

  with opcode select
    target_pc <=
    jalr_target    when JALR_OP,
    jal_target     when JAL_OP,
    branch_target  when BRANCH_OP,
    nbranch_target when others;


  middle_latch : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        valid_branch_instr <= '0';
        br_taken_latch     <= '0';
      else
        valid_branch_instr <= valid and not stall;
        if stall = '0' then
          br_taken_latch     <= br_taken_in;
          target_pc_latch    <= target_pc;
          branch_taken_latch <= branch_taken;

          is_jal_op  <= '0';
          is_jalr_op <= '0';
          is_br_op   <= '0';

          if opcode = JAL_OP then    is_jal_op   <= '1'; end if;
          if opcode = JALR_OP then   is_jalr_op <= '1'; end if;
          if opcode = BRANCH_OP then is_br_op <= '1'; end if;

          nbranch_latch <= nbranch_target;
        end if;
      end if;
    end if;
  end process;


  data_out_en <= valid_branch_instr and (is_jal_op or is_jalr_op);

  branch_taken_or_jump <= (branch_taken_latch and is_br_op) or is_jal_op or is_jalr_op;
  br_taken_out         <= valid_branch_instr and branch_taken_or_jump;
  bad_predict          <= valid_branch_instr when br_taken_latch /= branch_taken_or_jump or is_jalr_op = '1' else '0';
  is_branch            <= valid_branch_instr when is_jal_op = '1' or is_br_op = '1'                             else '0';

  new_pc   <= std_logic_vector(target_pc_latch) when branch_taken_or_jump = '1' else std_logic_vector(nbranch_latch);
  data_out <= std_logic_vector(nbranch_latch);


end architecture;
