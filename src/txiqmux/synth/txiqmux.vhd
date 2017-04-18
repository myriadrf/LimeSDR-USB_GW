-- ----------------------------------------------------------------------------	
-- FILE: 	txiqmux.vhd
-- DESCRIPTION:	describe file
-- DATE:	Jan 27, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity txiqmux is
   generic(
      diq_width   : integer := 12
   );
   port (

      clk            	: in std_logic;
      reset_n        	: in std_logic;
      test_ptrn_en   	: in std_logic;   -- Enables test pattern
      test_ptrn_fidm 	: in std_logic;   -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
		test_ptrn_I			: in std_logic_vector(15 downto 0);
		test_ptrn_Q			: in std_logic_vector(15 downto 0);
		test_data_en		: in std_logic;
		test_data_mimo_en : in std_logic;
      mux_sel        	: in std_logic;   -- Mux select: 0 - tx, 1 - wfm
      tx_diq_h       	: in std_logic_vector(diq_width downto 0);
      tx_diq_l       	: in std_logic_vector(diq_width downto 0);
      wfm_diq_h      	: in std_logic_vector(diq_width downto 0);
      wfm_diq_l      	: in std_logic_vector(diq_width downto 0);
      diq_h          	: out std_logic_vector(diq_width downto 0);
      diq_l          	: out std_logic_vector(diq_width downto 0)

        );
end txiqmux;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of txiqmux is
--declare signals,  components here
signal test_ptrn_en_sync   : std_logic;
signal mux_sel_sync        : std_logic;
signal isnt0_diq_h         : std_logic_vector(diq_width downto 0);
signal isnt0_diq_l         : std_logic_vector(diq_width downto 0);

--inst1 
signal inst1_data_h			: std_logic_vector(diq_width downto 0);
signal inst1_data_l			: std_logic_vector(diq_width downto 0);


--First mux stage
signal mux0_diq_h          : std_logic_vector(diq_width downto 0);
signal mux0_diq_l          : std_logic_vector(diq_width downto 0);
signal mux0_diq_h_reg      : std_logic_vector(diq_width downto 0);
signal mux0_diq_l_reg      : std_logic_vector(diq_width downto 0);

--Second mux stage
signal mux1_diq_h          : std_logic_vector(diq_width downto 0);
signal mux1_diq_l          : std_logic_vector(diq_width downto 0);
signal mux1_diq_h_reg      : std_logic_vector(diq_width downto 0);
signal mux1_diq_l_reg      : std_logic_vector(diq_width downto 0);

--Third mux stage
signal mux2_diq_h          : std_logic_vector(diq_width downto 0);
signal mux2_diq_l          : std_logic_vector(diq_width downto 0);
signal mux2_diq_h_reg      : std_logic_vector(diq_width downto 0);
signal mux2_diq_l_reg      : std_logic_vector(diq_width downto 0);

  
begin

sync_reg0 : entity work.sync_reg
port map(clk, '1', test_ptrn_en, test_ptrn_en_sync);

sync_reg1 : entity work.sync_reg
port map(clk, '1', mux_sel, mux_sel_sync);


tst_ptrn_inst0 : entity work.txiq_tst_ptrn
   generic map(
      diq_width   => diq_width
   )
   port map(

      clk      => clk,
      reset_n  => reset_n,
      fidm     => test_ptrn_fidm,
		ptrn_i	=> test_ptrn_I,
		ptrn_q	=> test_ptrn_Q,
      diq_h    => isnt0_diq_h,
      diq_l    => isnt0_diq_l
        );
        
-- ----------------------------------------------------------------------------
-- Mux 0, between tx data and wfm
-- ----------------------------------------------------------------------------        
mux0_diq_h <= tx_diq_h when mux_sel_sync = '0' else wfm_diq_h;
mux0_diq_l <= tx_diq_l when mux_sel_sync = '0' else wfm_diq_l;

 mux0_reg : process(reset_n, clk)
    begin
      if reset_n='0' then
         mux0_diq_h_reg <= (others=>'0');
         mux0_diq_l_reg <= (others=>'0');
      elsif (clk'event and clk = '1') then
 	      mux0_diq_h_reg <= mux0_diq_h;
 	      mux0_diq_l_reg <= mux0_diq_l;         
 	    end if;
    end process;
    
-- ----------------------------------------------------------------------------
-- Mux 1, Mux 0 data and test pattern
-- ----------------------------------------------------------------------------        
mux1_diq_h <= mux0_diq_h_reg when test_ptrn_en_sync = '0' else isnt0_diq_h;
mux1_diq_l <= mux0_diq_l_reg when test_ptrn_en_sync = '0' else isnt0_diq_l;

 mux1_reg : process(reset_n, clk)
    begin
      if reset_n='0' then
         mux1_diq_h_reg <= (others=>'0');
         mux1_diq_l_reg <= (others=>'0');
      elsif (clk'event and clk = '1') then
 	      mux1_diq_h_reg <= mux1_diq_h;
 	      mux1_diq_l_reg <= mux1_diq_l;         
 	    end if;
    end process;
	 
	 
	 
test_data_dd_inst1 : entity work.test_data_dd
  PORT MAP(
			clk       		=> clk,
			reset_n   		=> reset_n,
			fr_start	 		=> test_ptrn_fidm,
			mimo_en			=> test_data_mimo_en,
			data_h		  	=> inst1_data_h,
			data_l		  	=> inst1_data_l
        );
		  
-- ----------------------------------------------------------------------------
-- Mux 2, Mux 1 data and test data
-- ----------------------------------------------------------------------------        
mux2_diq_h <= mux1_diq_h_reg when test_data_en = '0' else inst1_data_l;
mux2_diq_l <= mux1_diq_l_reg when test_data_en = '0' else inst1_data_h;

 mux2_reg : process(reset_n, clk)
    begin
      if reset_n='0' then
         mux2_diq_h_reg <= (others=>'0');
         mux2_diq_l_reg <= (others=>'0');
      elsif (clk'event and clk = '1') then
 	      mux2_diq_h_reg <= mux2_diq_h;
 	      mux2_diq_l_reg <= mux2_diq_l;         
 	    end if;
    end process;
    
-- ----------------------------------------------------------------------------
-- To output ports
-- ----------------------------------------------------------------------------     
diq_h <= mux2_diq_h_reg;
diq_l <= mux2_diq_l_reg; 
  
end arch;   





