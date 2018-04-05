-- ----------------------------------------------------------------------------	
-- FILE:          p2d_sync_fsm.vhd
-- DESCRIPTION:   FSm for data reading from packets.
-- DATE:          April 6, 2017
-- AUTHOR(s):     Lime Microsystems
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
entity p2d_sync_fsm is
   generic (
      pct_size_w           : integer := 16;
      n_buff               : integer := 2 -- 2,4 valid values
   );
   port (
      clk                  : in std_logic;
      reset_n              : in std_logic;
      --Mode settings      
      mode                 : in std_logic; -- JESD207: 1; TRXIQ: 0
      trxiqpulse           : in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
      ddr_en               : in std_logic; -- DDR: 1; SDR: 0
      mimo_en              : in std_logic; -- SISO: 1; MIMO: 0
      ch_en                : in std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.  
      sample_width         : in std_logic_vector(1 downto 0); --"10"-12bit, "01"-14bit, "00"-16bit;
      
      pct_size             : in std_logic_vector(pct_size_w-1 downto 0);   --Whole packet size in 
                                                                           --in_pct_data_w words
      pct_sync_dis         : in std_logic;
                                                                           
      smpl_nr              : in std_logic_vector(63 downto 0);
                                                                           
      pct_hdr_0            : in std_logic_vector(63 downto 0);
      pct_hdr_0_valid      : in std_logic_vector(n_buff-1 downto 0);
      
      pct_hdr_1            : in std_logic_vector(63 downto 0);
      pct_hdr_1_valid      : in std_logic_vector(n_buff-1 downto 0);
     
      pct_data_clr_n       : in std_logic_vector(n_buff-1 downto 0);      
      pct_buff_rdy         : in std_logic_vector(n_buff-1 downto 0); --assert when whole packet is ready
      
      pct_rd_fsm_rdy       : in std_logic;
      pct_rd_fsm_done      : in std_logic;

      pct_buff_rd_en       : out std_logic_vector(n_buff-1 downto 0)   
      
        );
end p2d_sync_fsm;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of p2d_sync_fsm is
--declare signals,  components here

type state_type is (idle, pct_sync_en, shift_sync_en, rd_buff);
signal current_state, next_state : state_type; 

type smpl_nr_array_type  is array (0 to n_buff-1) of std_logic_vector(63 downto 0);  
signal smpl_nr_array          : smpl_nr_array_type;

signal pct_smpl_nr_equal      : std_logic_vector(n_buff-1 downto 0);
signal pct_smpl_nr_sync_dis   : std_logic_vector(n_buff-1 downto 0);
signal sync_cnt               : unsigned(15 downto 0);
signal sync_cnt_limit         : unsigned(15 downto 0);
signal sync_cnt_max           : unsigned(15 downto 0);
signal sync_en_vect           : std_logic_vector(n_buff-1 downto 0);
signal sync_en_vect_shift     : std_logic;
signal sync_en                : std_logic_vector(n_buff-1 downto 0);
signal pct_buff_rd_en_int     : std_logic_vector(n_buff-1 downto 0);

signal int_mode               : std_logic_vector(1 downto 0);



begin



process(clk, reset_n)
begin
   if reset_n = '0' then 
      sync_cnt_limit <= (others=>'1');
   elsif (clk'event AND clk='1') then 
      if sample_width = "10" then   
         sync_cnt_limit <= x"0550";
      elsif sample_width = "10" then 
         sync_cnt_limit <= x"0120";
      else
         sync_cnt_limit <= x"03FC";
      end if;
   end if;
end process;

-- ----------------------------------------------------------------------------
--Internal mode selection for DIQ position
-- "00" - MIMO DDR both channels enabled, SISO DDR, TXIQ_PULSE
-- "01" - MIMO DDR, TXIQ_PULSE first channel enabled
-- "10" - MIMO DDR, TXIQ_PULSE second channel enabled
-- "11" - SISO SDR 
-- ----------------------------------------------------------------------------
 int_mode <= "00" when (mimo_en='0' AND ddr_en='1') OR ((mimo_en='1' OR trxiqpulse ='1') AND ch_en="11") else 
             "01" when ((mimo_en='1' OR trxiqpulse ='1') AND ch_en="01") else
             "10" when ((mimo_en='1' OR trxiqpulse ='1') AND ch_en="10") else
             "11";
             
             
process(clk, reset_n)
begin
   if reset_n = '0' then 
      sync_cnt_max <= (others=>'1');
   elsif (clk'event AND clk='1') then 
      if int_mode = "00" then 
         sync_cnt_max <= sync_cnt_limit - 4;
      elsif int_mode = "11" then 
         sync_cnt_max <= unsigned(sync_cnt_limit(13 downto 0) & "00") - 4;
      else
         sync_cnt_max <= unsigned(sync_cnt_limit(14 downto 0) & '0') - 4;
      end if;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- Capture sample numbers from packets to reg array
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      smpl_nr_array <= (others=>(others=>'0'));
   elsif (clk'event AND clk='1') then 
      for i in 0 to n_buff-1 loop
         if pct_hdr_1_valid(i) = '1' then 
            smpl_nr_array(i)<= pct_hdr_1;
         else 
            smpl_nr_array(i)<=smpl_nr_array(i);
         end if;
      end loop;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- Capture sample numbers from packets to reg array
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      pct_smpl_nr_sync_dis <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      for i in 0 to n_buff-1 loop
         if pct_hdr_0_valid(i) = '1' then 
            pct_smpl_nr_sync_dis(i)<= pct_hdr_0(4);
         else 
            pct_smpl_nr_sync_dis(i)<=pct_smpl_nr_sync_dis(i);
         end if;
      end loop;
   end if;
end process;


-- ----------------------------------------------------------------------------
-- Compare current sample number with received packet sample number
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      pct_smpl_nr_equal <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      for i in 0 to n_buff-1 loop
         if unsigned(smpl_nr_array(i)) = unsigned(smpl_nr) AND pct_sync_dis = '0' then 
            pct_smpl_nr_equal(i)<= '1';
         else 
            pct_smpl_nr_equal(i)<= '0';
         end if;
      end loop;
   end if;
end process;


process(clk, reset_n)
begin
   if reset_n = '0' then 
      sync_en_vect <= (0=>'1', others=>'0');
   elsif (clk'event AND clk='1') then 
      if current_state = shift_sync_en then 
         sync_en_vect <= sync_en_vect(n_buff-2 downto 0) & sync_en_vect(n_buff-1);
      else 
         sync_en_vect <= sync_en_vect;
      end if;
   end if;
end process;


sync_en <= sync_en_vect when (pct_sync_dis = '1' OR unsigned(pct_smpl_nr_sync_dis) > 0)  else pct_smpl_nr_equal;
            
process(clk, reset_n)
begin
   if reset_n = '0' then 
      sync_cnt <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      if current_state = pct_sync_en then
         sync_cnt <= sync_cnt+1;
      else 
         sync_cnt <= (others=>'0');
      end if;
   end if;
end process;


-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------
fsm_f : process(clk, reset_n)begin
   if(reset_n = '0')then
      current_state <= idle;
   elsif(clk'event and clk = '1')then
         current_state <= next_state;
   end if;
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, pct_buff_rd_en_int, pct_rd_fsm_rdy, pct_rd_fsm_done) begin
   next_state <= current_state;
   case current_state is
   
      when idle =>
         if unsigned(pct_buff_rd_en_int) > 0  then
            next_state <= pct_sync_en;
         else 
            next_state <= idle;
         end if;
         
      when pct_sync_en =>
         if pct_rd_fsm_done = '1' then 
            next_state <= shift_sync_en;
         else 
            next_state <= pct_sync_en;
         end if;

      when shift_sync_en =>
         next_state <= idle;
         
      when others => 
         next_state <= idle;
   end case;
end process;

-- ----------------------------------------------------------------------------
-- Trigger packet read when packet is ready
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      pct_buff_rd_en_int <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      for i in 0 to n_buff-1 loop
         if pct_buff_rdy(i) = '1' AND pct_data_clr_n(i) = '1' AND sync_en(i) = '1' AND pct_rd_fsm_rdy = '1' then 
            pct_buff_rd_en_int(i)<= '1';
         else 
            pct_buff_rd_en_int(i)<= '0';
         end if;
      end loop;
   end if;
end process;


pct_buff_rd_en <= pct_buff_rd_en_int;



end arch;   





