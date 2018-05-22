-- ----------------------------------------------------------------------------	
-- FILE: 	p2d_wr_fsm_tb.vhd
-- DESCRIPTION:	
-- DATE:	March 31, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FIFO_PACK.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity p2d_wr_fsm_tb is
end p2d_wr_fsm_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of p2d_wr_fsm_tb is
constant clk0_period   : time := 10 ns;
constant clk1_period   : time := 48 ns; 
   --signals
signal clk0,clk1		: std_logic;
signal reset_n       : std_logic; 


constant N_BUFF                  : integer := 4;
constant C_PACKET_SIZE           : integer := 48;



-- 
constant C_PCT_WR_WIDTH          : integer := 32;
constant C_PCT_RD_WIDTH          : integer := 128;
constant C_PCT_FIFO_SIZE         : integer := 4096; -- packet FIFO size in bytes
constant C_PCT_WRUSEDW_WIDTH     : integer := FIFO_WORDS_TO_Nbits((C_PCT_FIFO_SIZE*8)/C_PCT_WR_WIDTH, true);
constant C_PCT_RDUSEDW_WIDTH     : integer := FIFORD_SIZE(C_PCT_WR_WIDTH, C_PCT_RD_WIDTH, C_PCT_WRUSEDW_WIDTH); 

constant C_PACKET_WORDS          : integer := (C_PACKET_SIZE*8)/C_PCT_WR_WIDTH;

   
--dut0 signals
signal dut0_wrreq                : std_logic;  
signal dut0_data                 : std_logic_vector(C_PCT_WR_WIDTH-1 downto 0);
signal dut0_wrempty              : std_logic;
  
--dut1
signal dut1_in_pct_rdy           : std_logic;
signal dut1_pct_size             : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned((C_PACKET_SIZE*8)/C_PCT_RD_WIDTH,16));
signal dut1_in_pct_rdreq         : std_logic;
signal dut1_pct_data_wrreq       : std_logic_vector(N_BUFF-1 downto 0);
signal dut1_pct_buff_rdy         : std_logic_vector(N_BUFF-1 downto 0) := "1111";
   
signal dut0_q                    : std_logic_vector(C_PCT_RD_WIDTH-1 downto 0);
signal dut0_rdusedw              : std_logic_vector(C_PCT_RDUSEDW_WIDTH-1 downto 0);
   
  

begin 
  
      clock0: process is
	begin
		clk0 <= '0'; wait for clk0_period/2;
		clk0 <= '1'; wait for clk0_period/2;
	end process clock0;

   	clock: process is
	begin
		clk1 <= '0'; wait for clk1_period/2;
		clk1 <= '1'; wait for clk1_period/2;
	end process clock;
	
		res: process is
	begin
		reset_n <= '0'; wait for 20 ns;
		reset_n <= '1'; wait;
	end process res;
   
   process is 
   begin
      dut0_wrreq <= '0';
      wait until rising_edge(clk0) AND reset_n = '1';
         if dut0_wrempty = '1' then 
            for i in 0 to C_PACKET_WORDS loop 
               wait until rising_edge(clk0);
               dut0_wrreq <= '1';
            end loop;
         end if;
      
   end process;
   
   proc_name : process(clk0, reset_n)
   begin
      if reset_n = '0' then 
         dut0_data <= (others=>'0');
      elsif (clk0'event AND clk0='1') then 
         if dut0_wrreq = '1' then 
            dut0_data <= std_logic_vector(unsigned(dut0_data)+1);
         else 
            dut0_data <= (others=>'0');
         end if;
      end if;
   end process;
    
    
    
   dut0_fifo_inst : entity work.fifo_inst
   generic map(
      dev_family     => "Cyclone IV E",
      wrwidth        => C_PCT_WR_WIDTH,
      wrusedw_witdth => C_PCT_WRUSEDW_WIDTH, 
      rdwidth        => C_PCT_RD_WIDTH,
      rdusedw_width  => C_PCT_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   )  
  port map(
      --input ports 
      reset_n  => reset_n,
      wrclk    => clk0,
      wrreq    => dut0_wrreq,
      data     => dut0_data,
      wrfull   => open,
      wrempty  => dut0_wrempty,
      wrusedw  => open,
      rdclk    => clk1,
      rdreq    => dut1_in_pct_rdreq,
      q        => dut0_q,
      rdempty  => open,
      rdusedw  => dut0_rdusedw
   );
   
   dut1_in_pct_rdy <= '1' when unsigned(dut0_rdusedw) = (C_PACKET_SIZE*8)/C_PCT_RD_WIDTH else '0';
 

  
  p2d_wr_fsm_dut1 : entity work.p2d_wr_fsm
   generic map(
      N_BUFF            => N_BUFF,
      PCT_SIZE          => C_PACKET_SIZE
   )
   port map(
      clk               => clk1,
      reset_n           => reset_n,
      
      in_pct_rdreq      => dut1_in_pct_rdreq,
      in_pct_data       => dut0_q,
      in_pct_rdy        => dut1_in_pct_rdy,

      pct_hdr_0         => open,
      pct_hdr_0_valid   => open,

      pct_hdr_1         => open,
      pct_hdr_1_valid   => open,
      
      pct_data          => open,
      pct_data_wrreq    => dut1_pct_data_wrreq,
      
      pct_buff_rdy      => dut1_pct_buff_rdy
      );
      
   gen : for i in 0 to N_BUFF-1 generate
      process 
      begin
         wait until rising_edge(dut1_pct_data_wrreq(i));
         dut1_pct_buff_rdy(i) <= not dut1_pct_buff_rdy(i);
      end process;
   end generate gen;
      
	end tb_behave;
  
  


  
