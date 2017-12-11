-- ----------------------------------------------------------------------------	
-- FILE: 	rxiq_pulse_ddr.vhd
-- DESCRIPTION:	rxiq samples in MIMO DDR mode
-- DATE:	Jan 13, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity rxiq_pulse_ddr is
   generic(
      iq_width		: integer := 12
   );
  port (
      clk         : in std_logic;
      reset_n     : in std_logic;
		ch_en			: in std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
      fidm		   : in std_logic; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      --Rx interface data 
      DIQ_h		 	: in std_logic_vector(iq_width downto 0);
		DIQ_l	 	   : in std_logic_vector(iq_width downto 0);
      --fifo ports 
      fifo_wfull  : in std_logic;
      fifo_wrreq  : out std_logic;
      fifo_wdata  : out std_logic_vector(iq_width*4-1 downto 0)   
        );
end rxiq_pulse_ddr;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of rxiq_pulse_ddr is
--declare signals,  components here

signal reg_h_0        	   : std_logic_vector(iq_width downto 0);
signal reg_l_0        	   : std_logic_vector(iq_width downto 0);

signal diq_pos0_chA_0_reg  : std_logic_vector(iq_width-1 downto 0);
signal diq_pos1_chA_0_reg  : std_logic_vector(iq_width-1 downto 0);
signal diq_pos2_chB_0_reg  : std_logic_vector(iq_width-1 downto 0);
signal diq_pos3_chB_0_reg  : std_logic_vector(iq_width-1 downto 0);

signal diq_pos0_chA_1_reg  : std_logic_vector(iq_width-1 downto 0);
signal diq_pos1_chA_1_reg  : std_logic_vector(iq_width-1 downto 0);
signal diq_pos2_chB_1_reg  : std_logic_vector(iq_width-1 downto 0);
signal diq_pos3_chB_1_reg  : std_logic_vector(iq_width-1 downto 0);

signal diq_pos0_1_cap_en	: std_logic;

signal diq_chA_0_cap_en    : std_logic;
signal diq_chA_1_cap_en    : std_logic;
signal diq_chB_0_cap_en    : std_logic;
signal diq_chB_1_cap_en    : std_logic;

signal diq_chA_0_cap       : std_logic;
signal diq_chA_1_cap       : std_logic;
signal diq_chB_0_cap       : std_logic;
signal diq_chB_1_cap       : std_logic;

signal diq_valid    	      : std_logic;

signal mux_fifo_wrreq      : std_logic;
signal mux_fifo_wdata      : std_logic_vector(iq_width*4-1 downto 0);

signal fifo_wrreq_reg      : std_logic;
signal fifo_wdata_reg      : std_logic_vector(iq_width*4-1 downto 0);

signal chA_data			   : std_logic_vector(iq_width*4-1 downto 0);
signal chA_data_valid	   : std_logic;

signal chB_data			   : std_logic_vector(iq_width*4-1 downto 0);
signal chB_data_valid	   : std_logic;

signal chAB_data			   : std_logic_vector(iq_width*4-1 downto 0);
signal chAB_data_valid	   : std_logic;

type state_type is (idle, chA_0_cap, chA_1_cap, chB_0_cap, chB_1_cap);
signal current_state, next_state : state_type;



begin
 
 diq_valid<=   (reg_h_0(iq_width) AND DIQ_h(iq_width)) AND 
               (reg_l_0(iq_width) XOR DIQ_l(iq_width));
            
 
 reg_proc : process(reset_n, clk)
    begin
      if reset_n='0' then
			reg_h_0<=(others=>'0');
         reg_l_0<=(others=>'0');
      elsif (clk'event and clk = '1') then
			reg_h_0<=DIQ_h; 
         reg_l_0<=DIQ_l; 
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
fsm : process(current_state, diq_valid, diq_chA_0_cap, diq_chA_1_cap, diq_chB_0_cap, diq_chB_1_cap, ch_en) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => --idle state
         if diq_valid = '1' then
            if ch_en(0)='1' then 
               next_state <= chA_0_cap;
            else 
               next_state <= chB_0_cap;
            end if;
         else 
            next_state <= idle;
         end if;
      
      when chA_0_cap => 
         if diq_chA_0_cap = '1' then
            if ch_en(1)='0' then 
               next_state <= chA_1_cap;
            else 
               next_state <= chB_0_cap;
            end if;
         else 
            next_state <= chA_0_cap;
         end if;
         
      when chA_1_cap =>
         if diq_valid = '1' then
            if diq_chA_1_cap = '1' then
               next_state <= chA_0_cap;
            else 
               next_state <= chA_1_cap;
            end if;
         else
            next_state <= idle;
         end if;
         
      when chB_0_cap => 
         if diq_chB_0_cap = '1' then
            if ch_en(0)='0' then
               next_state <= chB_1_cap;
            else 
               next_state <= chA_0_cap;
            end if;
         else 
            next_state <= chB_0_cap;
         end if;
         
      when chB_1_cap =>
         if diq_valid = '1' then         
            if diq_chB_1_cap = '1' then
               next_state <= chB_0_cap;              
            else 
               next_state <= chB_1_cap;
            end if;
         else
            next_state <= idle;
         end if;
      
		when others => 
			next_state<=idle;
         
	end case;
end process;

-- ----------------------------------------------------------------------------
-- diq_ch reg enable signals
-- ----------------------------------------------------------------------------
process(current_state, ch_en)
begin 
   if current_state = chA_0_cap OR ch_en = "11" then 
      diq_chA_0_cap_en <= '1';
   else 
      diq_chA_0_cap_en <= '0';
   end if;
end process;

process(current_state)
begin 
   if current_state = chA_1_cap then 
      diq_chA_1_cap_en <= '1';
   else 
      diq_chA_1_cap_en <= '0';
   end if;
end process;

process(current_state, ch_en, diq_chA_0_cap)
begin 
   if ((current_state = chB_0_cap) OR (ch_en = "11" AND diq_chA_0_cap='1')) then 
      diq_chB_0_cap_en <= '1';
   else 
      diq_chB_0_cap_en <= '0';
   end if;
end process;

process(current_state)
begin 
   if current_state = chB_1_cap then 
      diq_chB_1_cap_en <= '1';
   else 
      diq_chB_1_cap_en <= '0';
   end if;
end process;
    
    
-- ----------------------------------------------------------------------------
-- To capture DIQ data in 0,1 positions (frame start),Ch. A., 
-- ch_en="11" - first FIFO word
-- ch_en="10" - not captured
-- ----------------------------------------------------------------------------
 diq_chA_0_reg_proc : process(reset_n, clk)
    begin
      if reset_n='0' then
         diq_pos0_chA_0_reg <= (others=>'0');
         diq_pos1_chA_0_reg <= (others=>'0');
         diq_chA_0_cap<='0';
      elsif (clk'event and clk = '1') then
			if DIQ_l(iq_width) = fidm AND diq_valid='1' AND diq_chA_0_cap_en='1' then 
         	diq_pos0_chA_0_reg <= DIQ_l(iq_width-1 downto 0);
            diq_pos1_chA_0_reg <= DIQ_h(iq_width-1 downto 0);
            diq_chA_0_cap<='1';
			else 
				diq_pos0_chA_0_reg <= diq_pos0_chA_0_reg;
				diq_pos1_chA_0_reg <= diq_pos1_chA_0_reg;
            diq_chA_0_cap<='0';
			end if; 
 	    end if;
    end process;

-- ----------------------------------------------------------------------------
-- To capture DIQ data in 0,1 positions (frame start), Ch. A., 
-- ch_en="11" - not captured
-- ch_en="01" - second fifo word
-- ----------------------------------------------------------------------------
 diq_chA_1_reg_proc : process(reset_n, clk)
    begin
      if reset_n='0' then
         diq_pos0_chA_1_reg <= (others=>'0');
         diq_pos1_chA_1_reg <= (others=>'0');
         diq_chA_1_cap<='0';
      elsif (clk'event and clk = '1') then
			if DIQ_l(iq_width) = fidm AND diq_valid='1' AND diq_chA_1_cap_en='1' then 
         	diq_pos0_chA_1_reg <= DIQ_l(iq_width-1 downto 0);
            diq_pos1_chA_1_reg <= DIQ_h(iq_width-1 downto 0);
            diq_chA_1_cap<='1';
			else 
				diq_pos0_chA_1_reg <= diq_pos0_chA_1_reg;
				diq_pos1_chA_1_reg <= diq_pos1_chA_1_reg;
            diq_chA_1_cap<='0';
			end if; 
 	    end if;
    end process;

-- ----------------------------------------------------------------------------
-- To capture DIQ data in 2,3 positions, Ch. B., second FIFO word
-- ch_en="11" - second fifo word
-- ch_en="01" - not captured
-- ----------------------------------------------------------------------------
 diq_chB_0_reg_proc : process(reset_n, clk)
    begin
      if reset_n='0' then
         diq_pos2_chB_0_reg <= (others=>'0');
         diq_pos3_chB_0_reg <= (others=>'0');
         diq_chB_0_cap<='0';
      elsif (clk'event and clk = '1') then
			if DIQ_l(iq_width) /= fidm AND diq_valid='1' AND diq_chB_0_cap_en='1' then 
         	diq_pos2_chB_0_reg <= DIQ_l(iq_width-1 downto 0);
            diq_pos3_chB_0_reg <= DIQ_h(iq_width-1 downto 0);
            diq_chB_0_cap<='1';
			else 
				diq_pos2_chB_0_reg <= diq_pos2_chB_0_reg;
				diq_pos3_chB_0_reg <= diq_pos3_chB_0_reg;
            diq_chB_0_cap<='0';
			end if; 
 	    end if;
    end process;

-- ----------------------------------------------------------------------------
-- To capture DIQ data in 3 position, Ch. B
-- ----------------------------------------------------------------------------
 diq_chB_1_reg_proc : process(reset_n, clk)
    begin
      if reset_n='0' then
         diq_pos2_chB_1_reg <= (others=>'0');
         diq_pos3_chB_1_reg <= (others=>'0');
         diq_chB_1_cap<='0';
      elsif (clk'event and clk = '1') then
			if DIQ_l(iq_width) /= fidm AND diq_valid='1' AND diq_chB_1_cap_en='1' then 
         	diq_pos2_chB_1_reg <= DIQ_l(iq_width-1 downto 0);
            diq_pos3_chB_1_reg <= DIQ_h(iq_width-1 downto 0);
            diq_chB_1_cap<='1';
			else 
				diq_pos2_chB_1_reg <= diq_pos2_chB_1_reg;
				diq_pos3_chB_1_reg <= diq_pos3_chB_1_reg;
            diq_chB_1_cap<='0';
			end if; 
 	    end if;
    end process;
    
    
--chA_data       <=	diq_pos0_chA_0_reg & diq_pos1_chA_0_reg & diq_pos0_chA_1_reg & diq_pos1_chA_1_reg;
chA_data       <=	diq_pos1_chA_1_reg & diq_pos0_chA_1_reg & diq_pos1_chA_0_reg & diq_pos0_chA_0_reg;		
chA_data_valid <= diq_chA_1_cap;

--chB_data		   <= diq_pos2_chB_0_reg & diq_pos3_chB_0_reg & diq_pos2_chB_1_reg & diq_pos3_chB_1_reg;
chB_data		   <= diq_pos3_chB_1_reg & diq_pos2_chB_1_reg & diq_pos3_chB_0_reg & diq_pos2_chB_0_reg;
chB_data_valid <= diq_chB_1_cap;

--chAB_data      <= diq_pos0_chA_0_reg & diq_pos1_chA_0_reg & diq_pos2_chB_0_reg & diq_pos3_chB_0_reg;
chAB_data      <= diq_pos3_chB_0_reg & diq_pos2_chB_0_reg & diq_pos1_chA_0_reg & diq_pos0_chA_0_reg;
chAB_data_valid<= diq_chB_0_cap;


--output mux
mux_fifo_wdata <=   chAB_data when ch_en="11" else 
                    chB_data when ch_en="10" else
                    chA_data;
               
mux_fifo_wrreq <=   chAB_data_valid when ch_en="11" else 
                    chB_data_valid when ch_en="10" else
                    chA_data_valid;
                     
            
                     
 --output port registers    
out_reg_fifo_wdata : process (reset_n, clk)
begin
   if reset_n = '0' then 
      fifo_wdata_reg <= (others=>'0');
      fifo_wrreq_reg <= '0';
   elsif (clk'event and clk='1') then 
      fifo_wdata_reg <= mux_fifo_wdata;
      fifo_wrreq_reg <= mux_fifo_wrreq;
   end if;
end process; 

fifo_wdata <= fifo_wdata_reg;
fifo_wrreq <= fifo_wrreq_reg AND NOT fifo_wfull;             

        
        

end arch;   







