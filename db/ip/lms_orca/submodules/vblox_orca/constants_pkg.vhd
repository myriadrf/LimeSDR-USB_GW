library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.utils.all;

package constants_pkg is

  --REGISTER NAMES
  constant REGISTER_NAME_SIZE : integer := 5;

  constant REGISTER_ZERO : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(1, REGISTER_NAME_SIZE);
  constant REGISTER_RA   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(1, REGISTER_NAME_SIZE);
  constant REGISTER_SP   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(2, REGISTER_NAME_SIZE);
  constant REGISTER_GP   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(3, REGISTER_NAME_SIZE);
  constant REGISTER_TP   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(4, REGISTER_NAME_SIZE);
  constant REGISTER_T0   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(5, REGISTER_NAME_SIZE);
  constant REGISTER_T1   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(6, REGISTER_NAME_SIZE);
  constant REGISTER_T2   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(7, REGISTER_NAME_SIZE);
  constant REGISTER_S0   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(8, REGISTER_NAME_SIZE);
  constant REGISTER_S1   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(9, REGISTER_NAME_SIZE);
  constant REGISTER_A0   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(10, REGISTER_NAME_SIZE);
  constant REGISTER_A1   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(11, REGISTER_NAME_SIZE);
  constant REGISTER_A2   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(12, REGISTER_NAME_SIZE);
  constant REGISTER_A3   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(13, REGISTER_NAME_SIZE);
  constant REGISTER_A4   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(14, REGISTER_NAME_SIZE);
  constant REGISTER_A5   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(15, REGISTER_NAME_SIZE);
  constant REGISTER_A6   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(16, REGISTER_NAME_SIZE);
  constant REGISTER_A7   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(17, REGISTER_NAME_SIZE);
  constant REGISTER_S2   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(18, REGISTER_NAME_SIZE);
  constant REGISTER_S3   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(19, REGISTER_NAME_SIZE);
  constant REGISTER_S4   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(20, REGISTER_NAME_SIZE);
  constant REGISTER_S5   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(21, REGISTER_NAME_SIZE);
  constant REGISTER_S6   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(22, REGISTER_NAME_SIZE);
  constant REGISTER_S7   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(23, REGISTER_NAME_SIZE);
  constant REGISTER_S8   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(24, REGISTER_NAME_SIZE);
  constant REGISTER_S9   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(25, REGISTER_NAME_SIZE);
  constant REGISTER_S10  : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(26, REGISTER_NAME_SIZE);
  constant REGISTER_S11  : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(27, REGISTER_NAME_SIZE);
  constant REGISTER_T3   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(28, REGISTER_NAME_SIZE);
  constant REGISTER_T4   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(29, REGISTER_NAME_SIZE);
  constant REGISTER_T5   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(30, REGISTER_NAME_SIZE);
  constant REGISTER_T6   : unsigned(REGISTER_NAME_SIZE-1 downto 0) := to_unsigned(31, REGISTER_NAME_SIZE);

  constant REGISTER_RS1 : unsigned(19 downto 15) := (others => '0');
  constant REGISTER_RS2 : unsigned(24 downto 20) := (others => '0');
  constant REGISTER_RD  : unsigned(11 downto 7)  := (others => '0');



  --Major OP codes instr(6 downto 0)
  constant MAJOR_OP   : std_logic_vector(6 downto 0) := (others => '-');
  constant JAL_OP     : std_logic_vector(6 downto 0) := "1101111";
  constant JALR_OP    : std_logic_vector(6 downto 0) := "1100111";
  constant LUI_OP     : std_logic_vector(6 downto 0) := "0110111";
  constant AUIPC_OP   : std_logic_vector(6 downto 0) := "0010111";
  constant ALU_OP     : std_logic_vector(6 downto 0) := "0110011";
  constant ALUI_OP    : std_logic_vector(6 downto 0) := "0010011";
  constant LOAD_OP    : std_logic_vector(6 downto 0) := "0000011";
  constant STORE_OP   : std_logic_vector(6 downto 0) := "0100011";
  constant FENCE_OP   : std_logic_vector(6 downto 0) := "0001111";
  constant SYSTEM_OP  : std_logic_vector(6 downto 0) := "1110011";
  constant CUSTOM0_OP : std_logic_vector(6 downto 0) := "0101011";
  constant LVE_OP     : std_logic_vector(6 downto 0) := CUSTOM0_OP;
  constant BRANCH_OP  : std_logic_vector(6 downto 0) := "1100011";


  constant INSTRUCTION_SIZE : integer := 32;


  constant OP_IMM_IMMEDIATE_SIZE : integer                      := 12;
  constant JAL                   : std_logic_vector(6 downto 0) := "1101111";
  constant JALR                  : std_logic_vector(6 downto 0) := "1100111";

  constant CSR_ADDRESS      : std_logic_vector(31 downto 20) := (others => '0');
  constant CSR_MSTATUS      : std_logic_vector(11 downto 0)  := x"300";
  constant CSR_MIE          : std_logic_vector(11 downto 0)  := x"304";
  constant CSR_MEPC         : std_logic_vector(11 downto 0)  := x"341";
  constant CSR_MCAUSE       : std_logic_vector(11 downto 0)  := x"342";
  constant CSR_MBADADDR     : std_logic_vector(11 downto 0)  := x"304";
  constant CSR_MIP          : std_logic_vector(11 downto 0)  := x"344";
  constant CSR_MTIME        : std_logic_vector(11 downto 0)  := x"F01";
  constant CSR_MTIMEH       : std_logic_vector(11 downto 0)  := x"F81";
  --NON-STANDARD
  constant CSR_MEIMASK      : std_logic_vector(11 downto 0)  := x"7C0";
  constant CSR_MEIPEND      : std_logic_vector(11 downto 0)  := x"FC0";
  --CSR BITS
  constant CSR_MSTATUS_MIE  : integer                        := 3;
  constant CSR_MSTATUS_MPIE : integer                        := 7;

  constant CSR_MCAUSE_MEXT    : integer := 16#8000000B#;
  constant CSR_MCAUSE_ILLEGAL : integer := 2;
  constant CSR_MCAUSE_EBREAK  : integer := 3;
  constant CSR_MCAUSE_MECALL  : integer := 11;

  constant CSRRW_FUNC3 : std_logic_vector(2 downto 0) := "001";
  constant CSRRS_FUNC3 : std_logic_vector(2 downto 0) := "010";
  constant CSRRC_FUNC3 : std_logic_vector(2 downto 0) := "011";



  constant SYSTEM_MINOR_OP : std_logic_vector(31 downto 20) := (others => '0');
  constant SYSTEM_NOT_CSR  : std_logic_vector(19 downto 7)  := (others => '0');
  constant SYSTEM_ECALL    : std_logic_vector(11 downto 0)  := x"000";
  constant SYSTEM_EBREAK   : std_logic_vector(11 downto 0)  := x"001";

  constant INSTR_FUNC3 : std_logic_vector(14 downto 12) := "000";
  --branch FUNC3 instr(14 downto 12)
  constant BEQ_OP      : std_logic_vector(2 downto 0)   := "000";
  constant BNE_OP      : std_logic_vector(2 downto 0)   := "001";
  constant BLT_OP      : std_logic_vector(2 downto 0)   := "100";
  constant BGE_OP      : std_logic_vector(2 downto 0)   := "101";
  constant BLTU_OP     : std_logic_vector(2 downto 0)   := "110";
  constant BGEU_OP     : std_logic_vector(2 downto 0)   := "111";

  --Load store  func3 instr(14 downto 12)

  constant BYTE_SIZE   : std_logic_vector(2 downto 0) := "000";
  constant HALF_SIZE   : std_logic_vector(2 downto 0) := "001";
  constant WORD_SIZE   : std_logic_vector(2 downto 0) := "010";
  constant UBYTE_SIZE  : std_logic_vector(2 downto 0) := "100";
  constant UHALF_SIZE  : std_logic_vector(2 downto 0) := "101";
  constant STORE_INSTR : std_logic_vector(6 downto 0) := "0100011";
  constant LOAD_INSTR  : std_logic_vector(6 downto 0) := "0000011";

  --alu func3
  constant ADD_OP  : std_logic_vector(2 downto 0) := "000";
  constant SLL_OP  : std_logic_vector(2 downto 0) := "001";
  constant SLT_OP  : std_logic_vector(2 downto 0) := "010";
  constant SLTU_OP : std_logic_vector(2 downto 0) := "011";
  constant XOR_OP  : std_logic_vector(2 downto 0) := "100";
  constant SR_OP   : std_logic_vector(2 downto 0) := "101";
  constant OR_OP   : std_logic_vector(2 downto 0) := "110";
  constant AND_OP  : std_logic_vector(2 downto 0) := "111";


  --multipy func3
  constant MUL_OP    : std_logic_vector(2 downto 0) := "000";
  constant MULH_OP   : std_logic_vector(2 downto 0) := "001";
  constant MULHSU_OP : std_logic_vector(2 downto 0) := "010";
  constant MULHU_OP  : std_logic_vector(2 downto 0) := "011";
  constant DIV_OP    : std_logic_vector(2 downto 0) := "100";
  constant DIVU_OP   : std_logic_vector(2 downto 0) := "101";
  constant REM_OP    : std_logic_vector(2 downto 0) := "110";
  constant REMU_OP   : std_logic_vector(2 downto 0) := "111";

  constant MUL_F7 : std_logic_vector(6 downto 0) := "0000001";
  constant SUB_f7 : std_logic_vector(6 downto 0) := "0100000";
  constant ALU_f7 : std_logic_vector(6 downto 0) := "0000000";

  constant FENCE_I_BITS : std_logic_vector(31 downto 7) := x"0000"&"00010"&x"0";
end package constants_pkg;
