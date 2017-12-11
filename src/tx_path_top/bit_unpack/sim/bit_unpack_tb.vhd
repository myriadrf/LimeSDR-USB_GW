-- ----------------------------------------------------------------------------	
-- FILE: 	bit_pack_tb.vhd
-- DESCRIPTION:	
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity bit_unpack_tb is
end bit_unpack_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of bit_unpack_tb is
   constant clk0_period   : time := 10 ns;
   constant clk1_period   : time := 10 ns; 
   --signals
	signal clk0,clk1		: std_logic;
	signal reset_n       : std_logic; 
   
   --dut0
   signal dut0_data_in           : std_logic_vector(63 downto 0);
   signal dut0_data_in_valid     : std_logic;
   signal dut0_sample_width      : std_logic_vector(1 downto 0):="01"; --"10"-12bit, "01"-14bit, "00"-16bit;
   
   signal dut0_data_out          : std_logic_vector(63 downto 0);
   signal dut0_data_out_valid    : std_logic;
   
   --dut1
   signal dut1_n                 : std_logic_vector(7 downto 0):=x"00";
   signal dut1_pulse_out         : std_logic;
   
   --dut2
   signal dut2_rdreq             : std_logic;
   signal dut2_q                 : std_logic_vector(31 downto 0);
   signal dut2_rdempty           : std_logic;
   
   --dut3
   signal dut3_data_in_valid     : std_logic;
   
   
   
   
   signal data_wrreq             : std_logic;
   
   signal data12_0               : unsigned(11 downto 0);
   signal data12_1               : unsigned(11 downto 0);
   signal data12_2               : unsigned(11 downto 0);
   signal data12_3               : unsigned(11 downto 0);
                  
   signal data14_0               : unsigned(13 downto 0);
   signal data14_1               : unsigned(13 downto 0);
   signal data14_2               : unsigned(13 downto 0);
   signal data14_3               : unsigned(13 downto 0);
                  
   signal data16_0               : unsigned(15 downto 0);
   signal data16_1               : unsigned(15 downto 0);
   signal data16_2               : unsigned(15 downto 0);
   signal data16_3               : unsigned(15 downto 0);
   
   
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
   
   
   
   
   ---------------------------------------------------------------------------------------------------
   --! Process description
   ---------------------------------------------------------------------------------------------------
   DATA12_CNT : process(reset_n, clk0)
   begin
      if reset_n = '0' then 
         data12_0<=(others=>'0');
         data12_1<=(others=>'0');
         data12_2<=(others=>'0');
         data12_3<=(others=>'0');  
      elsif (clk0'event and clk0 = '1') then
         if data_wrreq='1' then   
            data12_0 <= data12_0+4;
            data12_1 <= data12_0+5;
            data12_2 <= data12_0+6;
            data12_3 <= data12_0+7; 
         else 
            data12_0 <= data12_0;
            data12_1 <= data12_1;
            data12_2 <= data12_2;
            data12_3 <= data12_3; 
         end if;
      end if;
   end process;
   
   ---------------------------------------------------------------------------------------------------
   --! Process description
   ---------------------------------------------------------------------------------------------------
   DATA14_CNT : process(reset_n, clk0)
   begin
      if reset_n = '0' then 
         data14_0<=(others=>'0');
         data14_1<=(others=>'0');
         data14_2<=(others=>'0');
         data14_3<=(others=>'0');  
      elsif (clk0'event and clk0 = '1') then
         if data_wrreq='1' then   
            data14_0 <= data14_0+4;
            data14_1 <= data14_0+5;
            data14_2 <= data14_0+6;
            data14_3 <= data14_0+7; 
         else 
            data14_0 <= data14_0;
            data14_1 <= data14_1;
            data14_2 <= data14_2;
            data14_3 <= data14_3; 
         end if;
      end if;
   end process;
   
   ---------------------------------------------------------------------------------------------------
   --! Process description
   ---------------------------------------------------------------------------------------------------
   DATA16_CNT : process(reset_n, clk0)
   begin
      if reset_n = '0' then 
         data16_0<=(others=>'0');
         data16_1<=(others=>'0');
         data16_2<=(others=>'0');
         data16_3<=(others=>'0');  
      elsif (clk0'event and clk0 = '1') then
         if data_wrreq='1' then   
            data16_0 <= data16_0+4;
            data16_1 <= data16_0+5;
            data16_2 <= data16_0+6;
            data16_3 <= data16_0+7; 
         else 
            data16_0 <= data16_0;
            data16_1 <= data16_1;
            data16_2 <= data16_2;
            data16_3 <= data16_3; 
         end if;
      end if;
   end process;
   
   
   dut0_data_in <=   ("0000000000000000" & std_logic_vector(data12_3) & std_logic_vector(data12_2) & std_logic_vector(data12_1) & std_logic_vector(data12_0)) when dut0_sample_width="10" else 
                     ("00000000" & std_logic_vector(data14_3) & std_logic_vector(data14_2) & std_logic_vector(data14_1) & std_logic_vector(data14_0)) when dut0_sample_width="01" else 
                     (std_logic_vector(data16_3) & std_logic_vector(data16_2) & std_logic_vector(data16_1) & std_logic_vector(data16_0)); 
  
  dut0_data_in_valid <= data_wrreq;
  
  bit_pack_dut0 : entity work.bit_pack 
port map(
        clk             => clk0,
        reset_n         => reset_n,
        data_in         => dut0_data_in,
        data_in_valid   => dut0_data_in_valid,
        sample_width    => dut0_sample_width,
        data_out        => dut0_data_out,
        data_out_valid  => dut0_data_out_valid
);	

pulse_gen_dut1 : entity work.pulse_gen
port map (
         clk         => clk0,
         reset_n     => reset_n,
         n           => dut1_n, 
         pulse_out   => dut1_pulse_out
               
);

dut2_rdreq <= not dut2_rdempty;

fifo_inst_dut2 : entity work.fifo_inst
  generic map(
         dev_family	    => "Cyclone IV E",
         wrwidth         => 64,
         wrusedw_witdth  => 11, --12=2048 words 
         rdwidth         => 32,
         rdusedw_width   => 11,
         show_ahead      => "OFF"
  ) 
  port map(
      --input ports 
      reset_n       => reset_n,
      wrclk         => clk0,
      wrreq         => dut0_data_out_valid,
      data          => dut0_data_out,
      wrfull        => open,
		wrempty		  => open,
      wrusedw       => open,
      rdclk 	     => clk0,
      rdreq         => dut2_rdreq,
      q             => dut2_q,
      rdempty       => dut2_rdempty,
      rdusedw       => open          
        );
        
        
        
proc_name : process(clk0, reset_n)
begin
   if reset_n = '0' then 
      dut3_data_in_valid <= '0';
   elsif (clk0'event AND clk0='1') then 
      dut3_data_in_valid <= dut2_rdreq;
   end if;
end process;
        
               
  bit_unpack_dut3 : entity work.bit_unpack 
port map(
        clk             => clk0,
        reset_n         => reset_n,
        data_in         => dut2_q,
        data_in_valid   => dut3_data_in_valid,
        sample_width    => dut0_sample_width,
        data_out        => open,
        data_out_valid  => open
);


data_wrreq<=dut1_pulse_out;

	end tb_behave;
  
  


  
