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

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity packets2data is
   generic (
      dev_family        : string := "Cyclone IV E";
      pct_size_w        : integer := 16;
      n_buff            : integer := 4; -- 2,4 valid values
      in_pct_data_w     : integer := 32;
      out_pct_data_w    : integer := 32
   );
   port (

      wclk              : in std_logic;
      rclk              : in std_logic;
      reset_n           : in std_logic;
      --Mode settings
      mode			      : in std_logic; -- JESD207: 1; TRXIQ: 0
      trxiqpulse	      : in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
		ddr_en 		      : in std_logic; -- DDR: 1; SDR: 0
		mimo_en		      : in std_logic; -- SISO: 1; MIMO: 0
		ch_en			      : in std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.  
      sample_width      : in std_logic_vector(1 downto 0); --"10"-12bit, "01"-14bit, "00"-16bit;
      
      pct_size          : in std_logic_vector(pct_size_w-1 downto 0); 
      
      pct_sync_dis      : in std_logic;
      sample_nr         : in std_logic_vector(63 downto 0);

      in_pct_wrreq      : in std_logic;
      in_pct_data       : in std_logic_vector(in_pct_data_w-1 downto 0);
      in_pct_last       : out std_logic;
      in_pct_full       : out std_logic;
      in_pct_clr_flag   : out std_logic;
      in_pct_buff_rdy   : out std_logic_vector(n_buff-1 downto 0);
      
      smpl_buff_full    : in std_logic;
      smpl_buff_q       : out std_logic_vector(out_pct_data_w-1 downto 0);
      smpl_buff_valid   : out std_logic
      
        );
end packets2data;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of packets2data is
--declare signals,  components here

--inst0
signal inst0_pct_hdr_0        : std_logic_vector(63 downto 0);
signal inst0_pct_hdr_0_valid  : std_logic_vector(n_buff-1 downto 0);
signal inst0_pct_hdr_1        : std_logic_vector(63 downto 0);
signal inst0_pct_hdr_1_valid  : std_logic_vector(n_buff-1 downto 0);
signal inst0_pct_data         : std_logic_vector(in_pct_data_w-1 downto 0);
signal inst0_pct_data_wrreq   : std_logic_vector(n_buff-1 downto 0);
signal inst0_pct_buff_rdy     : std_logic_vector(n_buff-1 downto 0);
signal inst0_in_pct_wrfull    : std_logic;


--for clk domain crosing
signal pct_sync_dis_rclk            : std_logic;
signal inst0_pct_hdr_0_rclk         : std_logic_vector(63 downto 0);
signal inst0_pct_hdr_0_rclk_stage0  : std_logic_vector(63 downto 0);
signal inst0_pct_hdr_0_valid_rclk   : std_logic_vector(n_buff-1 downto 0);
signal inst0_pct_hdr_1_rclk         : std_logic_vector(63 downto 0);
signal inst0_pct_hdr_1_rclk_stage0  : std_logic_vector(63 downto 0);
signal inst0_pct_hdr_1_valid_rclk   : std_logic_vector(n_buff-1 downto 0);

--inst1
signal inst1_pct_buff_rdy           : std_logic_vector(n_buff-1 downto 0);
signal inst1_pct_data_clr_n         : std_logic_vector(n_buff-1 downto 0);
signal inst1_pct_data_clr           : std_logic_vector(n_buff-1 downto 0);
signal inst1_pct_data_clr_dis       : std_logic_vector(n_buff-1 downto 0);

--inst2
signal isnt2_pct_buff_rd_en         : std_logic_vector(n_buff-1 downto 0);

--inst3
signal inst3_pct_data_rdreq         : std_logic_vector(n_buff-1 downto 0);
signal inst3_pct_data_rdstate       : std_logic_vector(n_buff-1 downto 0);
signal inst3_pct_size               : std_logic_vector(pct_size_w-1 downto 0); 
signal inst3_rd_fsm_rd_hold         : std_logic;

--instx
signal instx_wrempty                : std_logic_vector(n_buff-1 downto 0);
type instx_rdusedw_array is array (0 to (n_buff-1)) of std_logic_vector(9 downto 0);
signal instx_rdusedw                : instx_rdusedw_array;
type instx_q_array is array (0 to (n_buff-1)) of std_logic_vector(63 downto 0);
signal instx_q                      : instx_q_array;
signal instx_q_valid                : std_logic_vector(n_buff-1 downto 0);

signal pct_smpl_mux                 : std_logic_vector(63 downto 0);

signal pct_buff_rdy_int             : std_logic_vector(n_buff-1 downto 0);
signal pct_size_only_data           : unsigned(pct_size_w-1 downto 0);
signal half_pct_size_only_data      : unsigned(pct_size_w-1 downto 0);

signal smpl_buff_valid_int          : std_logic;


  
begin


--inst0_pct_hdr_0 bus is changed once per packet, safe to use sync registers 
bus_sync_reg0 : entity work.bus_sync_reg
 generic map (64) 
 port map(rclk, '1', inst0_pct_hdr_0, inst0_pct_hdr_0_rclk_stage0);

bus_sync_reg1 : entity work.bus_sync_reg
 generic map (64) 
 port map(rclk, '1', inst0_pct_hdr_0_rclk_stage0, inst0_pct_hdr_0_rclk);
 
 
 gen_handshake_sync_0  : 
   for i in 0 to n_buff-1 generate 
      handake_sync_insx : entity work.handshake_sync port map
         (wclk, 
         reset_n, 
         inst0_pct_hdr_0_valid(i), 
         open, 
         rclk, 
         reset_n, 
         inst0_pct_hdr_0_valid_rclk(i)
      );
  end generate gen_handshake_sync_0;
  
-- bus_sync_reg1 : entity work.bus_sync_reg
 -- generic map (n_buff) 
-- port map(rclk, '1', (others=>'1'), inst0_pct_hdr_0_valid_rclk);

--inst0_pct_hdr_1 bus is changed once per packet, safe to use sync registers 
 bus_sync_reg2 : entity work.bus_sync_reg
 generic map (64) 
 port map(rclk, '1', inst0_pct_hdr_1, inst0_pct_hdr_1_rclk_stage0);
 
 bus_sync_reg3 : entity work.bus_sync_reg
 generic map (64) 
 port map(rclk, '1', inst0_pct_hdr_1_rclk_stage0, inst0_pct_hdr_1_rclk);
 
 
  gen_handshake_sync_1  : 
   for i in 0 to n_buff-1 generate 
      handake_sync_insx : entity work.handshake_sync port map
         (wclk, 
         reset_n, 
         inst0_pct_hdr_1_valid(i), 
         open, 
         rclk, 
         reset_n, 
         inst0_pct_hdr_1_valid_rclk(i)
      );
  end generate gen_handshake_sync_1;
 
-- bus_sync_reg3 : entity work.bus_sync_reg
 -- generic map (n_buff) 
-- port map(rclk, '1', (others=>'1'), inst0_pct_hdr_1_valid_rclk);

sync_reg1 : entity work.sync_reg 
port map(rclk, '1', pct_sync_dis, pct_sync_dis_rclk);


process(rclk, reset_n)
begin
   if reset_n = '0' then 
      pct_size_only_data <= (others=>'1');
   elsif (rclk'event AND rclk='1') then 
      pct_size_only_data <= unsigned(pct_size)-4;
   end if;
end process;

process(rclk, reset_n)
begin
   if reset_n = '0' then 
      half_pct_size_only_data <= (others=>'1');
   elsif (rclk'event AND rclk='1') then
      half_pct_size_only_data <= unsigned('0' & pct_size_only_data(pct_size_w-1 downto 1));
   end if;
end process;

inst3_pct_size <= std_logic_vector(half_pct_size_only_data);


process(rclk, reset_n)
begin
   if reset_n = '0' then
      inst1_pct_data_clr <= (others=>'0');
      in_pct_clr_flag <= '0';
   elsif (rclk'event AND rclk='1') then
      for i in 0 to n_buff-1 loop
         inst1_pct_data_clr <= not inst1_pct_data_clr_n;
      end loop; 
      if unsigned(inst1_pct_data_clr) > 0 then 
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
      pct_size_w        => pct_size_w,
      n_buff            => n_buff,
      in_pct_data_w     => in_pct_data_w
   )
   port map(
      clk               => wclk,
      reset_n           => reset_n,
      pct_size          => pct_size, 
      in_pct_wrreq      => in_pct_wrreq,
      in_pct_data       => in_pct_data,
      in_pct_wrfull     => inst0_in_pct_wrfull,

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
   for i in 0 to n_buff-1 generate
      fifo_inst_isntx : entity work.fifo_inst
         generic map(
            dev_family	    => "Cyclone IV E",
            wrwidth         => in_pct_data_w,
            wrusedw_witdth  => 11, --12=2048 words 
            rdwidth         => 64,
            rdusedw_width   => 10,
            show_ahead      => "OFF"
         ) 
         port map(
            --input ports 
            reset_n       => inst1_pct_data_clr_n(i),
            wrclk         => wclk,
            wrreq         => inst0_pct_data_wrreq(i),
            data          => inst0_pct_data,
            wrfull        => open,
            wrempty		  => instx_wrempty(i),
            wrusedw       => open,
            rdclk 	     => rclk,
            rdreq         => inst3_pct_data_rdreq(i),
            q             => instx_q(i),
            rdempty       => open,
            rdusedw       => instx_rdusedw(i)          
            );
end generate gen_fifo;


in_pct_last <= inst0_in_pct_wrfull;

process(wclk, reset_n)
begin
   if reset_n = '0' then 
      in_pct_full <= '0';
   elsif (wclk'event AND wclk='1') then 
      if unsigned(instx_wrempty) = 0 OR inst0_in_pct_wrfull = '1' then 
         in_pct_full <= '1';
      else
         in_pct_full <= '0';
      end if;      
   end if;
end process;


process(rclk, reset_n)
begin
   if reset_n = '0' then 
      pct_buff_rdy_int <= (others=>'0');
   elsif (rclk'event AND rclk='1') then 
      for i in 0 to n_buff-1 loop
         if unsigned(instx_rdusedw(i)) = half_pct_size_only_data then 
            pct_buff_rdy_int(i)<= '1';
         else 
            pct_buff_rdy_int(i)<= '0';
         end if;
      end loop;
   end if;
end process;




inst1_pct_buff_rdy   <= pct_buff_rdy_int;
in_pct_buff_rdy      <= pct_buff_rdy_int;


p2d_clr_fsm_inst1 : entity work.p2d_clr_fsm
   generic map(
      pct_size_w           =>  pct_size_w,
      n_buff               =>  n_buff
   )
   port map(
      clk                  => rclk,
      reset_n              => reset_n,
      pct_size             => pct_size, 
      
      smpl_nr              => sample_nr,
      
      pct_hdr_0            => inst0_pct_hdr_0_rclk,
      pct_hdr_0_valid      => inst0_pct_hdr_0_valid_rclk,

      pct_hdr_1            => inst0_pct_hdr_1_rclk,
      pct_hdr_1_valid      => inst0_pct_hdr_1_valid_rclk,

      pct_data_clr_n       => inst1_pct_data_clr_n,
      pct_data_clr_dis     => inst1_pct_data_clr_dis,
		
      pct_buff_rdy         => inst1_pct_buff_rdy
      
        );
        
inst1_pct_data_clr_dis <= inst3_pct_data_rdstate when pct_sync_dis_rclk = '0' else (others=>'1');
        
        
        
p2d_sync_fsm_inst2 : entity work.p2d_sync_fsm
   generic map(
      pct_size_w           =>  pct_size_w,
      n_buff               =>  n_buff
   )
   port map(
      clk                  => rclk,
      reset_n              => reset_n,
      
      mode                 => mode, 
      trxiqpulse           => trxiqpulse,	
      ddr_en 		         => ddr_en,
      mimo_en		         => mimo_en,	
      ch_en			         => ch_en,
      sample_width         => sample_width, 
      
      pct_size             => std_logic_vector(pct_size_only_data),
      
      pct_sync_dis         => pct_sync_dis_rclk,
      
      smpl_nr              => sample_nr,
      
      pct_hdr_0            => inst0_pct_hdr_0_rclk,
      pct_hdr_0_valid      => inst0_pct_hdr_0_valid_rclk,

      pct_hdr_1            => inst0_pct_hdr_1_rclk,
      pct_hdr_1_valid      => inst0_pct_hdr_1_valid_rclk,

      pct_data_clr_n       => inst1_pct_data_clr_n,
      pct_buff_rdy         => pct_buff_rdy_int,
      
      pct_rd_fsm_hold      => inst3_rd_fsm_rd_hold,

      pct_buff_rd_en       => isnt2_pct_buff_rd_en
      
        );
        
        
p2d_rd_fsm_inst3 : entity work.p2d_rd_fsm
   generic map(
      pct_size_w           => pct_size_w,
      n_buff               => n_buff
   )
   port map(
      clk                  => rclk,
      reset_n              => reset_n,
      pct_size             => inst3_pct_size,
     
      pct_data_buff_full   => smpl_buff_full,
      pct_data_rdreq       => inst3_pct_data_rdreq,
      pct_data_rdstate     => inst3_pct_data_rdstate,
      

      pct_buff_rdy         => isnt2_pct_buff_rd_en,
      rd_fsm_rdy           => open,
      rd_fsm_rd_hold       => inst3_rd_fsm_rd_hold
      
        );
        
        
proc_name : process(rclk, reset_n)
begin
   if reset_n = '0' then 
      instx_q_valid <= (others=>'0');
      smpl_buff_q <= (others=> '0');
      smpl_buff_valid <= '0';
   elsif (rclk'event AND rclk='1') then 
      instx_q_valid <= inst3_pct_data_rdreq;
      smpl_buff_q <= pct_smpl_mux;
      smpl_buff_valid <= smpl_buff_valid_int;
   end if;
end process;

process(instx_q_valid,instx_q)
variable tmp : integer := 0;
begin
   tmp := 0;
   for i in 0 to n_buff-1 loop
      if instx_q_valid(i)= '1' then 
         tmp := i;
      end if;
      smpl_buff_valid_int <= instx_q_valid(tmp);
      pct_smpl_mux <= instx_q(tmp);
   end loop;
end process;

-- smpl_buff_valid <= instx_q_valid;
        


  
end arch;   





