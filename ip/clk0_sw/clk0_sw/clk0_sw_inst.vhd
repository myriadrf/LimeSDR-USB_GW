	component clk0_sw is
		port (
			inclk2x   : in  std_logic                    := 'X';             -- inclk2x
			inclk1x   : in  std_logic                    := 'X';             -- inclk1x
			inclk0x   : in  std_logic                    := 'X';             -- inclk0x
			clkselect : in  std_logic_vector(1 downto 0) := (others => 'X'); -- clkselect
			outclk    : out std_logic                                        -- outclk
		);
	end component clk0_sw;

	u0 : component clk0_sw
		port map (
			inclk2x   => CONNECTED_TO_inclk2x,   --  altclkctrl_input.inclk2x
			inclk1x   => CONNECTED_TO_inclk1x,   --                  .inclk1x
			inclk0x   => CONNECTED_TO_inclk0x,   --                  .inclk0x
			clkselect => CONNECTED_TO_clkselect, --                  .clkselect
			outclk    => CONNECTED_TO_outclk     -- altclkctrl_output.outclk
		);

