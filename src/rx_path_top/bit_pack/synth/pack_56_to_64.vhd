-- ----------------------------------------------------------------------------
-- FILE: pack_56_to_64.vhd
-- DESCRIPTION:packs bits from 56 to 64 bits
-- DATE:Nov 14, 2016
-- AUTHOR(s):Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pack_56_to_64 is
   port (
   --input ports 
      clk            : in std_logic;
      reset_n        : in std_logic;
      data_in_wrreq  : in std_logic;
      data56_in      : in std_logic_vector(55 downto 0);
      data64_out     : out std_logic_vector(63 downto 0);
      data_out_valid : out std_logic
      );
end pack_56_to_64;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pack_56_to_64 is
--declare signals,  components here

signal word64_0               : std_logic_vector(63 downto 0);
signal word64_1               : std_logic_vector(63 downto 0);
signal word64_2               : std_logic_vector(63 downto 0);
signal word64_3               : std_logic_vector(63 downto 0);
signal word64_4               : std_logic_vector(63 downto 0);
signal word64_5               : std_logic_vector(63 downto 0);
signal word64_6               : std_logic_vector(63 downto 0);
      
signal word64_0_valid         : std_logic;
signal word64_1_valid         : std_logic;
signal word64_2_valid         : std_logic;
signal word64_3_valid         : std_logic;
signal word64_4_valid         : std_logic;
signal word64_5_valid         : std_logic;
signal word64_6_valid         : std_logic;

signal word64_0_valid_pipe    : std_logic_vector(2 downto 0);
signal word64_1_valid_pipe    : std_logic_vector(2 downto 0);
signal word64_2_valid_pipe    : std_logic_vector(2 downto 0);
signal word64_3_valid_pipe    : std_logic_vector(2 downto 0);
signal word64_4_valid_pipe    : std_logic_vector(2 downto 0);
signal word64_5_valid_pipe    : std_logic_vector(2 downto 0);
signal word64_6_valid_pipe    : std_logic_vector(2 downto 0);


signal wr_cnt                 : unsigned(2 downto 0);


signal data56_in_reg          : std_logic_vector(55 downto 0);

--output mux network
signal mux_stage0_X_0         : std_logic_vector(63 downto 0);
signal mux_stage0_2_1         : std_logic_vector(63 downto 0);
signal mux_stage0_4_3         : std_logic_vector(63 downto 0);
signal mux_stage0_6_5         : std_logic_vector(63 downto 0);

signal mux_stage0_X_0_reg     : std_logic_vector(63 downto 0);
signal mux_stage0_2_1_reg     : std_logic_vector(63 downto 0);
signal mux_stage0_4_3_reg     : std_logic_vector(63 downto 0);
signal mux_stage0_6_5_reg     : std_logic_vector(63 downto 0);

signal word64_0_en_reg_stage0 : std_logic;
signal word64_3_en_reg_stage0 : std_logic;
signal word64_4_en_reg_stage0 : std_logic;

signal mux_stage1_2_0         : std_logic_vector(63 downto 0);
signal mux_stage1_6_3         : std_logic_vector(63 downto 0);

signal mux_stage1_2_0_reg     : std_logic_vector(63 downto 0);
signal mux_stage1_6_3_reg     : std_logic_vector(63 downto 0);

signal mux_stage1_2_0_sel     : std_logic;
signal mux_stage1_6_3_sel_0   : std_logic;
signal mux_stage1_6_3_sel_1   : std_logic;

signal mux_stage2_6_0         : std_logic_vector(63 downto 0);
signal mux_stage2_6_0_sel     : std_logic;
signal mux_stage2_6_0_reg     : std_logic_vector(63 downto 0);

signal data_out_valid_reg     : std_logic;
signal data_out_valid_pipe    : std_logic_vector(1 downto 0);


 
begin

-- ----------------------------------------------------------------------------
-- Input data register
-- ----------------------------------------------------------------------------
process(reset_n, clk)
begin
   if reset_n = '0' then
      data56_in_reg <= (others=>'0');
   elsif (clk'event and clk = '1') then
      if data_in_wrreq = '1' then 
         data56_in_reg <= data56_in;
      else 
         data56_in_reg <= data56_in_reg;
      end if;
   end if;
end process;


-- ----------------------------------------------------------------------------
-- Write counter
-- ----------------------------------------------------------------------------
process(clk, reset_n) is 
begin 
   if reset_n = '0' then 
      wr_cnt <= (others=>'0');
   elsif (clk'event and clk = '1') then
      if  data_in_wrreq = '1' then 
         if wr_cnt < 7 then 
            wr_cnt <= wr_cnt+1;
         else 
            wr_cnt <= (others=>'0');
         end if;
      else
         wr_cnt <= wr_cnt;
      end if;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- 64b word formation
-- ----------------------------------------------------------------------------
--1 stage

process(reset_n, clk)
begin
   if reset_n = '0' then
      word64_0 <= (others=>'0');
      word64_0_valid <= '0';
   elsif (clk'event and clk = '1') then
      if wr_cnt = 1 and data_in_wrreq = '1' then 
         --word64_0<=data56_in(55 downto 48) & data56_in_reg;
         word64_0 <= data56_in(7 downto 0) & data56_in_reg;
         word64_0_valid <= '1';
      else 
         word64_0 <= word64_0;
         word64_0_valid <= '0';
      end if;
   end if;
end process;
 
--2 stage

process(reset_n, clk)
begin
   if reset_n = '0' then
      word64_1 <= (others=>'0');
      word64_1_valid <= '0';
   elsif (clk'event and clk = '1') then
      if wr_cnt = 2 and data_in_wrreq = '1' then
         --word64_1<=data56_in(55 downto 40) & data56_in_reg(47 downto 0);
         word64_1 <= data56_in(15 downto 0) & data56_in_reg(55 downto 8);
         word64_1_valid <= '1';
      else 
         word64_1 <= word64_1;
         word64_1_valid <= '0';
      end if;
   end if;
end process;

--3 stage

process(reset_n, clk)
begin
   if reset_n = '0' then
      word64_2 <= (others=>'0');
      word64_2_valid <= '0';
   elsif (clk'event and clk = '1') then
      if wr_cnt = 3 and data_in_wrreq = '1' then
         --word64_2<=data56_in(55 downto 32) & data56_in_reg(39 downto 0);
         word64_2 <=  data56_in(23 downto 0) & data56_in_reg(55 downto 16);
         word64_2_valid <='1';
      else 
         word64_2 <= word64_2;
         word64_2_valid <= '0';
      end if;
   end if;
end process;
 
--4 stage

process(reset_n, clk)
begin
   if reset_n = '0' then
      word64_3 <= (others=>'0');
      word64_3_valid <= '0';
   elsif (clk'event and clk = '1') then
      if wr_cnt = 4 and data_in_wrreq = '1' then
         --word64_3<=data56_in(55 downto 24) & data56_in_reg(31 downto 0);
         word64_3 <= data56_in(31 downto 0) & data56_in_reg(55 downto 24);
         word64_3_valid <= '1';
      else 
         word64_3 <= word64_3;
         word64_3_valid <= '0';
      end if;
   end if;
end process;

--5 stage

process(reset_n, clk)
begin
   if reset_n = '0' then
      word64_4 <= (others=>'0');
      word64_4_valid <= '0';
   elsif (clk'event and clk = '1') then
      if wr_cnt = 5 and data_in_wrreq = '1' then
         --word64_4<=data56_in(55 downto 16) & data56_in_reg(23 downto 0);
         word64_4 <=  data56_in(39 downto 0) & data56_in_reg(55 downto 32); 
         word64_4_valid <='1';
      else 
         word64_4 <= word64_4;
         word64_4_valid <= '0';
      end if;
   end if;
end process;

--6 stage 

process(reset_n, clk)
begin
   if reset_n = '0' then
      word64_5 <= (others=>'0');
      word64_5_valid<='0';
   elsif (clk'event and clk = '1') then
      if wr_cnt = 6 and data_in_wrreq = '1' then 
         --word64_5<=data56_in(55 downto 8) & data56_in_reg(15 downto 0);
         word64_5 <=  data56_in(47 downto 0) & data56_in_reg(55 downto 40);
         word64_5_valid <= '1';
      else 
         word64_5 <= word64_5;
         word64_5_valid <= '0';
      end if;
   end if;
end process;

--7 stage 

process(reset_n, clk)
begin
   if reset_n = '0' then
      word64_6 <= (others=>'0');
      word64_6_valid <= '0';
   elsif (clk'event and clk = '1') then
      if wr_cnt = 7 and data_in_wrreq = '1' then
         --word64_6<=data56_in(55 downto 0) & data56_in_reg(7 downto 0);
         word64_6 <=  data56_in(55 downto 0) & data56_in_reg(55 downto 48);
         word64_6_valid <= '1';
      else 
         word64_6 <= word64_6;
         word64_6_valid <= '0';
      end if;
   end if;
end process;
    
-- ----------------------------------------------------------------------------
-- Shift registers for word_valid signals 
-- ---------------------------------------------------------------------------- 
process(reset_n, clk)
begin
   if reset_n = '0' then
      word64_0_valid_pipe <= (others=>'0');
      word64_1_valid_pipe <= (others=>'0');
      word64_2_valid_pipe <= (others=>'0');
      word64_3_valid_pipe <= (others=>'0');
      word64_4_valid_pipe <= (others=>'0');
      word64_5_valid_pipe <= (others=>'0');
      word64_6_valid_pipe <= (others=>'0');
   elsif (clk'event and clk = '1') then
      word64_0_valid_pipe <= word64_0_valid_pipe(1 downto 0) & word64_0_valid;
      word64_1_valid_pipe <= word64_1_valid_pipe(1 downto 0) & word64_1_valid;
      word64_2_valid_pipe <= word64_2_valid_pipe(1 downto 0) & word64_2_valid;
      word64_3_valid_pipe <= word64_3_valid_pipe(1 downto 0) & word64_3_valid;
      word64_4_valid_pipe <= word64_4_valid_pipe(1 downto 0) & word64_4_valid;
      word64_5_valid_pipe <= word64_5_valid_pipe(1 downto 0) & word64_5_valid;
      word64_6_valid_pipe <= word64_6_valid_pipe(1 downto 0) & word64_6_valid;
   end if;
end process;   

 

-- ----------------------------------------------------------------------------
-- 32b word output
-- ----------------------------------------------------------------------------
--firts stage of mux
mux_stage0_X_0 <= word64_0 when word64_0_valid = '1' else (others=>'0');
mux_stage0_2_1 <= word64_1 when word64_1_valid = '1' else word64_2;
mux_stage0_4_3 <= word64_3 when word64_3_valid = '1' else word64_4;
mux_stage0_6_5 <= word64_5 when word64_5_valid = '1' else word64_6;
-- ----------------------------------------------------------------------------
-- Registers for MUX stage 0
-- ---------------------------------------------------------------------------- 
process(reset_n, clk)
begin
   if reset_n = '0' then
      mux_stage0_X_0_reg   <=(others=>'0');
      mux_stage0_2_1_reg   <=(others=>'0');
      mux_stage0_4_3_reg   <=(others=>'0');
      mux_stage0_6_5_reg   <=(others=>'0');
      mux_stage1_2_0_sel   <='0';
      mux_stage1_6_3_sel_0 <='0';
      mux_stage1_6_3_sel_1 <='0';
   elsif (clk'event and clk = '1') then
      mux_stage0_X_0_reg   <= mux_stage0_X_0;
      mux_stage0_2_1_reg   <= mux_stage0_2_1;
      mux_stage0_4_3_reg   <= mux_stage0_4_3;
      mux_stage0_6_5_reg   <= mux_stage0_6_5;
      mux_stage1_2_0_sel   <= (word64_1_valid OR word64_2_valid);
      mux_stage1_6_3_sel_0 <= (word64_3_valid OR word64_4_valid);  
      mux_stage1_6_3_sel_1 <= (word64_5_valid OR word64_6_valid);     
   end if;
end process;



--second stage of mux
mux_stage1_2_0 <= mux_stage0_X_0_reg when mux_stage1_2_0_sel = '0'   else mux_stage0_2_1_reg;
mux_stage1_6_3 <= mux_stage0_4_3_reg when mux_stage1_6_3_sel_1 = '0' else mux_stage0_6_5_reg;

-- ----------------------------------------------------------------------------
-- Registers for MUX stage 1
-- ---------------------------------------------------------------------------- 
process(reset_n, clk)
begin
   if reset_n = '0' then
      mux_stage1_2_0_reg <= (others=>'0');
      mux_stage1_6_3_reg <= (others=>'0');
      mux_stage2_6_0_sel <= '0';
   elsif (clk'event and clk = '1') then
      mux_stage1_2_0_reg <= mux_stage1_2_0;
      mux_stage1_6_3_reg <= mux_stage1_6_3;
      mux_stage2_6_0_sel <= (mux_stage1_6_3_sel_0 OR mux_stage1_6_3_sel_1); 
   end if;
end process;

--last stage of mux
mux_stage2_6_0 <= mux_stage1_2_0_reg when mux_stage2_6_0_sel = '0' else mux_stage1_6_3_reg;

process(reset_n, clk)
begin
   if reset_n = '0' then
      mux_stage2_6_0_reg <= (others=>'0');
   elsif (clk'event and clk = '1') then
      mux_stage2_6_0_reg <= mux_stage2_6_0;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- 32b word output valid signal
-- ----------------------------------------------------------------------------
process(reset_n, clk)
begin
   if reset_n = '0' then
      data_out_valid_reg   <='0';
      data_out_valid_pipe  <=(others=>'0');
   elsif (clk'event and clk = '1') then
      data_out_valid_reg   <= word64_0_valid OR word64_1_valid OR word64_2_valid OR word64_3_valid OR word64_4_valid OR word64_5_valid OR word64_6_valid;
      data_out_valid_pipe  <= data_out_valid_pipe(0) & data_out_valid_reg; 
   end if;
end process;
    
data64_out     <= mux_stage2_6_0_reg;
data_out_valid <= data_out_valid_pipe(1);

 

end arch;   



