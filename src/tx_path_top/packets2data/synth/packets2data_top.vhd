-- ----------------------------------------------------------------------------	
-- FILE: 	packets2data_top.vhd
-- DESCRIPTION:	Reads data from packets.
-- DATE:	April 03, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	

-- ----------------------------------------------------------------------------
-- Notes:
-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity packets2data_top is
   generic (
      g_DEV_FAMILY      : string  := "Cyclone IV E";
      g_PCT_MAX_SIZE    : integer := 4096;     
      g_PCT_HDR_SIZE    : integer := 16;
      g_BUFF_COUNT      : integer := 4; -- 2,4 valid values
      in_pct_data_w     : integer := 32;
      out_pct_data_w    : integer := 64;
      decomp_fifo_size  : integer := 9 -- 256 words
   );
   port (

      wclk              : in std_logic;
      rclk              : in std_logic;
      reset_n           : in std_logic;
      pct_size          : in std_logic_vector(15 downto 0);
      
      --Mode settings
      mode			      : in std_logic; -- JESD207: 1; TRXIQ: 0
		trxiqpulse	      : in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
		ddr_en 		      : in std_logic; -- DDR: 1; SDR: 0
		mimo_en		      : in std_logic; -- SISO: 1; MIMO: 0
		ch_en			      : in std_logic_vector(1 downto 0); --"11" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
      sample_width      : in std_logic_vector(1 downto 0); --"10"-12bit, "01"-14bit, "00"-16bit;
      
      pct_sync_dis      : in std_logic;
      sample_nr         : in std_logic_vector(63 downto 0);
      
      in_pct_reset_n_req: out std_logic;
      in_pct_rdreq      : out std_logic;
      in_pct_data       : in std_logic_vector(in_pct_data_w-1 downto 0);
      in_pct_rdy        : in std_logic;
      in_pct_clr_flag   : out std_logic;
      in_pct_buff_rdy   : out std_logic_vector(g_BUFF_COUNT-1 downto 0);
      
      smpl_buff_rdempty : out std_logic;
      smpl_buff_wrfull  : out std_logic;
      smpl_buff_q       : out std_logic_vector(out_pct_data_w-1 downto 0);
      smpl_buff_rdreq   : in std_logic
      
        );
end packets2data_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of packets2data_top is
--declare signals,  components here

--inst0
signal inst0_smpl_buff_q         : std_logic_vector(out_pct_data_w-1 downto 0); 
signal inst0_smpl_buff_valid     : std_logic;

--inst1
signal inst1_data_out            : std_logic_vector(127 downto 0);
signal inst1_data_out_valid      : std_logic;

--inst2
signal inst2_wrusedw             : std_logic_vector(decomp_fifo_size-1 downto 0);

signal max_fifo_words            : std_logic_vector(decomp_fifo_size-1 downto 0);
signal fifo_limit                : unsigned(decomp_fifo_size-1 downto 0);
signal fifo_full_sig             : std_logic;
 
begin

max_fifo_words <= ((decomp_fifo_size-1)=> '0', others=>'1');


process(rclk, reset_n)
begin
   if reset_n = '0' then 
      fifo_limit <=(others=>'0');
   elsif (rclk'event AND rclk='1') then 
      fifo_limit <= unsigned(max_fifo_words) - 8;
   end if;
end process;


process(rclk, reset_n)
begin
   if reset_n = '0' then 
      fifo_full_sig <= '0';
   elsif (rclk'event AND rclk='1') then 
      if unsigned(inst2_wrusedw) > fifo_limit then
         fifo_full_sig <= '1';
      else
         fifo_full_sig <= '0';
      end if;
   end if;
end process;

smpl_buff_wrfull <= fifo_full_sig;


  packets2data_inst0 : entity work.packets2data
   generic map (
      g_DEV_FAMILY      => g_DEV_FAMILY,
      g_PCT_MAX_SIZE    => g_PCT_MAX_SIZE,        
      g_PCT_HDR_SIZE    => g_PCT_HDR_SIZE,
      g_BUFF_COUNT      => g_BUFF_COUNT,
      in_pct_data_w     => in_pct_data_w,
      out_pct_data_w    => out_pct_data_w
   )
   port map(

      wclk                    => wclk,
      rclk                    => rclk, 
      reset_n                 => reset_n,
               
      mode                    => mode,
      trxiqpulse              => trxiqpulse,	
      ddr_en 		            => ddr_en,
      mimo_en		            => mimo_en,	
      ch_en			            => ch_en,
      sample_width            => sample_width, 
            
      --pct_size                => pct_size,
               
      pct_sync_dis            => pct_sync_dis,
      sample_nr               => sample_nr,
      
      in_pct_reset_n_req      => in_pct_reset_n_req,
      in_pct_rdreq            => in_pct_rdreq,
      in_pct_data             => in_pct_data,
      in_pct_rdy              => in_pct_rdy,
      in_pct_clr_flag         => in_pct_clr_flag,
      in_pct_buff_rdy         => in_pct_buff_rdy, 
      
      smpl_buff_almost_full   => fifo_full_sig,
      smpl_buff_q             => inst0_smpl_buff_q,    
      smpl_buff_valid         => inst0_smpl_buff_valid
   );
        
        
bit_unpack_64_inst1 : entity work.bit_unpack_64
  port map(
        clk             => rclk,
        reset_n         => reset_n,
        data_in         => inst0_smpl_buff_q,
        data_in_valid   => inst0_smpl_buff_valid,
        sample_width    => sample_width,
        data_out        => inst1_data_out,
        data_out_valid  => inst1_data_out_valid
        );
        
        
   fifo_inst_isnt2 : entity work.fifo_inst
      generic map(
         dev_family	    => g_DEV_FAMILY,
         wrwidth         => 128,
         wrusedw_witdth  => decomp_fifo_size,
         rdwidth         => out_pct_data_w,
         rdusedw_width   => decomp_fifo_size+1,
         show_ahead      => "OFF"
      ) 
      port map(
         --input ports 
         reset_n       => reset_n,
         wrclk         => rclk,
         wrreq         => inst1_data_out_valid,
         data          => inst1_data_out,
         wrfull        => open,
         wrempty		  => open,
         wrusedw       => inst2_wrusedw,
         rdclk 	     => rclk,
         rdreq         => smpl_buff_rdreq,
         q             => smpl_buff_q,
         rdempty       => smpl_buff_rdempty,
         rdusedw       => open          
         );
  
  
  
end arch;   





