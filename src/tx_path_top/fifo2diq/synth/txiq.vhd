-- ----------------------------------------------------------------------------	
-- FILE: 	txiq.vhd
-- DESCRIPTION:	TXIQ modes: 
-- DATE:	Jan 20, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity txiq is
   generic( 
      dev_family	: string := "Cyclone IV E";
      iq_width		: integer := 12
   );
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      en          : in std_logic;
      --Mode settings
      trxiqpulse	: in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
		ddr_en 		: in std_logic; -- DDR: 1; SDR: 0
		mimo_en		: in std_logic; -- SISO: 1; MIMO: 0
		ch_en			: in std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.  
		fidm			: in std_logic; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      --Tx interface data 
      DIQ_h		 	: out std_logic_vector(iq_width downto 0);
		DIQ_l	 	   : out std_logic_vector(iq_width downto 0);
      --fifo ports 
      fifo_rdempty: in std_logic;
      fifo_rdreq  : out std_logic;
      fifo_q      : in std_logic_vector(iq_width*4-1 downto 0);
      --TX activity indication
      txant_en    : out std_logic
      
        );
end txiq;

-- ----------------------------------------------------------------------------
--Truth table for mode selection
-- ----------------------------------------------------------------------------
-- Mode       | TRXIQ_PULSE  | MIMO DDR  | MIMO DDR  | MIMO DDR  |SISO DDR   | SISO SDR  |
--            |              |  all ch.  |  1 ch.    |  2 ch.    |           |           |
-- trxiqpulse |       H      |     L     |    L      |    L      |     L     |     L     |
-- ddr_en     |       X      |     H     |    H      |    H      |     H     |     L     |
-- mimo_en    |       X      |     H     |    H      |    H      |     L     |     L     |
-- ch_en      |       XX     |     HH    |   LH      |    HL     |     XX    |     XX    |

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of txiq is
--declare signals,  components here
signal int_fifo_rdreq      : std_logic;
signal int_fifo_q_valid    : std_logic;

signal diq_smpl_0          : std_logic_vector(iq_width-1 downto 0);
signal diq_smpl_1          : std_logic_vector(iq_width-1 downto 0);
signal diq_smpl_2          : std_logic_vector(iq_width-1 downto 0);
signal diq_smpl_3          : std_logic_vector(iq_width-1 downto 0);

signal mux_pos0_L          : std_logic_vector(iq_width-1 downto 0);
signal mux_pos1_L          : std_logic_vector(iq_width-1 downto 0);
signal mux_pos2_L          : std_logic_vector(iq_width-1 downto 0);
signal mux_pos3_L          : std_logic_vector(iq_width-1 downto 0);

signal mux_pos0_H          : std_logic_vector(iq_width-1 downto 0);
signal mux_pos1_H          : std_logic_vector(iq_width-1 downto 0);
signal mux_pos2_H          : std_logic_vector(iq_width-1 downto 0);
signal mux_pos3_H          : std_logic_vector(iq_width-1 downto 0);

signal mux_fsync_L         : std_logic_vector(3 downto 0);
signal mux_fsync_H         : std_logic_vector(3 downto 0);

signal int_fsync_L         : std_logic_vector(3 downto 0);
signal int_fsync_H         : std_logic_vector(3 downto 0);

signal diq_L_reg_0         : std_logic_vector(iq_width downto 0);
signal diq_L_reg_1         : std_logic_vector(iq_width downto 0);
signal diq_L_reg_2         : std_logic_vector(iq_width downto 0);
signal diq_L_reg_3         : std_logic_vector(iq_width downto 0);

signal diq_H_reg_0         : std_logic_vector(iq_width downto 0);
signal diq_H_reg_1         : std_logic_vector(iq_width downto 0);
signal diq_H_reg_2         : std_logic_vector(iq_width downto 0);
signal diq_H_reg_3         : std_logic_vector(iq_width downto 0);

signal int_mode            : std_logic_vector(1 downto 0);

signal rd_wait_cnt         : unsigned(3 downto 0);
signal rd_wait_cnt_max     : unsigned(3 downto 0);
signal rd_wait_cnt_max_reg : unsigned(3 downto 0);

signal zero_valid          : std_logic;

type state_type is (idle, rd_samples, zero_samples, wait_rd_cycles);
signal current_state, next_state : state_type;
  
begin
-- ----------------------------------------------------------------------------
-- DIQ samples from fifo
-- ----------------------------------------------------------------------------
diq_smpl_3 <= fifo_q(4*iq_width-1 downto 3*iq_width);
diq_smpl_2 <= fifo_q(3*iq_width-1 downto 2*iq_width);
diq_smpl_1 <= fifo_q(2*iq_width-1 downto 1*iq_width);
diq_smpl_0 <= fifo_q(1*iq_width-1 downto 0*iq_width);

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
             
-- ----------------------------------------------------------------------------
--Muxes for fsync signal
-- ----------------------------------------------------------------------------  
mux_fsync_H <= "1111" when  (mimo_en ='0' AND ddr_en ='1' AND trxiqpulse='0') else 
               "0101";

mux_fsync_L <= "0000" when  (mimo_en ='0' AND ddr_en = '1') OR trxiqpulse='1'  else 
               "0101";
               
int_fsync_L <= (not mux_fsync_L(3) & not mux_fsync_L(2) & not mux_fsync_L(1) & not mux_fsync_L(0)) when fidm = '0' else 
               mux_fsync_L;
               
int_fsync_H <= (not mux_fsync_H(3) & not mux_fsync_H(2) & not mux_fsync_H(1) & not mux_fsync_H(0)) when fidm = '0' else 
               mux_fsync_H;
           

-- ----------------------------------------------------------------------------
--Muxes for diq  H positions
-- ----------------------------------------------------------------------------            
--mux_posx_H      : |3            |2          | 1         |0           
--int_mode = "00" : |0            |0          |diq_smpl_2 |diq_smpl_0
--int_mode = "01" : |0            |diq_smpl_2 |0          |diq_smpl_0
--int_mode = "10" : |diq_smpl_2   |0          |diq_smpl_0 |0
--int_mode = "11" : |diq_smpl_3   |diq_smpl_2 |diq_smpl_1 |diq_smpl_0

mux_pos0_H <=  (others=>'0') when int_mode = "10" else 
               diq_smpl_0;
                  
mux_pos1_H <=  diq_smpl_2     when int_mode = "00" else 
               (others=>'0')  when int_mode = "01" else 
               diq_smpl_0     when int_mode = "10" else 
               diq_smpl_1;
               
mux_pos2_H <=  (others=>'0')  when int_mode(0) = '0' else 
               diq_smpl_2;               
                  
mux_pos3_H <=  (others=>'0')  when int_mode(1) = '0' else 
               diq_smpl_2     when int_mode = "10" else 
               diq_smpl_3;
-- ----------------------------------------------------------------------------               
-- Muxes for diq  L positions
-- ----------------------------------------------------------------------------
--mux_posx_L      : |3            |2          | 1         |0           
--int_mode = "00" : |0            |0          |diq_smpl_3 |diq_smpl_1
--int_mode = "01" : |0            |diq_smpl_3 |0          |diq_smpl_1
--int_mode = "10" : |diq_smpl_3   |0          |diq_smpl_1 |0
--int_mode = "11" : |diq_smpl_3   |diq_smpl_2 |diq_smpl_1 |diq_smpl_0
 
mux_pos0_L <=  diq_smpl_0     when int_mode = "11" else 
               (others=>'0')  when int_mode = "10" else 
               diq_smpl_1;
                  
mux_pos1_L <=  diq_smpl_3     when int_mode = "00" else 
               (others=>'0')  when int_mode = "01" else 
               diq_smpl_1;
               
mux_pos2_L <=  (others=>'0')  when int_mode(0) = '0' else 
               diq_smpl_3     when int_mode = "01" else 
               diq_smpl_2;               
                  
mux_pos3_L <=  (others=>'0')  when int_mode(1) = '0' else 
               diq_smpl_3; 



rd_wait_cnt_max <=   "0000" when int_mode = "00" else 
                     "0010" when int_mode = "11" else 
                     "0010" ; 
                     
rd_wait_cnt_proc: process(clk, reset_n) 
begin 
   if reset_n ='0' then 
      rd_wait_cnt <= (others=>'0');
      rd_wait_cnt_max_reg <= (others=>'0');
   elsif (clk'event AND clk='1') then
      rd_wait_cnt_max_reg <= rd_wait_cnt_max;
      if current_state = wait_rd_cycles then
         rd_wait_cnt <= rd_wait_cnt+1;
      else
         rd_wait_cnt <= (others=>'0');
      end if;
   end if;
end process;
 
-- ----------------------------------------------------------------------------
--state machine to control when to read from FIFO
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
fsm : process(current_state, fifo_rdempty, rd_wait_cnt, rd_wait_cnt_max_reg, en) begin
   next_state <= current_state;
   case current_state is
   
      when idle => --idle state
         if en = '1' then
            if fifo_rdempty = '0' then 
               next_state <= rd_samples;
            else 
               next_state <= zero_samples;
            end if;
         else 
            next_state <= idle;
         end if;
         
      when rd_samples => 
         next_state <= wait_rd_cycles;
      
      when wait_rd_cycles =>
         if rd_wait_cnt = rd_wait_cnt_max_reg then 
            if fifo_rdempty = '0' AND en = '1' then 
               next_state <= rd_samples;
            elsif fifo_rdempty = '1' AND en = '1' then
               next_state <= zero_samples;
            else 
               next_state <= idle;
            end if;
         else 
            next_state <= wait_rd_cycles;
         end if;
         
      when zero_samples => 
         next_state <= wait_rd_cycles;
                  
      when others => 
         next_state<=idle;
   end case;
end process;

-- ----------------------------------------------------------------------------
-- FIFO read signal
-- ----------------------------------------------------------------------------
process(current_state)
begin
   if current_state = rd_samples then 
      int_fifo_rdreq <= '1';
   else 
      int_fifo_rdreq <= '0';
   end if;
end process;

--To avoid reading from empty FIFO
fifo_rdreq <= int_fifo_rdreq AND NOT fifo_rdempty;

-- ----------------------------------------------------------------------------
-- Internal valdid data signal (delayed int_fifo_rdreq version)
-- ----------------------------------------------------------------------------
process(clk, reset_n)
 begin
   if reset_n = '0' then
      int_fifo_q_valid  <= '0';
      zero_valid        <= '0';
   elsif (clk'event AND clk = '1') then
      int_fifo_q_valid <= int_fifo_rdreq;
      if current_state = zero_samples then 
         zero_valid <= '1';
      else 
         zero_valid <= '0';
      end if;
   end if;
 end process;
 
-- ----------------------------------------------------------------------------
-- TX activity indication
-- ----------------------------------------------------------------------------
process(clk, reset_n)
 begin
   if reset_n = '0' then
      txant_en  <= '0';
   elsif (clk'event AND clk = '1') then
      if current_state = idle then 
         txant_en <= '0';
      else 
         txant_en <= '1';
      end if;
   end if;
 end process;
 
 
-- ----------------------------------------------------------------------------
-- Shift reg array with synchronous load 
-- ----------------------------------------------------------------------------
diq_L_reg_x_proc : process(reset_n, clk)
   begin
      if reset_n='0' then
         diq_L_reg_0 <= (others=>'0');
         diq_L_reg_1 <= (others=>'0');
         diq_L_reg_2 <= (others=>'0');
         diq_L_reg_3 <= (others=>'0');
      elsif (clk'event and clk = '1') then
         if int_fifo_q_valid ='1' then 
            diq_L_reg_0 <= int_fsync_L(0) & mux_pos0_L;
            diq_L_reg_1 <= int_fsync_L(1) & mux_pos1_L;
            diq_L_reg_2 <= int_fsync_L(2) & mux_pos2_L;
            diq_L_reg_3 <= int_fsync_L(3) & mux_pos3_L;
         elsif zero_valid = '1' then 
            diq_L_reg_0 <= int_fsync_L(0) & (iq_width-1 downto 0  =>'0');
            diq_L_reg_1 <= int_fsync_L(1) & (iq_width-1 downto 0  =>'0');
            diq_L_reg_2 <= int_fsync_L(2) & (iq_width-1 downto 0  =>'0');
            diq_L_reg_3 <= int_fsync_L(3) & (iq_width-1 downto 0  =>'0');
         else 
            diq_L_reg_0 <= diq_L_reg_1;
            diq_L_reg_1 <= diq_L_reg_2;
            diq_L_reg_2 <= diq_L_reg_3;
            diq_L_reg_3 <= (others=>'0');
         end if; 
      end if;
end process;
     
-- ----------------------------------------------------------------------------
-- Shift reg array with synchronous load 
-- ----------------------------------------------------------------------------
diq_H_reg_x_proc : process(reset_n, clk)
   begin
      if reset_n='0' then
         diq_H_reg_0 <= (others=>'0');
         diq_H_reg_1 <= (others=>'0');
         diq_H_reg_2 <= (others=>'0');
         diq_H_reg_3 <= (others=>'0');
      elsif (clk'event and clk = '1') then
         if int_fifo_q_valid ='1' then 
            diq_H_reg_0 <= int_fsync_H(0) & mux_pos0_H;
            diq_H_reg_1 <= int_fsync_H(1) & mux_pos1_H;
            diq_H_reg_2 <= int_fsync_H(2) & mux_pos2_H;
            diq_H_reg_3 <= int_fsync_H(3) & mux_pos3_H;
         elsif zero_valid = '1' then
            diq_H_reg_0 <= int_fsync_H(0) & (iq_width-1 downto 0  =>'0');
            diq_H_reg_1 <= int_fsync_H(1) & (iq_width-1 downto 0  =>'0');
            diq_H_reg_2 <= int_fsync_H(2) & (iq_width-1 downto 0  =>'0');
            diq_H_reg_3 <= int_fsync_H(3) & (iq_width-1 downto 0  =>'0');           
         else 
            diq_H_reg_0 <= diq_H_reg_1;
            diq_H_reg_1 <= diq_H_reg_2;
            diq_H_reg_2 <= diq_H_reg_3;
            diq_H_reg_3 <= (others=>'0');
         end if; 
      end if;
end process;
    
--To output ports   
DIQ_l <= diq_L_reg_0;
DIQ_h <= diq_H_reg_0; 
 
end arch;   


