-- ----------------------------------------------------------------------------
-- FILE:          pct_separate_tb.vhd
-- DESCRIPTION:   
-- DATE:          12:22 PM Tuesday, January 15, 2019
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pct_separate_tb is
end pct_separate_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of pct_separate_tb is
   constant clk0_period    : time := 10 ns;
   constant clk1_period    : time := 62 ns;
   
   --signals
   signal clk0,clk1        : std_logic;
   signal reset_n          : std_logic; 
   
   --inst0
   type integer_array is array (0 to 2) of integer;
   constant words_to_write    : integer_array := (6,10,18);
   signal pct_cnt             : integer := 0; 
   signal wr_cnt              : integer := 0;
   signal inst0_wrreq         : std_logic;
   signal inst0_data          : std_logic_vector(31 downto 0);
   signal inst0_rdreq         : std_logic;
   signal inst0_wrempty       : std_logic;
   signal inst0_q             : std_logic_vector(31 downto 0);
   signal inst0_rdempty       : std_logic;
   
   --inst1
   signal inst1_infifo_rdreq  : std_logic;
   signal inst1_pct_wrreq     : std_logic;
   signal inst1_pct_data      : std_logic_vector(31 downto 0);
   
   --inst2
   signal inst2_wrempty       : std_logic;
   signal inst2_rdreq         : std_logic;
   signal inst2_rdempty       : std_logic;
   
  
begin 
  
      clock0: process is
   begin
      clk0 <= '0'; wait for clk0_period/2;
      clk0 <= '1'; wait for clk0_period/2;
   end process clock0;

      clock1: process is
   begin
      clk1 <= '0'; wait for clk1_period/2;
      clk1 <= '1'; wait for clk1_period/2;
   end process clock1;
   
      res: process is
   begin
      reset_n <= '0'; wait for 20 ns;
      reset_n <= '1'; wait;
   end process res;
   
   wr_fifo_proc : process is 
   begin
      inst0_wrreq <= '0';
      wait until reset_n = '1';
      for i in 0 to 2 loop
         wait until rising_edge(clk0) AND inst0_wrempty='1';
         
         for j in 0 to words_to_write(i)-1 loop
            inst0_wrreq <= '1';
            wait until rising_edge(clk0);
         end loop;
         inst0_wrreq <= '0';
      end loop;
   end process;
   
   wr_cnt_proc : process is 
   begin
      wait until rising_edge(inst0_wrreq);
      wr_cnt <= 0;
      while inst0_wrreq = '1' loop
         wait until rising_edge(clk0);
         wr_cnt <= wr_cnt + 1;
      end loop;
   end process;
   
   pct_cnt_proc : process is 
   begin 
      pct_cnt <= 0;
      loop
      wait until falling_edge(inst0_wrreq);
      pct_cnt <= pct_cnt+1;
      if pct_cnt = 5 then 
         exit;
      end if;
      end loop;    
   end process;
   
   data_proc : process (wr_cnt, pct_cnt) 
   begin 
      if wr_cnt = 0 then
         inst0_data <= (others=>'0');
      inst0_data(23 downto 8) <= std_logic_vector(to_unsigned((words_to_write(pct_cnt)-4)*8,16));
      elsif wr_cnt = 1 then
         inst0_data <= (others=>'0');
      else 
         inst0_data <= std_logic_vector(to_unsigned(wr_cnt,32));
      end if;
   end process;
   
   
   -- Data fifo instance
   inst0_fifo : entity work.fifo_inst   
      generic map(
      dev_family     => "Cyclone IV",
      wrwidth        => 32,
      wrusedw_witdth => 10,
      rdwidth        => 32,
      rdusedw_width  => 10,   
      show_ahead     => "OFF"
   )
   port map(
      reset_n     => reset_n,
      wrclk       => clk0,
      wrreq       => inst0_wrreq,
      data        => inst0_data,
      wrfull      => open,
      wrempty     => inst0_wrempty,
      wrusedw     => open,
      rdclk       => clk0,
      rdreq       => inst1_infifo_rdreq,
      q           => inst0_q,
      rdempty     => inst0_rdempty,
      rdusedw     => open             
   );
   
   inst1_pct_separate : entity work.pct_separate
   generic map(
      g_DATA_WIDTH   => 32
   )
   port map(
      clk            => clk0,
      reset_n        => reset_n,
      infifo_rdreq   => inst1_infifo_rdreq,
      infifo_data    => inst0_q,
      infifo_rdempty => inst0_rdempty,
      pct_wrreq      => inst1_pct_wrreq,
      pct_data       => inst1_pct_data,
      pct_wrempty    => inst2_wrempty,
      pct_size       => open,
      pct_size_valid => open
   );
   
      -- Data fifo instance
   inst2_fifo : entity work.fifo_inst   
      generic map(
      dev_family     => "Cyclone IV",
      wrwidth        => 32,
      wrusedw_witdth => 10,
      rdwidth        => 32,
      rdusedw_width  => 10,   
      show_ahead     => "OFF"
   )
   port map(
      reset_n     => reset_n,
      wrclk       => clk0,
      wrreq       => inst1_pct_wrreq,
      data        => inst1_pct_data,
      wrfull      => open,
      wrempty     => inst2_wrempty,
      wrusedw     => open,
      rdclk       => clk1,
      rdreq       => inst2_rdreq,
      q           => open,
      rdempty     => inst2_rdempty,
      rdusedw     => open             
   );
   
   inst2_rdreq <= not inst2_rdempty;

end tb_behave;

