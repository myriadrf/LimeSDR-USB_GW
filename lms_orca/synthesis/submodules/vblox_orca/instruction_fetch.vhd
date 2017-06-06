library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.rv_components.all;
use work.utils.all;
use work.constants_pkg.all;

entity instruction_fetch is
  generic (
    REGISTER_SIZE     : positive;
    RESET_VECTOR      : integer;
    BRANCH_PREDICTORS : natural);
  port (
    clk                : in std_logic;
    reset              : in std_logic;
    downstream_stalled : in std_logic;
    interrupt_pending  : in std_logic;
    branch_pred        : in std_logic_vector(REGISTER_SIZE*2+3-1 downto 0);

    br_taken        : buffer std_logic;
    instr_out       : out    std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
    pc_out          : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
    next_pc_out     : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
    valid_instr_out : out    std_logic;

    read_address   : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
    read_en        : buffer std_logic;
    read_data      : in     std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
    read_datavalid : in     std_logic;
    read_wait      : in     std_logic);
end entity instruction_fetch;


architecture rtl of instruction_fetch is
  type state_t is (state_0, state_1, state_2);

  signal state : state_t;

  signal move_to_next_address : boolean;
  signal program_counter      : unsigned(REGISTER_SIZE-1 downto 0);

  signal pc_corr    : unsigned(REGISTER_SIZE-1 downto 0);
  signal pc_corr_en : std_logic;

  signal pc_corr_saved    : unsigned(REGISTER_SIZE-1 downto 0);
  signal pc_corr_saved_en : std_logic;

  signal instr_out_saved       : std_logic_vector(instr_out'range);
  signal valid_instr_out_saved : std_logic;

  signal predicted_pc : unsigned(REGISTER_SIZE -1 downto 0);
  signal next_address : unsigned(REGISTER_SIZE -1 downto 0);

  signal suppress_valid_instr_out : std_logic;
  signal dont_increment           : std_logic;
begin  -- architecture rtl


  --unpack branch_pred_data_in
  --branch_pc       <= branch_get_pc(branch_pred);
  --branch_taken_in <= branch_get_taken(branch_pred);
  --branch_en       <= branch_get_enable(branch_pred);
  pc_corr    <= unsigned(branch_get_tgt(branch_pred));
  pc_corr_en <= branch_get_flush(branch_pred);

  dont_increment <= downstream_stalled or interrupt_pending;

  move_to_next_address <= (state = state_1 and read_datavalid = '1' and dont_increment = '0') or
                          (state = state_2 and dont_increment = '0');



  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when state_0 =>                 --waiting for read_wait
          if read_wait = '0' then
            state <= state_1;
          else
            state <= state_0;
          end if;
        when state_1 =>                 --waiting for readvalid
          if read_datavalid = '1' then
            if dont_increment = '1' then
              state <= state_2;
            elsif read_wait = '0' then
              state <= state_1;
            else
              state <= state_0;
            end if;
          end if;
        when state_2 =>                 -- waiting for execute_stall
          if dont_increment = '0' then
            if read_wait = '0' then
              state <= state_1;
            else
              state <= state_0;
            end if;

          else
            state <= state_2;
          end if;
        when others => null;
      end case;

      if reset = '1' then
        state <= state_0;
      end if;
    end if;
  end process;


  bramch_pred_proc : process(clk)
  begin
    if rising_edge(clk) then
      predicted_pc <= next_address +4;
    end if;
  end process;

  pc_corr_proc : process(clk)
  begin
    if rising_edge(clk) then
      if not move_to_next_address then
        if pc_corr_en = '1' then
          pc_corr_saved    <= pc_corr;
          pc_corr_saved_en <= '1';
        end if;
      else
        pc_corr_saved_en <= '0';
      end if;
    end if;
  end process;

  program_counter_transition : process(clk)
  begin
    if rising_edge(clk) then
      if move_to_next_address then
        program_counter <= next_address;
      end if;
      if reset = '1' then
        program_counter <= unsigned(to_signed(RESET_VECTOR, REGISTER_SIZE));
      end if;
    end if;
  end process;

  save_fetched_instr : process(clk)
  begin
    if rising_edge(clk) then
      if downstream_stalled = '1' then
        if read_datavalid = '1' then
          instr_out_saved       <= read_data;
          valid_instr_out_saved <= read_datavalid;
        end if;
      else
        valid_instr_out_saved <= '0';
      end if;
    end if;
  end process;

  suppress_valid_instr_out_proc : process(clk)
  begin
    if rising_edge(clk) then
      if pc_corr_en = '1' then
        suppress_valid_instr_out <= not interrupt_pending;
      end if;
      if read_datavalid = '1' then
        suppress_valid_instr_out <= '0';
      end if;
      if reset = '1' then
        suppress_valid_instr_out <= '0';
      end if;
    end if;
  end process;

  pc_out          <= std_logic_vector(program_counter);
  instr_out       <= read_data when valid_instr_out_saved = '0' else instr_out_saved;
  valid_instr_out <= (read_datavalid or valid_instr_out_saved) and not (suppress_valid_instr_out or pc_corr_en or interrupt_pending);


  next_address <= pc_corr when pc_corr_en = '1' and move_to_next_address else
                  pc_corr_saved when pc_corr_saved_en = '1' and move_to_next_address else
                  predicted_pc  when move_to_next_address else
                  program_counter;
  next_pc_out  <= std_logic_vector(next_address);
  read_address <= std_logic_vector(program_counter) when state = state_0                           else std_logic_vector(next_address);
  read_en      <= not reset                         when (state = state_0 or move_to_next_address) else '0';
  br_taken     <= '0';
end architecture rtl;
