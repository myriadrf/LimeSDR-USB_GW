library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.utils.all;
use work.constants_pkg.all;

package rv_components is

  component orca is
    generic (
      REGISTER_SIZE   : integer              := 32;
      --BUS Select
      AVALON_ENABLE   : integer range 0 to 1 := 0;
      WISHBONE_ENABLE : integer range 0 to 1 := 0;
      AXI_ENABLE      : integer range 0 to 1 := 0;

      RESET_VECTOR       : integer               := 16#00000200#;
      MULTIPLY_ENABLE    : natural range 0 to 1  := 0;
      DIVIDE_ENABLE      : natural range 0 to 1  := 0;
      SHIFTER_MAX_CYCLES : natural               := 1;
      COUNTER_LENGTH     : natural               := 0;
      ENABLE_EXCEPTIONS  : natural               := 1;
      BRANCH_PREDICTORS  : natural               := 0;
      PIPELINE_STAGES    : natural range 4 to 5  := 5;
      LVE_ENABLE         : natural range 0 to 1  := 0;
      NUM_EXT_INTERRUPTS : integer range 0 to 32 := 0;
      SCRATCHPAD_SIZE    : integer               := 1024;
      FAMILY             : string                := "ALTERA");
    port(
      clk            : in std_logic;
      scratchpad_clk : in std_logic;
      reset          : in std_logic;

      --avalon data bus
      avm_data_address              : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      avm_data_byteenable           : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      avm_data_read                 : out std_logic;
      avm_data_readdata             : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => 'X');
      avm_data_write                : out std_logic;
      avm_data_writedata            : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      avm_data_waitrequest          : in  std_logic                                  := '0';
      avm_data_readdatavalid        : in  std_logic                                  := '0';
      --avalon instruction bus
      avm_instruction_address       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      avm_instruction_read          : out std_logic;
      avm_instruction_readdata      : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => 'X');
      avm_instruction_waitrequest   : in  std_logic                                  := '0';
      avm_instruction_readdatavalid : in  std_logic                                  := '0';
      --wishbone data bus
      data_ADR_O                    : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_DAT_I                    : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_DAT_O                    : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_WE_O                     : out std_logic;
      data_SEL_O                    : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      data_STB_O                    : out std_logic;
      data_ACK_I                    : in  std_logic;
      data_CYC_O                    : out std_logic;
      data_CTI_O                    : out std_logic_vector(2 downto 0);
      data_STALL_I                  : in  std_logic;
      --wishbone instruction bus
      instr_ADR_O                   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      instr_DAT_I                   : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      instr_STB_O                   : out std_logic;
      instr_ACK_I                   : in  std_logic;
      instr_CYC_O                   : out std_logic;
      instr_CTI_O                   : out std_logic_vector(2 downto 0);
      instr_STALL_I                 : in  std_logic;

      --AXI BUS

      -- Write address channel ---------------------------------------------------------
      data_AWID    : out std_logic_vector(3 downto 0);  -- ID for write address signals
      data_AWADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);  -- Address of the first transferin a burst
      data_AWLEN   : out std_logic_vector(3 downto 0);  -- Number of transfers in a burst, burst must not cross 4 KB boundary, burst length of 1 to 16 transfers in AXI3
      data_AWSIZE  : out std_logic_vector(2 downto 0);  -- Maximum number of bytes to transfer in each data transfer (beat) in a burst
      -- See Table A3-2 for AxSIZE encoding
      -- 0b010 => 4 bytes in a transfer
      data_AWBURST : out std_logic_vector(1 downto 0);  -- defines the burst type, fixed, incr, or wrap
      -- fixed accesses the same address repeatedly, incr increments the address for each transfer, wrap = incr except rolls over to lower address if upper limit is reached
      -- see table A3-3 for AxBURST encoding
      data_AWLOCK  : out std_logic_vector(1 downto 0);  -- Ensures that only the master can access the targeted slave region
      data_AWCACHE : out std_logic_vector(3 downto 0);  -- specifies memory type, see Table A4-5
      data_AWPROT  : out std_logic_vector(2 downto 0);  -- specifies access permission, see Table A4-6
      data_AWVALID : out std_logic;  -- Valid address and control information on bus, asserted until slave asserts AWREADY
      data_AWREADY : in  std_logic := '-';  -- Slave is ready to accept address and control signals

      -- Write data channel ------------------------------------------------------------
      data_WID    : out std_logic_vector(3 downto 0);  -- ID for write data signals
      data_WDATA  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      data_WSTRB  : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);  -- Specifies which byte lanes contain valid information
      data_WLAST  : out std_logic;  -- Asserted when master is driving the final write transfer in the burst
      data_WVALID : out std_logic;  -- Valid data available on bus, asserted until slave asserts WREADY
      data_WREADY : in  std_logic := '-';  -- Slave is now available to accept write data

      -- Write response channel ---------------------------------------------------------
      data_BID    : in  std_logic_vector(3 downto 0) := (others => '-');  -- ID for write response
      data_BRESP  : in  std_logic_vector(1 downto 0) := (others => '-');  -- Slave response (with error codes) to a write
      data_BVALID : in  std_logic                    := '-';  -- Indicates that the channel is signaling a valid write response
      data_BREADY : out std_logic;  -- Indicates that master has acknowledged write response

      -- Read address channel ------------------------------------------------------------
      data_ARID    : out std_logic_vector(3 downto 0);
      data_ARADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      data_ARLEN   : out std_logic_vector(3 downto 0);
      data_ARSIZE  : out std_logic_vector(2 downto 0);
      data_ARBURST : out std_logic_vector(1 downto 0);
      data_ARLOCK  : out std_logic_vector(1 downto 0);
      data_ARCACHE : out std_logic_vector(3 downto 0);
      data_ARPROT  : out std_logic_vector(2 downto 0);
      data_ARVALID : out std_logic;
      data_ARREADY : in  std_logic := '-';

      -- Read data channel -----------------------------------------------------------------
      data_RID    : in  std_logic_vector(3 downto 0)                := (others => '-');
      data_RDATA  : in  std_logic_vector(REGISTER_SIZE -1 downto 0) := (others => '-');
      data_RRESP  : in  std_logic_vector(1 downto 0)                := (others => '-');
      data_RLAST  : in  std_logic                                   := '-';
      data_RVALID : in  std_logic                                   := '-';
      data_RREADY : out std_logic;

      -- Read address channel ------------------------------------------------------------
      instr_ARID    : out std_logic_vector(3 downto 0);
      instr_ARADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      instr_ARLEN   : out std_logic_vector(3 downto 0);
      instr_ARSIZE  : out std_logic_vector(2 downto 0);
      instr_ARBURST : out std_logic_vector(1 downto 0);
      instr_ARLOCK  : out std_logic_vector(1 downto 0);
      instr_ARCACHE : out std_logic_vector(3 downto 0);
      instr_ARPROT  : out std_logic_vector(2 downto 0);
      instr_ARVALID : out std_logic;
      instr_ARREADY : in  std_logic := '-';

      -- Read data channel -----------------------------------------------------------------
      instr_RID    : in  std_logic_vector(3 downto 0)                := (others => '-');
      instr_RDATA  : in  std_logic_vector(REGISTER_SIZE -1 downto 0) := (others => '-');
      instr_RRESP  : in  std_logic_vector(1 downto 0)                := (others => '-');
      instr_RLAST  : in  std_logic                                   := '-';
      instr_RVALID : in  std_logic                                   := '-';
      instr_RREADY : out std_logic;

      instr_AWID    : out std_logic_vector(3 downto 0);
      instr_AWADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      instr_AWLEN   : out std_logic_vector(3 downto 0);
      instr_AWSIZE  : out std_logic_vector(2 downto 0);
      instr_AWBURST : out std_logic_vector(1 downto 0);
      instr_AWLOCK  : out std_logic_vector(1 downto 0);
      instr_AWCACHE : out std_logic_vector(3 downto 0);
      instr_AWPROT  : out std_logic_vector(2 downto 0);
      instr_AWVALID : out std_logic;
      instr_AWREADY : in  std_logic                    := '-';
      instr_WID     : out std_logic_vector(3 downto 0);
      instr_WDATA   : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      instr_WSTRB   : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      instr_WLAST   : out std_logic;
      instr_WVALID  : out std_logic;
      instr_WREADY  : in  std_logic                    := '-';
      instr_BID     : in  std_logic_vector(3 downto 0) := (others => '-');
      instr_BRESP   : in  std_logic_vector(1 downto 0) := (others => '-');
      instr_BVALID  : in  std_logic                    := '-';
      instr_BREADY  : out std_logic;


      global_interrupts : in std_logic_vector(NUM_EXT_INTERRUPTS-1 downto 0) := (others => '0')
      );
  end component orca;

  component orca_core is
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
      LVE_ENABLE         : natural range 0 to 1;
      NUM_EXT_INTERRUPTS : integer range 0 to 32;
      SCRATCHPAD_SIZE    : integer;
      FAMILY             : string);
    port(
      clk            : in std_logic;
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
  end component orca_core;

  component decode is
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
  end component decode;

  component execute is
    generic(
      REGISTER_SIZE       : positive;
      SIGN_EXTENSION_SIZE : positive;
      RESET_VECTOR        : integer;
      MULTIPLY_ENABLE     : boolean;
      DIVIDE_ENABLE       : boolean;
      SHIFTER_MAX_CYCLES  : natural;
      COUNTER_LENGTH      : natural;
      ENABLE_EXCEPTIONS   : boolean;
      SCRATCHPAD_SIZE     : integer;
      FAMILY              : string);
    port(
      clk            : in std_logic;
      scratchpad_clk : in std_logic;
      reset          : in std_logic;
      valid_input    : in std_logic;

      br_taken_in  : in std_logic;
      pc_current   : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      instruction  : in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      subseq_instr : in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      subseq_valid : in std_logic;

      rs1_data       : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      rs2_data       : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      sign_extension : in std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);

      wb_sel       : buffer std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
      wb_data      : buffer std_logic_vector(REGISTER_SIZE-1 downto 0);
      wb_enable    : buffer std_logic;
      valid_output : out    std_logic;

      branch_pred        : out    std_logic_vector(REGISTER_SIZE*2+3-1 downto 0);
      stall_from_execute : buffer std_logic;




      --memory-bus
      address   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      byte_en   : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      write_en  : out std_logic;
      read_en   : out std_logic;
      writedata : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      readdata  : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_ack  : in  std_logic;

      external_interrupts : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      pipeline_empty      : in  std_logic;
      ifetch_next_pc      : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      interrupt_pending   : out std_logic);
  end component execute;

  component instruction_fetch is
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

      instr_out   : out    std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      pc_out      : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      next_pc_out : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      br_taken    : buffer std_logic;

      valid_instr_out : out std_logic;

      read_address   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      read_en        : out std_logic;
      read_data      : in  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      read_datavalid : in  std_logic;
      read_wait      : in  std_logic);
  end component instruction_fetch;

  component arithmetic_unit is
    generic (
      REGISTER_SIZE       : integer;
      SIGN_EXTENSION_SIZE : integer;
      MULTIPLY_ENABLE     : boolean;
      DIVIDE_ENABLE       : boolean;
      SHIFTER_MAX_CYCLES  : natural;
      FAMILY              : string);
    port (
      clk                : in  std_logic;
      stall_to_alu       : in  std_logic;
      stall_from_execute : in  std_logic;
      valid_instr        : in  std_logic;
      rs1_data           : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      rs2_data           : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      instruction        : in  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      sign_extension     : in  std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);
      program_counter    : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_out           : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_out_valid     : out std_logic;
      less_than          : out std_logic;
      stall_from_alu     : out std_logic;

      lve_data1        : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      lve_data2        : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      lve_source_valid : in std_logic
      );
  end component arithmetic_unit;

  component branch_unit is
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
      data_out       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_out_en    : out std_logic;
      is_branch      : out std_logic;
      br_taken_out   : out std_logic;
      new_pc         : out std_logic_vector(REGISTER_SIZE-1 downto 0);  --next pc
      bad_predict    : out std_logic
      );
  end component branch_unit;

  component load_store_unit is
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
      write_en       : out    std_logic;
      read_en        : out    std_logic;
      write_data     : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      read_data      : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
      ack            : in     std_logic);
  end component load_store_unit;

  component register_file
    generic(
      REGISTER_SIZE      : positive;
      REGISTER_NAME_SIZE : positive);
    port(
      clk         : in std_logic;
      valid_input : in std_logic;
      rs1_sel     : in std_logic_vector(REGISTER_NAME_SIZE -1 downto 0);
      rs2_sel     : in std_logic_vector(REGISTER_NAME_SIZE -1 downto 0);
      wb_sel      : in std_logic_vector(REGISTER_NAME_SIZE -1 downto 0);
      wb_data     : in std_logic_vector(REGISTER_SIZE -1 downto 0);
      wb_enable   : in std_logic;
      wb_valid    : in std_logic;

      rs1_data : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      rs2_data : out std_logic_vector(REGISTER_SIZE -1 downto 0)
      );
  end component register_file;

  component upper_immediate is
    generic (
      REGISTER_SIZE : positive);
    port (
      clk         : in  std_logic;
      valid       : in  std_logic;
      instr       : in  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      pc_current  : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_out    : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_enable : out std_logic);
  end component upper_immediate;

  component system_calls is
    generic (
      REGISTER_SIZE     : natural;
      RESET_VECTOR      : integer;
      COUNTER_LENGTH    : natural;
      ENABLE_EXCEPTIONS : boolean);
    port (
      clk         : in std_logic;
      reset       : in std_logic;
      valid       : in std_logic;
      stall_in    : in std_logic;
      rs1_data    : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      instruction : in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);

      wb_data   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      wb_enable : out std_logic;

      current_pc    : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      pc_correction : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      pc_corr_en    : out std_logic;

      interrupt_pending   : out std_logic;
      pipeline_empty      : in  std_logic;
      external_interrupts : in  std_logic_vector(REGISTER_SIZE-1 downto 0);


      instruction_fetch_pc : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      br_bad_predict       : in std_logic;
      br_new_pc            : in std_logic_vector(REGISTER_SIZE-1 downto 0)
      );
  end component system_calls;

  component lve_top is
    generic(
      REGISTER_SIZE    : natural;
      SLAVE_DATA_WIDTH : natural;
      SCRATCHPAD_SIZE  : integer;
      FAMILY           : string);
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
  end component;

end package rv_components;
