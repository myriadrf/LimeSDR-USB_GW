library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants_pkg.all;

entity instruction_legal is
  generic (
    CHECK_LEGAL_INSTRUCTIONS : boolean);
  port (
    instruction : in  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
    legal       : out std_logic);
end entity;

architecture rtl of instruction_legal is
  alias opcode7 is instruction(6 downto 0);
  alias func3 is instruction(INSTR_FUNC3'range);
  alias func7 is instruction(31 downto 25);
  alias csr_num is instruction(SYSTEM_MINOR_OP'range);
begin

  legal <=
    '1' when (CHECK_LEGAL_INSTRUCTIONS = false or
              opcode7 = LUI_OP or
              opcode7 = AUIPC_OP or
              opcode7 = JAL_OP or
              (opcode7 = JALR_OP and func3 = "000") or
              (opcode7 = BRANCH_OP and func3 /= "010" and func3 /= "011") or
              (opcode7 = LOAD_OP and func3 /= "011" and func3 /= "110" and func3 /= "111") or
              (opcode7 = STORE_OP and (func3 = "000" or func3 = "001" or func3 = "010")) or
              opcode7 = ALUI_OP or      --Does not catch illegal
                                        --shift amountes
              (opcode7 = ALU_OP and (func7 = ALU_F7 or func7 = MUL_F7 or func7 = SUB_F7))or
              (opcode7 = FENCE_OP) or   --all fence ops are treated as legal
              (opcode7 = SYSTEM_OP and csr_num /= SYSTEM_ECALL and csr_num /= SYSTEM_EBREAK) or
              opcode7 = LVE_OP) else '0';

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants_pkg.all;

entity system_calls is

  generic (
    REGISTER_SIZE     : natural;
    RESET_VECTOR      : integer;
    ENABLE_EXCEPTIONS : boolean := true;
    COUNTER_LENGTH    : natural);

  port (
    clk         : in std_logic;
    reset       : in std_logic;
    valid       : in std_logic;
    stall_in    : in std_logic;
    rs1_data    : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    instruction : in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);

    wb_data   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    wb_enable : out std_logic;

    current_pc    : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    pc_correction : out    std_logic_vector(REGISTER_SIZE -1 downto 0);
    pc_corr_en    : buffer std_logic;


    -- To the Instruction Fetch Stage
    interrupt_pending   : buffer std_logic;
    external_interrupts : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    -- Signals when an interrupt may proceed.
    pipeline_empty      : in     std_logic;

    -- These signals are used to tell the interrupt handler which instruction
    -- to return to upon exit. They are sourced from the instruction fetch
    -- stage of the processor.
    instruction_fetch_pc : in std_logic_vector(REGISTER_SIZE-1 downto 0);

    br_bad_predict : in std_logic;
    br_new_pc      : in std_logic_vector(REGISTER_SIZE-1 downto 0));

end entity system_calls;

architecture rtl of system_calls is


  component instruction_legal is
    generic (
      check_legal_instructions : boolean);
    port (
      instruction : in  std_logic_vector(instruction_size-1 downto 0);
      legal       : out std_logic);
  end component;

  --csr singnals. These are initialized to zero so that if any bits are nevver
  --assigned, they act like constants
  signal mstatus  : std_logic_vector(register_size-1 downto 0) := (others => '0');
  signal mie      : std_logic_vector(register_size-1 downto 0) := (others => '0');
  signal mepc     : std_logic_vector(register_size-1 downto 0) := (others => '0');
  signal mcause   : std_logic_vector(register_size-1 downto 0) := (others => '0');
  signal mbadaddr : std_logic_vector(register_size-1 downto 0) := (others => '0');
  signal mip      : std_logic_vector(register_size-1 downto 0) := (others => '0');
  signal mtime    : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mtimeh   : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal meimask  : std_logic_vector(register_size-1 downto 0) := (others => '0');
  signal meipend  : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');



  alias csr_select is instruction(CSR_ADDRESS'range);
  alias func3 is instruction(INSTR_FUNC3'range);

  signal bit_sel       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal csr_read_val  : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal csr_write_val : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal legal_instr : std_logic;

  signal was_mret    : std_logic;
  signal was_illegal : std_logic;
  signal was_fence_i : std_logic;
  signal pc_add_4    : std_logic_vector(current_pc'range);

  signal interrupt_processor : std_logic;

  signal time_counter : unsigned(63 downto 0);

begin  -- architecture rtl


  -----------------------------------------------------------------------------
  -- Implement the following :
  -- mret instruction
  -- csrrw
  -- csrrs
  -- csrrc (possibly not needed)
  -- Omit immediate versions of the csr* instructions
  -- Omit ECALL and EBREAK, as I can'tsee a reason with only mmode inplemented
  --
  -- Implement the following CSRs:
  --     MSTATUS  (for IE,PIE bits)
  --     MEPC
  --     MCAUSE
  --     MBADADDR (if bad reads are caught)
  --     MIP
  --     If expternal interupts are enabled:
  --         MEIMASK  (external interrupt mask)
  --         MEIPEND  (external interrupt
  -----------------------------------------------------------------------------

  instr_check : component instruction_legal
    generic map (
      check_legal_instructions => true)
    port map (
      instruction => instruction,
      legal       => legal_instr);

  --TIMER
  process(clk)
  begin
    if rising_edge(clk) then
      time_counter <= time_counter + 1;
      if reset = '1' then
        time_counter <= (others => '0');
      end if;
    end if;
  end process;

  mtime  <= std_logic_vector(time_counter(REGISTER_SIZE - 1 downto 0)) when COUNTER_LENGTH /= 0 else (others => '0');
  mtimeh <= std_logic_vector(time_counter(time_counter'left downto time_counter'left-REGISTER_SIZE+1))
            when REGISTER_SIZE = 32 and COUNTER_LENGTH = 64 else (others => '0');

  with csr_select select
    csr_read_val <=
    mstatus         when CSR_MSTATUS,
    mepc            when CSR_MEPC,
    mcause          when CSR_MCAUSE,
    mbadaddr        when CSR_MBADADDR,
    mip             when CSR_MIP,
    meimask         when CSR_MEIMASK,
    meipend         when CSR_MEIPEND,
    mtime           when CSR_MTIME,
    mtimeh          when CSR_MTIMEH,
    (others => '0') when others;

  bit_sel <= rs1_data;

  with func3 select
    csr_write_val <=
    rs1_data                     when CSRRW_FUNC3,
    csr_read_val or bit_sel      when CSRRS_FUNC3,
    csr_read_val and not bit_sel when CSRRC_FUNC3,
    csr_read_val                 when others;  --no write


  process(clk)
  begin
    if rising_edge(clk) then
      wb_enable   <= '0';
      wb_data     <= csr_read_val;
      pc_add_4    <= std_logic_vector(unsigned(current_pc) + 4);
      was_mret    <= '0';
      was_fence_i <= '0';
      was_illegal <= '0';
      if valid = '1' then
        if legal_instr /= '1' and ENABLE_EXCEPTIONS then
          ---------------------------------------------------------------------
          -- Handle illegal instructions
          ---------------------------------------------------------------------
          mstatus(CSR_MSTATUS_MIE)  <= '0';
          mstatus(CSR_MSTATUS_MPIE) <= mstatus(CSR_MSTATUS_MIE);
          mcause                    <= std_logic_vector(to_unsigned(CSR_MCAUSE_ILLEGAL, mcause'length));
          mepc                      <= current_pc;
          was_illegal               <= '1';
        elsif instruction(MAJOR_OP'range) = SYSTEM_OP  and stall_in = '0' then
          if func3 /= "000" then
            ---------------------------------------------------------------------
            -- CSR READ/WRITE
            ---------------------------------------------------------------------
            wb_enable <= '1';

            --disable csr writes if exceptions are not enabled
            if ENABLE_EXCEPTIONS then
              case csr_select is
                when CSR_MSTATUS =>
                  --only 2 bits writeable
                  mstatus(CSR_MSTATUS_MIE)  <= csr_write_val(CSR_MSTATUS_MIE);
                  mstatus(CSR_MSTATUS_MPIE) <= csr_write_val(CSR_MSTATUS_MPIE);
                when CSR_MEPC =>
                  mepc <= csr_write_val;
                when CSR_MCAUSE =>
                  mcause <= csr_write_val;
                when CSR_MBADADDR =>
                  mbadaddr <= csr_write_val;
                when CSR_MEIMASK =>
                  meimask <= csr_write_val;

                --READ only Registers
                --when CSR_MIP      =>
                --  mbadaddr <= csr_write_val;
                --when CSR_MEIPEND  =>
                --  meipend <= csr_write_val;
                when others => null;
              end case;
            end if;
          elsif instruction(SYSTEM_NOT_CSR'range) = SYSTEM_NOT_CSR then
            ---------------------------------------------------------------------
            -- OTHER SYSTEM INSTRUCTIONS (just Mret)
            ---------------------------------------------------------------------
            if instruction(31 downto 30) = "00" and instruction(27 downto 20) = "00000010" then
              --treat all [USHM]RET instructions the same
              mstatus(CSR_MSTATUS_MIE)  <= mstatus(CSR_MSTATUS_MPIE);
              mstatus(CSR_MSTATUS_MPIE) <= '0';
              was_mret                  <= '1';
            end if;  --other system
          end if;  --any system
        elsif instruction(MAJOR_OP'range) = FENCE_OP then
          --all FENCE is a NOP
          --FENCE.I is a pipeline flush
          was_fence_i <= instruction(12);
        end if;  --valid
      elsif interrupt_processor = '1' and ENABLE_EXCEPTIONS then
        mstatus(CSR_MSTATUS_MIE)  <= '0';
        mstatus(CSR_MSTATUS_MPIE) <= '1';
        mcause(mcause'left)       <= '1';
        mcause(3 downto 0)        <= std_logic_vector(to_unsigned(11, 4));
        mepc                      <= instruction_fetch_pc;
      end if;
      if reset = '1' then

        if ENABLE_EXCEPTIONS then
          mstatus(CSR_MSTATUS_MIE)  <= '0';
          mstatus(CSR_MSTATUS_MPIE) <= '0';
          mie                       <= (others => '0');
          mepc                      <= (others => '0');
          mcause                    <= (others => '0');
          meimask                   <= (others => '0');

        end if;

                                        --READ-ONLY
                                        --mip     <= (others => '0');
                                        --meipend <= (others => '0');
      end if;
    end if;
  end process;

-------------------------------------------------------------------------------
-- handle external interrupts
--
--TODO: (Not yet implemented)
-- nterrupt_processor goes high when pipeline is empty and and interrupt
--is pending
--
--If interrupt is pending and enabled, slip the pipeline.
-------------------------------------------------------------------------------
  meipend <= external_interrupts;

  interrupt_processor <= interrupt_pending and pipeline_empty;
  interrupt_pending   <= mstatus(CSR_MSTATUS_MIE) when unsigned(meimask and meipend) /= 0 else '0';


-----------------------------------------------------------------------------
-- There are several reasons that sys_calls might send a pc correction
-- Timer interrupt (if timer enabled)
-- external enterrupt
-- illegal instruction
-- mret instruction
-- fence.i  (flush pipelin, and start over)
-----------------------------------------------------------------------------

  pc_corr_en <= was_fence_i or was_mret or was_illegal or interrupt_processor;

  pc_correction <= pc_add_4 when was_fence_i = '1' else
                   std_logic_vector(to_unsigned(RESET_VECTOR, pc_correction'length)) when was_illegal = '1' or interrupt_processor = '1' else
                   mepc                                                              when was_mret = '1' else
                   (others => '-');



end architecture rtl;
