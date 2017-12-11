-- ----------------------------------------------------------------------------    
-- FILE:     pack_48_to_64.vhd
-- DESCRIPTION:    packs bits from 48 to 64 bits
-- DATE:    Nov 14, 2016
-- AUTHOR(s):    Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------    
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pack_48_to_64 is
  port (
      --input ports 
      clk            : in std_logic;
      reset_n        : in std_logic;
      data_in_wrreq  : in std_logic;
      data48_in      : in std_logic_vector(47 downto 0);
      data64_out     : out std_logic_vector(63 downto 0);
      data_out_valid : out std_logic
        );
end pack_48_to_64;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pack_48_to_64 is
--declare signals,  components here

signal word64_0            : std_logic_vector(63 downto 0);
signal word64_1            : std_logic_vector(63 downto 0);
signal word64_2            : std_logic_vector(63 downto 0);

signal word64_0_valid      : std_logic;
signal word64_1_valid      : std_logic;
signal word64_2_valid      : std_logic;

signal data64_out_mux      : std_logic_vector(63 downto 0);
signal data64_out_reg      : std_logic_vector(63 downto 0);
signal data_out_valid_reg  : std_logic;

signal wr_cnt              : unsigned(1 downto 0);

signal data48_in_reg       : std_logic_vector(47 downto 0);

begin

-- ----------------------------------------------------------------------------
-- Input data register
-- ----------------------------------------------------------------------------
process(reset_n, clk)
begin
   if reset_n = '0' then
      data48_in_reg <= (others=>'0');
   elsif (clk'event and clk = '1') then
      if data_in_wrreq = '1' then 
         data48_in_reg <= data48_in;
      else 
         data48_in_reg <= data48_in_reg;
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
         if wr_cnt < 3 then 
            wr_cnt <= wr_cnt + 1;
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
process(reset_n, clk)
begin
   if reset_n = '0' then
      word64_0 <= (others=>'0');
      word64_0_valid <= '0';
   elsif (clk'event and clk = '1') then
      if wr_cnt = 1 and data_in_wrreq = '1' then 
         word64_0 <= data48_in(15 downto 0) & data48_in_reg;
         word64_0_valid <= '1';
      else 
         word64_0 <= word64_0;
         word64_0_valid <= '0';
      end if;
   end if;
end process;

process(reset_n, clk)
begin
   if reset_n = '0' then
      word64_1 <= (others=>'0');
      word64_1_valid <= '0';
   elsif (clk'event and clk = '1') then
      if wr_cnt = 2 and data_in_wrreq = '1' then 
         word64_1 <= data48_in(31 downto 0) & data48_in_reg(47 downto 16);
         word64_1_valid <= '1';
      else 
         word64_1 <= word64_1;
         word64_1_valid <= '0';
      end if;
   end if;
end process;

process(reset_n, clk)
begin
   if reset_n = '0' then
      word64_2 <= (others=>'0');
      word64_2_valid <= '0';
   elsif (clk'event and clk = '1') then
      if wr_cnt = 3 and data_in_wrreq = '1' then
         word64_2 <= data48_in(47 downto 0) & data48_in_reg(47 downto 32);
         word64_2_valid <= '1';
      else 
         word64_2 <= word64_2;
         word64_2_valid <= '0';
      end if;
   end if;
end process;


-- ----------------------------------------------------------------------------
-- 64b word output mux
-- ----------------------------------------------------------------------------
data64_out_mux<=  word64_0 when word64_0_valid = '1' else 
                  word64_1 when word64_1_valid = '1' else
                  word64_2;

-- ----------------------------------------------------------------------------
-- Output register stage
-- ----------------------------------------------------------------------------                  
process(reset_n, clk)
begin
   if reset_n = '0' then
      data64_out_reg       <= (others => '0');
      data_out_valid_reg   <= '0';        
   elsif (clk'event and clk = '1') then
      data64_out_reg     <= data64_out_mux; 
      data_out_valid_reg <= word64_0_valid OR word64_1_valid OR word64_2_valid;
   end if;
end process;
    
data64_out     <= data64_out_reg;
data_out_valid <= data_out_valid_reg;

end arch;   



