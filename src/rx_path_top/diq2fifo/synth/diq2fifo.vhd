-- ----------------------------------------------------------------------------	
-- FILE:    diq2fifo.vhd
-- DESCRIPTION:   Writes DIQ data to FIFO, FIFO word size = 4  DIQ samples 
-- DATE: Jan 13, 2016
-- AUTHOR(s): Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity diq2fifo is
   generic( 
      dev_family           : string := "Cyclone IV E";
      iq_width             : integer := 12;
      invert_input_clocks  : string := "ON"
      );
   port (
      clk            : in std_logic;
      reset_n        : in std_logic;
      test_ptrn_en   : in std_logic;
      --Mode settings
      mode           : in std_logic; -- JESD207: 1; TRXIQ: 0
      trxiqpulse     : in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
      ddr_en         : in std_logic; -- DDR: 1; SDR: 0
      mimo_en        : in std_logic; -- SISO: 1; MIMO: 0
      ch_en          : in std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
      fidm           : in std_logic; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      --Rx interface data 
      DIQ            : in std_logic_vector(iq_width-1 downto 0);
      fsync          : in std_logic;
      --fifo ports 
      fifo_wfull     : in std_logic;
      fifo_wrreq     : out std_logic;
      fifo_wdata     : out std_logic_vector(iq_width*4-1 downto 0);
      --sample compare
      smpl_cmp_start : in std_logic;
      smpl_cmp_length: in std_logic_vector(15 downto 0);
      smpl_cmp_done  : out std_logic;
      smpl_cmp_err   : out std_logic;
      -- sample counter enable
      smpl_cnt_en    : out std_logic

        );
end diq2fifo;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of diq2fifo is
--declare signals,  components here
signal inst0_diq_out_h  : std_logic_vector (iq_width downto 0); 
signal inst0_diq_out_l  : std_logic_vector (iq_width downto 0);
signal inst0_reset_n    : std_logic; 

signal inst2_data_h     : std_logic_vector (iq_width downto 0);
signal inst2_data_l     : std_logic_vector (iq_width downto 0);

signal inst3_reset_n    : std_logic; 

signal mux0_diq_h       : std_logic_vector (iq_width downto 0); 
signal mux0_diq_l       : std_logic_vector (iq_width downto 0);

signal mux0_diq_h_reg   : std_logic_vector (iq_width downto 0); 
signal mux0_diq_l_reg   : std_logic_vector (iq_width downto 0);

signal smpl_cnt_en_reg  : std_logic;
  
begin

inst0_reset_n <= reset_n when smpl_cmp_start = '0' else '1';

inst0_lms7002_ddin : entity work.lms7002_ddin
   generic map( 
      dev_family           => dev_family,
      iq_width             => iq_width,
      invert_input_clocks  => invert_input_clocks
   )
   port map (
      clk         => clk,
      reset_n     => inst0_reset_n, 
      rxiq        => DIQ, 
      rxiqsel     => fsync, 
      data_out_h  => inst0_diq_out_h, 
      data_out_l  => inst0_diq_out_l 
        );
        
   process(clk, inst0_reset_n)
   begin 
      if inst0_reset_n = '0' then 
         smpl_cnt_en_reg <= '0';
      elsif rising_edge(clk) then 
         if mimo_en = '0' AND ddr_en = '1' then 
            smpl_cnt_en_reg <= '1';
         else 
            smpl_cnt_en_reg <= not smpl_cnt_en_reg;
         end if;
      end if;
   end process;

        
inst1_rxiq : entity work.rxiq
   generic map( 
      dev_family           => dev_family,
      iq_width             => iq_width
   )
   port map (
      clk         => clk,
      reset_n     => reset_n,
      trxiqpulse  => trxiqpulse,
      ddr_en      => ddr_en,
      mimo_en     => mimo_en,
      ch_en       => ch_en, 
      fidm        => fidm,
      DIQ_h       => mux0_diq_h_reg,
      DIQ_l       => mux0_diq_l_reg,
      fifo_wfull  => fifo_wfull,
      fifo_wrreq  => fifo_wrreq,
      fifo_wdata  => fifo_wdata
        );
  
int2_test_data_dd : entity work.test_data_dd
port map(

   clk            => clk,
   reset_n        => reset_n,
   fr_start       => fidm,
   mimo_en        => mimo_en,  
   data_h         => inst2_data_h,
   data_l         => inst2_data_l

);


mux0_diq_h <= inst0_diq_out_h when test_ptrn_en = '0' else inst2_data_h;
mux0_diq_l <= inst0_diq_out_l when test_ptrn_en = '0' else inst2_data_l;	


process(clk, reset_n)
begin 
   if reset_n = '0' then 
      mux0_diq_h_reg <= (others=>'0');
      mux0_diq_l_reg <= (others=>'0');
   elsif (clk'event AND clk='1') then
      mux0_diq_h_reg <= mux0_diq_h;
      mux0_diq_l_reg <= mux0_diq_l;
   end if;
end process;


inst3_reset_n <= smpl_cmp_start;

inst3_smpl_cmp : entity work.smpl_cmp
   generic map(
      smpl_width  => iq_width
   )
   port map(

      clk         => clk,
      reset_n     => inst3_reset_n,
      --Mode settings
      mode        => mode,
      trxiqpulse  => trxiqpulse,
      ddr_en      => ddr_en,
      mimo_en     => mimo_en,
      ch_en       => ch_en,
      fidm        => fidm,
      --control and status
      cmp_start   => smpl_cmp_start,
      cmp_length  => smpl_cmp_length,
      cmp_AI      => x"AAA",
      cmp_AQ      => x"555",
      cmp_BI      => x"AAA",
      cmp_BQ      => x"555",
      cmp_done    => smpl_cmp_done,
      cmp_error   => smpl_cmp_err,
      --DIQ bus
      diq_h       => inst0_diq_out_h,
      diq_l       => inst0_diq_out_l
      );
      
      
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------   
  
   smpl_cnt_en <= smpl_cnt_en_reg;
 
end arch;   





