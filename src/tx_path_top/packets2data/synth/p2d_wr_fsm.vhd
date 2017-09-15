-- ----------------------------------------------------------------------------	
-- FILE: 	p2d_wr_fsm.vhd
-- DESCRIPTION:	For decoding packets.
-- DATE:	March 31, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	

-- ----------------------------------------------------------------------------
-- Notes:
-- TODO: implement changeable in_pct_data_w parameter,
-- TODO: implement changeable pct_size_w parameter
-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.math_real.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity p2d_wr_fsm is
   generic (
      pct_size_w        : integer := 16;
      n_buff            : integer := 4; -- 2,4 valid values
      in_pct_data_w     : integer := 32
   );
   port (
      clk               : in std_logic;
      reset_n           : in std_logic;
      pct_size          : in std_logic_vector(pct_size_w-1 downto 0);   --Whole packet size in 
                                                                        --in_pct_data_w words
      
      in_pct_wrreq      : in std_logic;
      in_pct_data       : in std_logic_vector(in_pct_data_w-1 downto 0);
      in_pct_wrfull     : out std_logic; -- not registered, comb signal 
      
      pct_hdr_0         : out std_logic_vector(63 downto 0);
      pct_hdr_0_valid   : out std_logic_vector(n_buff-1 downto 0);
      
      pct_hdr_1         : out std_logic_vector(63 downto 0);
      pct_hdr_1_valid   : out std_logic_vector(n_buff-1 downto 0);
      
      pct_data          : out std_logic_vector(31 downto 0);
      pct_data_wrreq    : out std_logic_vector(n_buff-1 downto 0);

      pct_buff_rdy      : in std_logic_vector(n_buff-1 downto 0)
      
        );
end p2d_wr_fsm;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of p2d_wr_fsm is
--declare signals,  components here

signal in_pct_data_reg        : std_logic_vector(in_pct_data_w-1 downto 0);

signal wr_cnt                 : unsigned(pct_size_w-1 downto 0);
signal wr_cnt_end             : std_logic;


signal pct_hdr_0_reg          : std_logic_vector(63 downto 0);      
signal pct_hdr_0_valid_reg    : std_logic;

signal pct_hdr_1_reg          : std_logic_vector(63 downto 0); 
signal pct_hdr_1_valid_reg    : std_logic;

signal pct_data_wrreq_int     : std_logic;

signal buff_sel               : std_logic_vector(n_buff-1 downto 0);
signal buff_sel_cnt           : unsigned(integer(ceil(log2(real(n_buff))))-1 downto 0); 
signal buff_sel_cnt_reg       : unsigned(integer(ceil(log2(real(n_buff))))-1 downto 0);
signal buff_rdy               : std_logic;
signal buff_check_limit       : unsigned(pct_size_w-1 downto 0);
signal pct_size_limit         : unsigned(pct_size_w-1 downto 0);
signal in_pct_wrfull_int      : std_logic;

signal pct_data_reg           : std_logic_vector(31 downto 0);    
signal pct_data_wrreq_reg     : std_logic_vector(n_buff-1 downto 0);
signal pct_data_wrreq_comb    : std_logic_vector(n_buff-1 downto 0);


type state_type is (idle, wait_hdr_1, wait_pct_end, wait_rdy, switch_buff);
signal current_state, next_state : state_type;               



begin


-- ----------------------------------------------------------------------------
-- To calculate limits
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      buff_check_limit <= (others=>'1');
      pct_size_limit <= (others=>'1');
   elsif (clk'event AND clk='1') then 
      buff_check_limit  <= unsigned(pct_size)-2;
      pct_size_limit    <= unsigned(pct_size)-1;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- Counter for selecting new buffer
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      buff_sel_cnt <= (others=>'0');
      buff_sel_cnt_reg <= (others=>'0');
   elsif (clk'event AND clk='1') then
      if pct_hdr_0_valid_reg = '1' then 
         buff_sel_cnt <= buff_sel_cnt+1;
      else 
         buff_sel_cnt <= buff_sel_cnt;
      end if;
      
      if current_state = switch_buff then 
         buff_sel_cnt_reg <= buff_sel_cnt;
      else
         buff_sel_cnt_reg <= buff_sel_cnt_reg;
      end if;
      
   end if;
end process;

-- ----------------------------------------------------------------------------
-- To select buffer and show selected buffer status
-- ----------------------------------------------------------------------------
process(buff_sel_cnt,pct_buff_rdy)
begin
   buff_rdy <= pct_buff_rdy(to_integer(buff_sel_cnt));
end process;


process(in_pct_wrreq,wr_cnt_end,buff_rdy, in_pct_wrfull_int)
begin
      if wr_cnt_end = '1' AND in_pct_wrreq = '1' then 
         in_pct_wrfull_int <= NOT buff_rdy;
      else
         in_pct_wrfull_int <= '0';
      end if;
end process;

-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------
fsm_f : process(clk, reset_n)begin
	if(reset_n = '0')then
		current_state <= idle;
	elsif(clk'event and clk = '1')then
      if in_pct_wrreq = '1' then 
         current_state <= next_state;
      else 
         current_state <= current_state;
      end if;
	end if;	
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, pct_hdr_1_valid_reg, wr_cnt_end, buff_rdy, in_pct_wrreq, wr_cnt) begin
	next_state <= current_state;
	case current_state is
	  
		when idle =>
         if buff_rdy = '1' then
            next_state <= wait_hdr_1;
         else 
            next_state <= idle;
         end if;
         
      when wait_hdr_1 => 
         if in_pct_wrreq = '1' AND wr_cnt = 3 then 
            next_state <= wait_pct_end;
         else 
            next_state <= wait_hdr_1;
         end if;
         
      when wait_pct_end =>
         if wr_cnt_end = '1' then
            if buff_rdy = '1' then 
               next_state <= switch_buff;
            else 
               next_state <= wait_rdy;
            end if;
         else 
            next_state <= wait_pct_end;
         end if;
       
      when wait_rdy => 
         if buff_rdy = '1' then 
            next_state <= switch_buff;
         else 
            next_state <= wait_rdy;
         end if;
         
      when switch_buff => 
         next_state <= idle;
         
		when others => 
			next_state <= idle;
	end case;
end process;


-- ----------------------------------------------------------------------------
-- In packed data register
-- ----------------------------------------------------------------------------
in_reg_proc : process(clk, reset_n)
begin
   if reset_n = '0' then 
      in_pct_data_reg <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      if in_pct_wrreq = '1' then 
         in_pct_data_reg <= in_pct_data;
      else 
         in_pct_data_reg <= in_pct_data_reg;
      end if;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- Packet write counter
-- ----------------------------------------------------------------------------
pct_count_proc : process(clk, reset_n)
begin
   if reset_n = '0' then 
      wr_cnt <= (others=>'0');
      wr_cnt_end <= '0';
   elsif (clk'event AND clk='1') then 
      if in_pct_wrreq = '1' then 
         if wr_cnt < pct_size_limit then 
            wr_cnt <= wr_cnt+1;
         else 
            wr_cnt <= (others=>'0');
         end if;
         --for fsm
         if wr_cnt = buff_check_limit then 
            wr_cnt_end <= '1';
         else
            wr_cnt_end <= '0';
         end if;
         
      else 
         wr_cnt <= wr_cnt;
      end if;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- Packet header 0 register
-- ----------------------------------------------------------------------------
hdr0_reg : process(clk, reset_n)
begin
   if reset_n = '0' then 
      pct_hdr_0_reg        <= (others=>'0');     
      pct_hdr_0_valid_reg  <= '0';
   elsif (clk'event AND clk='1') then 
      if in_pct_wrreq = '1' AND wr_cnt = 1 then
         pct_hdr_0_reg        <= in_pct_data & in_pct_data_reg;     
         pct_hdr_0_valid_reg  <= '1';
      else 
         pct_hdr_0_reg        <= pct_hdr_0_reg;     
         pct_hdr_0_valid_reg  <= '0';
      end if;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- Packet header 1 register
-- ----------------------------------------------------------------------------
hdr1_reg : process(clk, reset_n)
begin
   if reset_n = '0' then 
      pct_hdr_1_reg        <= (others=>'0');     
      pct_hdr_1_valid_reg  <= '0';
   elsif (clk'event AND clk='1') then 
      if in_pct_wrreq = '1' AND wr_cnt = 3 then
         pct_hdr_1_reg        <= in_pct_data & in_pct_data_reg;     
         pct_hdr_1_valid_reg  <= '1';
      else 
         pct_hdr_1_reg        <= pct_hdr_1_reg;     
         pct_hdr_1_valid_reg  <= '0';
      end if;
   end if;
end process;


-- ----------------------------------------------------------------------------
-- Packet wrreq internal signal
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then    
      pct_data_wrreq_int  <= '0';
   elsif (clk'event AND clk='1') then 
      if in_pct_wrreq = '1' AND current_state = wait_pct_end then  
         pct_data_wrreq_int  <= '1';
      else    
         pct_data_wrreq_int  <= '0';
      end if;
   end if;
end process;


-- ----------------------------------------------------------------------------
-- Buffer select signal 
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then    
      buff_sel(0)  <= '1';
      buff_sel(n_buff-1 downto 1) <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      if current_state = switch_buff then 
         for i in 0 to n_buff-1 loop
            if i = buff_sel_cnt then 
               buff_sel(i) <= '1';
            else 
               buff_sel(i) <= '0';
            end if;
         end loop;
      else    
         buff_sel  <= buff_sel;
      end if;
   end if;
end process;
-- ----------------------------------------------------------------------------
-- Buffer write select signal 
-- ----------------------------------------------------------------------------
process(pct_data_wrreq_int,buff_sel_cnt_reg)
begin
   for i in 0 to n_buff-1 loop
      if i = buff_sel_cnt_reg then 
         pct_data_wrreq_comb(i) <= pct_data_wrreq_int;
      else 
         pct_data_wrreq_comb(i) <= '0';
      end if;
   end loop;
end process;

-- ----------------------------------------------------------------------------
-- Packet header capture valid signal 
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      pct_hdr_0_valid <= (others=>'0');
      pct_hdr_1_valid <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      for i in 0 to n_buff-1 loop 
         pct_hdr_0_valid(i) <= buff_sel(i) AND pct_hdr_0_valid_reg;
         pct_hdr_1_valid(i) <= buff_sel(i) AND pct_hdr_1_valid_reg;
      end loop;
   end if;
end process;



proc_name : process(clk, reset_n)
begin
   if reset_n = '0' then 
      pct_data_reg         <= (others=>'0');      
      pct_data_wrreq_reg   <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      pct_data_reg         <= in_pct_data_reg;      
      pct_data_wrreq_reg   <= pct_data_wrreq_comb;
   end if;
end process;

pct_hdr_0      <= pct_hdr_0_reg;
pct_hdr_1      <= pct_hdr_1_reg;
pct_data       <= pct_data_reg;
pct_data_wrreq <= pct_data_wrreq_reg;
in_pct_wrfull  <= in_pct_wrfull_int;



end arch;   





