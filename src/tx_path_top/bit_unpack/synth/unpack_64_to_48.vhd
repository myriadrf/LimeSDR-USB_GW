
-- ----------------------------------------------------------------------------	
-- FILE: 	unpack_64_to_48.vhd
-- DESCRIPTION:	unpacks bits from 64b words to 12 bit samples
-- DATE:	March 30, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity unpack_64_to_48 is
  port (
      --input ports 
      clk       		: in std_logic;
      reset_n   		: in std_logic;
		data_in_wrreq	: in std_logic;
		data64_in		: in std_logic_vector(63 downto 0);
		data48_out		: out std_logic_vector(127 downto 0);
		data_out_valid	: out std_logic
       
        );
end unpack_64_to_48;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of unpack_64_to_48 is
--declare signals,  components here
signal word128_0		      : std_logic_vector(127 downto 0);
signal word128_1		      : std_logic_vector(127 downto 0);

signal word128_0_valid 	   : std_logic;
signal word128_1_valid	   : std_logic;

signal data128_out_mux     : std_logic_vector(127 downto 0);
signal data128_out_reg     : std_logic_vector(127 downto 0);
signal data_out_valid_reg  : std_logic;

signal wr_cnt			      : unsigned(1 downto 0);
signal data64_in_reg			: std_logic_vector(63 downto 0);
  
begin


-- ----------------------------------------------------------------------------
-- Input data register
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
			data64_in_reg<=(others=>'0');
      elsif (clk'event and clk = '1') then
         if data_in_wrreq = '1' then 
				data64_in_reg <= data64_in;
         else 
            data64_in_reg <= data64_in_reg;
         end if;
 	    end if;
    end process;
    
-- ----------------------------------------------------------------------------
-- Write counter
-- ----------------------------------------------------------------------------
process(clk, reset_n) is 
	begin 
		if reset_n='0' then 
			wr_cnt<=(others=>'0');
		elsif (clk'event and clk='1') then
			if  data_in_wrreq='1' then 
				if wr_cnt < 2 then 
					wr_cnt<=wr_cnt+1;
				else 
					wr_cnt<=(others=>'0');
				end if;
			else
				wr_cnt<=wr_cnt;
			end if;
		end if;
end process;


-- ----------------------------------------------------------------------------
-- 128b word formation
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
			word128_0<=(others=>'0');
         word128_0_valid<='0';
      elsif (clk'event and clk = '1') then
         if wr_cnt=1 and data_in_wrreq='1' then 
				word128_0<= data64_in(31 downto 20) & "0000" &
                        data64_in(19 downto 8) & "0000" & 
                        data64_in(7 downto 0) & data64_in_reg(63 downto 60) & "0000" &
                        data64_in_reg(59 downto 48) & "0000" &
                        data64_in_reg(47 downto 36) & "0000" &
                        data64_in_reg(35 downto 24) & "0000" &
                        data64_in_reg(23 downto 12) & "0000" &
                        data64_in_reg(11 downto 0) & "0000";
            word128_0_valid<='1';
			else 
				word128_0      <=word128_0;
            word128_0_valid<='0';
			end if;
 	    end if;
    end process;

  process(reset_n, clk)
    begin
      if reset_n='0' then
			word128_1<=(others=>'0');
         word128_1_valid<='0';
      elsif (clk'event and clk = '1') then
			if wr_cnt=2 and data_in_wrreq='1' then 
               word128_1<= data64_in(63 downto 52) & "0000" &
                           data64_in(51 downto 40) & "0000" &
                           data64_in(39 downto 28) & "0000" & 
                           data64_in(27 downto 16) & "0000" &
                           data64_in(15 downto 4) & "0000" & 
                           data64_in(3 downto 0) & data64_in_reg(63 downto 56) & "0000" &
                           data64_in_reg(55 downto 44) & "0000" & 
                           data64_in_reg(43 downto 32) & "0000";                   
            word128_1_valid<='1';
			else 
				word128_1<=word128_1;
            word128_1_valid<='0';
			end if;
 	    end if;
    end process;
    
-- ----------------------------------------------------------------------------
-- 128b word output mux
-- ----------------------------------------------------------------------------
data128_out_mux<=	word128_0 when word128_0_valid='1' else 
                  word128_1;

-- ----------------------------------------------------------------------------
-- Output register stage
-- ----------------------------------------------------------------------------                  
  process(reset_n, clk)
    begin
      if reset_n='0' then
         data128_out_reg      <= (others => '0');
			data_out_valid_reg   <= '0';        
      elsif (clk'event and clk = '1') then
         data128_out_reg      <= data128_out_mux; 
			data_out_valid_reg   <= word128_0_valid OR word128_1_valid;
 	    end if;
    end process;
    
data48_out     <= data128_out_reg;
data_out_valid <= data_out_valid_reg;


 

end arch;   



