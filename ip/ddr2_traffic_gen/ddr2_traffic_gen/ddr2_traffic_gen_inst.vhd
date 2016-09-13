	component ddr2_traffic_gen is
		port (
			clk                 : in  std_logic                     := 'X';             -- clk
			reset_n             : in  std_logic                     := 'X';             -- reset_n
			pass                : out std_logic;                                        -- pass
			fail                : out std_logic;                                        -- fail
			test_complete       : out std_logic;                                        -- test_complete
			avl_ready           : in  std_logic                     := 'X';             -- waitrequest_n
			avl_addr            : out std_logic_vector(24 downto 0);                    -- address
			avl_size            : out std_logic_vector(1 downto 0);                     -- burstcount
			avl_wdata           : out std_logic_vector(31 downto 0);                    -- writedata
			avl_rdata           : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			avl_write_req       : out std_logic;                                        -- write
			avl_read_req        : out std_logic;                                        -- read
			avl_rdata_valid     : in  std_logic                     := 'X';             -- readdatavalid
			avl_be              : out std_logic_vector(3 downto 0);                     -- byteenable
			avl_burstbegin      : out std_logic;                                        -- beginbursttransfer
			pnf_per_bit         : out std_logic_vector(31 downto 0);                    -- pnf_per_bit
			pnf_per_bit_persist : out std_logic_vector(31 downto 0)                     -- pnf_per_bit_persist
		);
	end component ddr2_traffic_gen;

	u0 : component ddr2_traffic_gen
		port map (
			clk                 => CONNECTED_TO_clk,                 -- avl_clock.clk
			reset_n             => CONNECTED_TO_reset_n,             -- avl_reset.reset_n
			pass                => CONNECTED_TO_pass,                --    status.pass
			fail                => CONNECTED_TO_fail,                --          .fail
			test_complete       => CONNECTED_TO_test_complete,       --          .test_complete
			avl_ready           => CONNECTED_TO_avl_ready,           --       avl.waitrequest_n
			avl_addr            => CONNECTED_TO_avl_addr,            --          .address
			avl_size            => CONNECTED_TO_avl_size,            --          .burstcount
			avl_wdata           => CONNECTED_TO_avl_wdata,           --          .writedata
			avl_rdata           => CONNECTED_TO_avl_rdata,           --          .readdata
			avl_write_req       => CONNECTED_TO_avl_write_req,       --          .write
			avl_read_req        => CONNECTED_TO_avl_read_req,        --          .read
			avl_rdata_valid     => CONNECTED_TO_avl_rdata_valid,     --          .readdatavalid
			avl_be              => CONNECTED_TO_avl_be,              --          .byteenable
			avl_burstbegin      => CONNECTED_TO_avl_burstbegin,      --          .beginbursttransfer
			pnf_per_bit         => CONNECTED_TO_pnf_per_bit,         --       pnf.pnf_per_bit
			pnf_per_bit_persist => CONNECTED_TO_pnf_per_bit_persist  --          .pnf_per_bit_persist
		);

