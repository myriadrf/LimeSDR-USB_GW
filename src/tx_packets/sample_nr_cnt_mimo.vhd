-- ----------------------------------------------------------------------------	
-- FILE: 	sample_nr_cnt_mimo.vhd
-- DESCRIPTION:	counter for pct sample nr
-- DATE:	June 25, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY lpm;
USE lpm.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity sample_nr_cnt_mimo is
  generic(
          ch_num         : integer :=16
  );
  port (
        --input ports 
        clk       : in std_logic;
        reset_n   : in std_logic;
        en        : in std_logic;
        fifo_wr   : in std_logic;
        mimo_en   : in std_logic;
        ch_en     : in std_logic_vector(ch_num-1 downto 0);
		          --output ports 
        sample_nr : out std_logic_vector(63 downto 0);
		  clr_smpl_nr	: in std_logic

        );
end sample_nr_cnt_mimo;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of sample_nr_cnt_mimo is
--declare signals,  components here
--signal lpm_cnt_aclr 		: std_logic;
signal lpm_cnt_cnten 	: std_logic;
signal en_reg0, en_reg1 : std_logic;
signal sample_nrcnt     : unsigned(7 downto 0);
signal fifo_wr_reg      : std_logic;
signal active_ch_cnt    : unsigned(4 downto 0);
 

	COMPONENT lpm_counter
	GENERIC (
		lpm_direction			: STRING;
		lpm_port_updown		: STRING;
		lpm_type					: STRING;
		lpm_width				: NATURAL
	);
	PORT (
			aclr		: IN STD_LOGIC ;
			clock		: IN STD_LOGIC ;
			cnt_en	: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
	);
	END COMPONENT;

begin
	
	
			lpm_cnt_inst : LPM_COUNTER
	GENERIC MAP (
		lpm_direction 		=> "UP",
		lpm_port_updown 	=> "PORT_UNUSED",
		lpm_type 			=> "LPM_COUNTER",
		lpm_width 			=> 64
	)
	PORT MAP (
		aclr 		=> clr_smpl_nr,
		clock 	=> clk,
		cnt_en 	=> lpm_cnt_cnten,
		q 			=> sample_nr
	);

-------------------------------------------------------------------------------
-- signal registers
------------------------------------------------------------------------------- 	
  process(reset_n, clk)
    begin
      if reset_n='0' then 
       en_reg0<='0';
       en_reg1<='0';
       --fifo_wr_reg<='0';
 	    elsif (clk'event and clk = '1') then
 	      --fifo_wr_reg<=fifo_wr;
 	      en_reg0<=en;
 	      en_reg1<=en_reg0;
 	    end if;
    end process;
    
-------------------------------------------------------------------------------
-- to count active channels
-------------------------------------------------------------------------------    
      process (reset_n, clk) 
        variable sum : integer := 0; 
    begin 
      if (reset_n = '0') then 
        active_ch_cnt <= (others=>'0'); 
      elsif (clk'event and clk='1') then
        sum:=0;
        for k in 0 to ch_num - 1 loop
           if  ch_en(k)='1' then              
        	     sum := sum + 1;
  	       else 
  	           sum := sum;
	         end if;
        end loop; 
        active_ch_cnt <= to_unsigned(sum, active_ch_cnt'length); 
      end if; 
    end process;
    
-------------------------------------------------------------------------------
-- counter 
-------------------------------------------------------------------------------   
      process(reset_n, clk)
    begin
      if reset_n='0' then
          sample_nrcnt<=(others=>'0');
 	    elsif (clk'event and clk = '1') then
 	      if en_reg1='1' then
 	        if fifo_wr='1' then 
 	            if sample_nrcnt<active_ch_cnt-1 then   
 	                sample_nrcnt<=sample_nrcnt+1;
 	            else 
 	              sample_nrcnt<=(others=>'0');
 	            end if;
 	        end if;
 	      else
 	        sample_nrcnt<=(others=>'0');
 	      end if;
 	    end if;
    end process; 
    
 	--lpm_cnt_aclr<= not en_reg1;
	lpm_cnt_cnten<='1' when sample_nrcnt=active_ch_cnt-1 and fifo_wr='1' else 
	               '0';     
  
end arch;   




