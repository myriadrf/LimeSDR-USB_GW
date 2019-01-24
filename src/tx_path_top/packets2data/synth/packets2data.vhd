-- ----------------------------------------------------------------------------	
-- FILE: 	packets2data.vhd
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
use work.FIFO_PACK.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity packets2data is
   generic (
      g_DEV_FAMILY      : string := "Cyclone IV E";
      g_PCT_MAX_SIZE    : integer := 4096;     
      g_PCT_HDR_SIZE    : integer := 16;           
      g_BUFF_COUNT      : integer := 4; -- 2,4 valid values
      in_pct_data_w     : integer := 32;
      out_pct_data_w    : integer := 32
   );
   port (

      wclk                    : in std_logic;
      rclk                    : in std_logic;
      reset_n                 : in std_logic;
      --Mode settings      
      mode			            : in std_logic; -- JESD207: 1; TRXIQ: 0
      trxiqpulse	            : in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
		ddr_en 		            : in std_logic; -- DDR: 1; SDR: 0
		mimo_en		            : in std_logic; -- SISO: 1; MIMO: 0
		ch_en			            : in std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.  
      sample_width            : in std_logic_vector(1 downto 0); --"10"-12bit, "01"-14bit, "00"-16bit;
            
      pct_sync_dis            : in std_logic;
      sample_nr               : in std_logic_vector(63 downto 0);
      
      in_pct_reset_n_req      : out std_logic;
      in_pct_rdreq            : out std_logic;
      in_pct_data             : in std_logic_vector(in_pct_data_w-1 downto 0);
      in_pct_rdy              : in std_logic;
            
      in_pct_clr_flag         : out std_logic;
      in_pct_buff_rdy         : out std_logic_vector(g_BUFF_COUNT-1 downto 0);
      
      smpl_buff_almost_full   : in std_logic;
      smpl_buff_q             : out std_logic_vector(out_pct_data_w-1 downto 0);
      smpl_buff_valid         : out std_logic
      
        );
end packets2data;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of packets2data is
--declare signals,  components here
-- c_PCT_MAX_WORDS represents data words stored in buffers minus header words
constant c_PCT_MAX_WORDS   : integer := (g_PCT_MAX_SIZE - g_PCT_HDR_SIZE)*8/out_pct_data_w;
constant c_RD_RATIO        : integer := out_pct_data_w/8;

--inst0
signal inst0_pct_hdr_0           : std_logic_vector(63 downto 0);
signal inst0_pct_hdr_0_valid     : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal inst0_pct_hdr_1           : std_logic_vector(63 downto 0);
signal inst0_pct_hdr_1_valid     : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal inst0_pct_data            : std_logic_vector(in_pct_data_w-1 downto 0);
signal inst0_pct_data_wrreq      : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal inst0_pct_buff_rdy        : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal inst0_in_pct_wrfull       : std_logic;
signal inst0_in_pct_reset_n_req  : std_logic;


--for clk domain crosing
signal pct_sync_dis_rclk            : std_logic;

--inst1
signal inst1_pct_buff_rdy           : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal inst1_pct_data_clr_n         : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal inst1_pct_data_clr           : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal inst1_pct_data_clr_dis       : std_logic_vector(g_BUFF_COUNT-1 downto 0);

--inst2
signal isnt2_pct_buff_rd_en         : std_logic_vector(g_BUFF_COUNT-1 downto 0);

--inst3
signal inst3_pct_data_rdreq         : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal inst3_pct_data_rdstate       : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal inst3_rd_fsm_rdy             : std_logic;
signal inst3_rd_fsm_rd_done         : std_logic;
signal inst3_pct_buff_rdreq         : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal inst3_pct_buff_clr_n         : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal inst3_pct_buff_sel           : std_logic_vector(3 downto 0);


--instx
constant c_INSTX_WRUSEDW_W          : integer := FIFO_WORDS_TO_Nbits(g_PCT_MAX_SIZE/(in_pct_data_w/8),true); 
constant c_INSTX_RDUSEDW_W          : integer := FIFO_WORDS_TO_Nbits(g_PCT_MAX_SIZE/(out_pct_data_w/8),true);
signal instx_wrempty                : std_logic_vector(g_BUFF_COUNT-1 downto 0);
type instx_rdusedw_array is array (0 to (g_BUFF_COUNT-1)) of std_logic_vector(c_INSTX_RDUSEDW_W-1 downto 0);
signal instx_rdusedw                : instx_rdusedw_array;
type instx_q_array is array (0 to (g_BUFF_COUNT-1)) of std_logic_vector(out_pct_data_w-1 downto 0);
signal instx_q                      : instx_q_array;
signal instx_q_valid                : std_logic_vector(g_BUFF_COUNT-1 downto 0);

signal pct_smpl_mux                 : std_logic_vector(63 downto 0);

signal pct_buff_rdy_int             : std_logic_vector(g_BUFF_COUNT-1 downto 0);
type pct_size_array is array (0 to (g_BUFF_COUNT-1)) of std_logic_vector(15 downto 0);
signal pct_buff_size                : pct_size_array;

signal smpl_buff_valid_int          : std_logic;


  
begin

sync_reg1 : entity work.sync_reg 
port map(rclk, '1', pct_sync_dis, pct_sync_dis_rclk);

process(rclk, reset_n)
begin
   if reset_n = '0' then
      inst1_pct_data_clr <= (others=>'0');
      in_pct_clr_flag <= '0';
   elsif (rclk'event AND rclk='1') then
      for i in 0 to g_BUFF_COUNT-1 loop
         inst1_pct_data_clr <= not inst3_pct_buff_clr_n;
      end loop; 
      if unsigned(inst1_pct_data_clr) > 0 OR inst0_in_pct_reset_n_req = '0' then 
         in_pct_clr_flag <= '1';
      else 
         in_pct_clr_flag <= '0';
      end if;
   end if;
end process;



-- ----------------------------------------------------------------------------
-- Write fsm instance
-- ----------------------------------------------------------------------------
p2d_wr_fsm_inst0 : entity work.p2d_wr_fsm
   generic map(
      g_PCT_MAX_SIZE => g_PCT_MAX_SIZE,   
      g_PCT_HDR_SIZE => g_PCT_HDR_SIZE,         
      g_BUFF_COUNT   => g_BUFF_COUNT
       
   )
   port map(
      clk               => wclk,
      reset_n           => reset_n,
      
      pct_sync_dis      => pct_sync_dis,
      sample_nr         => sample_nr,
      in_pct_reset_n_req=> inst0_in_pct_reset_n_req,
      in_pct_rdreq      => in_pct_rdreq,
      in_pct_data       => in_pct_data,
      in_pct_rdy        => in_pct_rdy,

      pct_hdr_0         => inst0_pct_hdr_0,
      pct_hdr_0_valid   => inst0_pct_hdr_0_valid,

      pct_hdr_1         => inst0_pct_hdr_1,
      pct_hdr_1_valid   => inst0_pct_hdr_1_valid,

      pct_data          => inst0_pct_data,
      pct_data_wrreq    => inst0_pct_data_wrreq,

      pct_buff_rdy      => instx_wrempty     
      );
      
        
-- ----------------------------------------------------------------------------
-- Generated FIFO buffers
-- ----------------------------------------------------------------------------        
gen_fifo :
   for i in 0 to g_BUFF_COUNT-1 generate
      fifo_inst_isntx : entity work.fifo_inst
         generic map(
            dev_family	    => g_DEV_FAMILY,
            wrwidth         => in_pct_data_w,
            wrusedw_witdth  => c_INSTX_WRUSEDW_W, --12=2048 words 
            rdwidth         => out_pct_data_w,
            rdusedw_width   => c_INSTX_RDUSEDW_W,
            show_ahead      => "OFF"
         ) 
         port map(
            --input ports 
            reset_n       => inst3_pct_buff_clr_n(i),
            wrclk         => wclk,
            wrreq         => inst0_pct_data_wrreq(i),
            data          => inst0_pct_data,
            wrfull        => open,
            wrempty		  => instx_wrempty(i),
            wrusedw       => open,
            rdclk 	     => rclk,
            rdreq         => inst3_pct_buff_rdreq(i),
            q             => instx_q(i),
            rdempty       => open,
            rdusedw       => instx_rdusedw(i)          
            );
end generate gen_fifo;




process(rclk, reset_n)
begin
   if reset_n = '0' then 
      pct_buff_rdy_int <= (others=>'0');
      pct_buff_size       <= (others=>(others=>'1'));
   elsif (rclk'event AND rclk='1') then 
      for i in 0 to g_BUFF_COUNT-1 loop
         if unsigned(instx_rdusedw(i)) = unsigned(pct_buff_size(i)) then 
            pct_buff_rdy_int(i)<= '1';
         else 
            pct_buff_rdy_int(i)<= '0';
         end if;
         
         if inst0_pct_hdr_0_valid(i) = '1' then
            if inst0_pct_hdr_0(23 downto 8) = "0000000000000000" then 
               pct_buff_size(i) <= std_logic_vector(to_unsigned(c_PCT_MAX_WORDS, 16));
            else 
               pct_buff_size(i) <= std_logic_vector(unsigned(in_pct_data(23 downto 8))/c_RD_RATIO);
            end if;
         else 
            pct_buff_size(i) <= pct_buff_size(i);
         end if;
         
      end loop;
   end if;
end process;

inst1_pct_buff_rdy   <= pct_buff_rdy_int;
in_pct_buff_rdy      <= pct_buff_rdy_int;

        
inst1_pct_data_clr_dis <= inst3_pct_data_rdstate when pct_sync_dis_rclk = '0' else (others=>'1');
    
        
p2d_rd_inst3 : entity work.p2d_rd
   generic map(
      g_PCT_MAX_SIZE => g_PCT_MAX_SIZE,    
      g_PCT_HDR_SIZE => g_PCT_HDR_SIZE,
      g_BUFF_COUNT   => g_BUFF_COUNT
   )  
   port map(   
      clk                     => rclk,
      reset_n                 => reset_n,
         
      synch_dis               => pct_sync_dis,
         
      pct_hdr_0               => inst0_pct_hdr_0,
      pct_hdr_0_valid         => inst0_pct_hdr_0_valid,
      pct_hdr_1               => inst0_pct_hdr_1,
      pct_hdr_1_valid         => inst0_pct_hdr_1_valid,
         
      sample_nr               => sample_nr,  
   
      pct_buff_rdy            => pct_buff_rdy_int,
      pct_buff_rdreq          => inst3_pct_buff_rdreq,
      pct_buff_sel            => inst3_pct_buff_sel,
      pct_buff_clr_n          => inst3_pct_buff_clr_n,
      
      smpl_buff_almost_full   => smpl_buff_almost_full

   );

   process(rclk, reset_n)
   begin
      if reset_n = '0' then 
         smpl_buff_valid_int <= '0';
      elsif (rclk'event AND rclk='1') then 
         if unsigned(inst3_pct_buff_rdreq) > 0 then 
            smpl_buff_valid_int <= '1';
         else 
            smpl_buff_valid_int <= '0';
         end if;
      end if;
   end process;

-- ----------------------------------------------------------------------------
-- Output ports
-- ---------------------------------------------------------------------------- 
   
   out_reg : process(rclk, reset_n)
   begin
      if reset_n = '0' then
         smpl_buff_valid <= '0';         
         smpl_buff_q <= (others=> '0');
      elsif (rclk'event AND rclk='1') then
         smpl_buff_valid   <= smpl_buff_valid_int;
         smpl_buff_q       <= instx_q(to_integer(unsigned(inst3_pct_buff_sel)));
      end if;
   end process;
   
   in_pct_reset_n_req <= inst0_in_pct_reset_n_req;
        


  
end arch;   





