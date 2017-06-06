library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library work;
use work.rv_components.all;
use work.utils.all;

entity Orca is
  generic (
    REGISTER_SIZE   : integer              := 32;
    --BUS Select
    AVALON_ENABLE   : integer range 0 to 1 := 0;
    WISHBONE_ENABLE : integer range 0 to 1 := 0;
    AXI_ENABLE      : integer range 0 to 1 := 0;

    RESET_VECTOR          : integer               := 16#00000200#;
    MULTIPLY_ENABLE       : natural range 0 to 1  := 0;
    DIVIDE_ENABLE         : natural range 0 to 1  := 0;
    SHIFTER_MAX_CYCLES    : natural               := 1;
    COUNTER_LENGTH        : natural               := 0;
    ENABLE_EXCEPTIONS     : natural               := 1;
    BRANCH_PREDICTORS     : natural               := 0;
    PIPELINE_STAGES       : natural range 4 to 5  := 5;
    LVE_ENABLE            : natural range 0 to 1  := 0;
    ENABLE_EXT_INTERRUPTS : natural range 0 to 1  := 0;
    NUM_EXT_INTERRUPTS    : integer range 1 to 32 := 1;
    SCRATCHPAD_SIZE       : integer               := 1024;
    FAMILY                : string                := "ALTERA");

  port(clk            : in std_logic;
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
       data_AWREADY : in  std_logic := '0';  -- Slave is ready to accept address and control signals

       -- Write data channel ------------------------------------------------------------
       data_WID    : out std_logic_vector(3 downto 0);  -- ID for write data signals
       data_WDATA  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
       data_WSTRB  : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);  -- Specifies which byte lanes contain valid information
       data_WLAST  : out std_logic;  -- Asserted when master is driving the final write transfer in the burst
       data_WVALID : out std_logic;  -- Valid data available on bus, asserted until slave asserts WREADY
       data_WREADY : in  std_logic;  -- Slave is now available to accept write data

       -- Write response channel ---------------------------------------------------------
       data_BID    : in  std_logic_vector(3 downto 0);  -- ID for write response
       data_BRESP  : in  std_logic_vector(1 downto 0);  -- Slave response (with error codes) to a write
       data_BVALID : in  std_logic;  -- Indicates that the channel is signaling a valid write response
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
       data_ARREADY : in  std_logic;

       -- Read data channel -----------------------------------------------------------------
       data_RID    : in  std_logic_vector(3 downto 0);
       data_RDATA  : in  std_logic_vector(REGISTER_SIZE -1 downto 0);
       data_RRESP  : in  std_logic_vector(1 downto 0);
       data_RLAST  : in  std_logic;
       data_RVALID : in  std_logic;
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
       instr_ARREADY : in  std_logic;

       -- Read data channel -----------------------------------------------------------------
       instr_RID    : in  std_logic_vector(3 downto 0);
       instr_RDATA  : in  std_logic_vector(REGISTER_SIZE -1 downto 0);
       instr_RRESP  : in  std_logic_vector(1 downto 0);
       instr_RLAST  : in  std_logic;
       instr_RVALID : in  std_logic;
       instr_RREADY : out std_logic;

       -- INSTRUCTION Write address channel ---------------------------------------------------------
       -- these channels are not used, but need to be there for qsys

       instr_AWID    : out std_logic_vector(3 downto 0);
       instr_AWADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
       instr_AWLEN   : out std_logic_vector(3 downto 0);
       instr_AWSIZE  : out std_logic_vector(2 downto 0);
       instr_AWBURST : out std_logic_vector(1 downto 0);
       instr_AWLOCK  : out std_logic_vector(1 downto 0);
       instr_AWCACHE : out std_logic_vector(3 downto 0);
       instr_AWPROT  : out std_logic_vector(2 downto 0);
       instr_AWVALID : out std_logic;
       instr_AWREADY : in  std_logic := '0';
       instr_WID     : out std_logic_vector(3 downto 0);
       instr_WDATA   : out std_logic_vector(REGISTER_SIZE -1 downto 0);
       instr_WSTRB   : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
       instr_WLAST   : out std_logic;
       instr_WVALID  : out std_logic;
       instr_WREADY  : in  std_logic;
       instr_BID     : in  std_logic_vector(3 downto 0);
       instr_BRESP   : in  std_logic_vector(1 downto 0);
       instr_BVALID  : in  std_logic;
       instr_BREADY  : out std_logic;


       global_interrupts : in std_logic_vector(NUM_EXT_INTERRUPTS-1 downto 0) := (others => '0')
       );

end entity Orca;

architecture rtl of Orca is

  signal core_data_address    : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal core_data_byteenable : std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
  signal core_data_read       : std_logic;
  signal core_data_readdata   : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal core_data_write      : std_logic;
  signal core_data_writedata  : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal core_data_ack        : std_logic;

  signal core_instruction_address       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal core_instruction_read          : std_logic;
  signal core_instruction_readdata      : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal core_instruction_waitrequest   : std_logic;
  signal core_instruction_readdatavalid : std_logic;



begin  -- architecture rtl
  assert AVALON_ENABLE + WISHBONE_ENABLE + AXI_ENABLE = 1 report "Exactly one bus type must be enabled" severity failure;


  -----------------------------------------------------------------------------
  -- AVALON
  -----------------------------------------------------------------------------
  avalon_enabled : if AVALON_ENABLE = 1 generate
    signal is_writing : std_logic;
    signal is_reading : std_logic;
    signal write_ack  : std_logic;

  begin
    core_data_readdata <= avm_data_readdata;

    core_data_ack  <= avm_data_readdatavalid or write_ack;
    avm_data_write <= is_writing;
    avm_data_read  <= is_reading;
    process(clk)

    begin
      if rising_edge(clk) then


        if (is_writing or is_reading) = '1' and avm_data_waitrequest = '1' then

        else
          is_reading          <= core_data_read;
          avm_data_address    <= core_data_address;
          is_writing          <= core_data_write;
          avm_data_writedata  <= core_data_writedata;
          avm_data_byteenable <= core_data_byteenable;
        end if;

        write_ack <= '0';
        if is_writing = '1' and avm_data_waitrequest = '0' then
          write_ack <= '1';
        end if;
      end if;

    end process;

    avm_instruction_address        <= core_instruction_address;
    avm_instruction_read           <= core_instruction_read;
    core_instruction_readdata      <= avm_instruction_readdata;
    core_instruction_waitrequest   <= avm_instruction_waitrequest;
    core_instruction_readdatavalid <= avm_instruction_readdatavalid;
  end generate avalon_enabled;

  -----------------------------------------------------------------------------
  -- WISHBONE
  -----------------------------------------------------------------------------
  wishbone_enabled : if WISHBONE_ENABLE = 1 generate
    signal is_read_transaction : std_logic;
  begin
    core_data_readdata <= data_DAT_I;
    core_data_ack      <= data_ACK_I;

    instr_ADR_O                    <= core_instruction_address;
    instr_CYC_O                    <= core_instruction_read;
    instr_STB_O                    <= core_instruction_read;
    core_instruction_readdata      <= instr_DAT_I;
    core_instruction_waitrequest   <= instr_STALL_I;
    core_instruction_readdatavalid <= instr_ACK_I;

    process(clk)
    begin
      if rising_edge(clk) then
        if data_STALL_I = '0' then
          data_ADR_O <= core_data_address;
          data_SEL_O <= core_data_byteenable;
          data_CYC_O <= core_data_read or core_data_write;
          data_STB_O <= core_data_read or core_data_write;
          data_WE_O  <= core_data_write;
          data_DAT_O <= core_data_writedata;
        end if;
      end if;
    end process;

  end generate wishbone_enabled;

  axi_enabled : if AXI_ENABLE = 1 generate
    -- 1 transfer
    constant BURST_LEN  : std_logic_vector(3 downto 0) := "0000";
    -- 4 bytes in transfer
    constant BURST_SIZE : std_logic_vector(2 downto 0) := "010";
    -- incremental bursts
    constant BURST_INCR : std_logic_vector(1 downto 0) := "01";


    signal core_data_stall1        : std_logic;
    signal core_data_stall2        : std_logic;
    signal core_data_stall3        : std_logic;
    signal write_ack               : std_logic;
    signal core_instruction_stall4 : std_logic;

    type state_t is (IDLE, WRITE_ADDR, WRITE_DATA);
    signal state : state_t;
  begin

--BUG: this combinational logic assumes that AWREADY and WREADY are the same signal
--BUG: this logic disregards the write response data

    data_AWID        <= (others => '0');
    data_AWADDR      <= core_data_address;
    data_AWLEN       <= BURST_LEN;
    data_AWSIZE      <= BURST_SIZE;
    data_AWBURST     <= BURST_INCR;
    data_AWLOCK      <= (others => '0');
    data_AWCACHE     <= (others => '0');
    data_AWPROT      <= (others => '0');
    data_AWVALID     <= core_data_write when (state /= WRITE_DATA) else '0';
    core_data_stall1 <= not data_AWREADY;
    data_WID         <= (others => '0');
    data_WDATA       <= core_data_writedata;
    data_WSTRB       <= core_data_byteenable;
    data_WLAST       <= '1';
    data_WVALID      <= core_data_write when (state /= WRITE_ADDR) else '0';
    core_data_stall2 <= data_WREADY;
    --data_BID
    --data_BRESP
    --data_BVALID
    data_BREADY      <= '1';


    data_ARID          <= (others => '0');
    data_ARADDR        <= core_data_address;
    data_ARLEN         <= BURST_LEN;
    data_ARSIZE        <= BURST_SIZE;
    data_ARBURST       <= BURST_INCR;
    data_ARLOCK        <= (others => '0');
    data_ARCACHE       <= (others => '0');
    data_ARPROT        <= (others => '0');
    data_ARVALID       <= core_data_read;
    core_data_stall3   <= not data_ARREADY;
    -- data_RID
    core_data_readdata <= data_RDATA;
    -- data_RRESP
    -- data_RLAST
    core_data_ack      <= data_RVALID or write_ack;
    data_RREADY        <= '1';

    -- This Process handles coupling the decoupled write data and write address channels
    data_write_proc : process(clk)
    begin
      if rising_edge(clk) then
        write_ack <= '0';
        case state is
          when IDLE =>
            if core_data_write = '1' then
              write_ack <= data_AWREADY and data_WREADY;
              if (data_AWREADY and not data_WREADY) = '1' then
                state <= WRITE_DATA;
              elsif (not data_AWREADY and data_WREADY) = '1' then
                state <= WRITE_ADDR;
              end if;
            end if;
          when WRITE_ADDR =>
            if data_AWREADY = '1' then
              state     <= IDLE;
              write_ack <= '1';
            end if;
          when WRITE_DATA =>
            if data_WREADY = '1' then
              state     <= IDLE;
              write_ack <= '1';
            end if;
          when others => null;
        end case;
        if reset = '1' then
          state <= IDLE;
        end if;
      end if;
    end process;

    --Instruction read port

    instr_ARID                     <= (others => '0');
    instr_ARADDR                   <= core_instruction_address;
    instr_ARLEN                    <= BURST_LEN;
    instr_ARSIZE                   <= BURST_SIZE;
    instr_ARBURST                  <= BURST_INCR;
    instr_ARLOCK                   <= (others => '0');
    instr_ARCACHE                  <= (others => '0');
    instr_ARPROT                   <= (others => '0');
    instr_ARVALID                  <= core_instruction_read;
    core_instruction_stall4        <= not instr_ARREADY;
                                        -- instr_RID
    core_instruction_readdata      <= instr_RDATA;
                                        --instr_RRESP
                                        --instr_RLAST
    core_instruction_readdatavalid <= instr_RVALID;
    instr_RREADY                   <= '1';

    core_instruction_waitrequest <= core_instruction_stall4;

    instr_AWID    <= (others => '0');
    instr_AWADDR  <= (others => '0');
    instr_AWLEN   <= (others => '0');
    instr_AWSIZE  <= (others => '0');
    instr_AWBURST <= (others => '0');
    instr_AWLOCK  <= (others => '0');
    instr_AWCACHE <= (others => '0');
    instr_AWPROT  <= (others => '0');
    instr_AWVALID <= '0';
    instr_WID     <= (others => '0');
    instr_WDATA   <= (others => '0');
    instr_WSTRB   <= (others => '0');
    instr_WLAST   <= '0';
    instr_WVALID  <= '0';
    instr_BREADY  <= '1';


  end generate axi_enabled;

  core : component orca_core
    generic map(
      REGISTER_SIZE      => REGISTER_SIZE,
      RESET_VECTOR       => RESET_VECTOR,
      MULTIPLY_ENABLE    => MULTIPLY_ENABLE,
      DIVIDE_ENABLE      => DIVIDE_ENABLE,
      SHIFTER_MAX_CYCLES => SHIFTER_MAX_CYCLES,
      COUNTER_LENGTH     => COUNTER_LENGTH,
      ENABLE_EXCEPTIONS  => ENABLE_EXCEPTIONS,
      BRANCH_PREDICTORS  => BRANCH_PREDICTORS,
      PIPELINE_STAGES    => PIPELINE_STAGES,
      LVE_ENABLE         => LVE_ENABLE,
      NUM_EXT_INTERRUPTS => CONDITIONAL(ENABLE_EXT_INTERRUPTS > 0, NUM_EXT_INTERRUPTS, 0),
      SCRATCHPAD_SIZE    => SCRATCHPAD_SIZE,
      FAMILY             => FAMILY)

    port map(
      clk            => clk,
      scratchpad_clk => scratchpad_clk,
      reset          => reset,

                                        --avalon master bus
      core_data_address              => core_data_address,
      core_data_byteenable           => core_data_byteenable,
      core_data_read                 => core_data_read,
      core_data_readdata             => core_data_readdata,
      core_data_write                => core_data_write,
      core_data_writedata            => core_data_writedata,
      core_data_ack                  => core_data_ack,
                                        --avalon master bus
      core_instruction_address       => core_instruction_address,
      core_instruction_read          => core_instruction_read,
      core_instruction_readdata      => core_instruction_readdata,
      core_instruction_waitrequest   => core_instruction_waitrequest,
      core_instruction_readdatavalid => core_instruction_readdatavalid,

      external_interrupts => global_interrupts(CONDITIONAL(ENABLE_EXT_INTERRUPTS > 0, NUM_EXT_INTERRUPTS, 0)-1 downto 0));




end architecture rtl;
