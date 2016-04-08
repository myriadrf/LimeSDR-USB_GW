-- ----------------------------------------------------------------------------	
-- FILE: 	compress.vhd
-- DESCRIPTION:	packs data from 12 or 14 bit samples to 16 bit data
-- DATE:	Oct 16, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity comprlaration
-- ----------------------------------------------------------------------------
entity compress_v2 is

  port (
        --input ports 
        clk             : in std_logic;
        reset_n         : in std_logic;
        data_in         : in std_logic_vector(63 downto 0);
        data_in_valid   : in std_logic;
        sample_width    : in std_logic_vector(1 downto 0); --"10"-12bit, "01"-14bit, "00"-16bit;
        --output ports 
        data_out        : out std_logic_vector(63 downto 0);
        data_out_valid  : out std_logic       
        );
end compress_v2;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of compress_v2 is
--Declare signals,  components here

--data registers
signal data_in_reg  			: std_logic_vector (63 downto 0);
signal d_out, d_out_reg 	: std_logic_vector(63 downto 0);
signal smpl_cnt 				: unsigned (3 downto 0);
signal smpl_cnt_max 			: unsigned (3 downto 0);
signal compr_array  	 		: std_logic_vector(447 downto 0);
signal compr_array_reg		: std_logic_vector(447 downto 0);
signal tst_out      			: std_logic_vector(63 downto 0);
signal tst_msb      			: integer;
signal tst_lsb      			: integer;
signal  wreq_sig    			: std_logic;
signal wreq_cnt 				: unsigned (3 downto 0);
signal wreq_cnt_max 			: unsigned (3 downto 0);
signal data_in_valid_reg  	: std_logic;
  
begin

  smpl_cnt_max<="0011" when sample_width="10" else 
                "0111" when sample_width="01" else
                "0000";
--  tst_msb<=to_integer(smpl_cnt*12+11);
--  tst_lsb<=to_integer(smpl_cnt*12);
  
  
--  tst_out<= compr_array(15 downto 0) when wreq_cnt=0 else 
--   	        compr_array(31 downto 16) when wreq_cnt=1 else
--   	        compr_array(47 downto 32) when wreq_cnt=2 else
--   	        compr_array(63 downto 48) when wreq_cnt=3 else
--   	        compr_array(79 downto 64) when wreq_cnt=4 else
--   	        compr_array(95 downto 80) when wreq_cnt=5 else
--   	        compr_array(111 downto 96) when wreq_cnt=6 else
--   	        compr_array(127 downto 112);  

  tst_out<= compr_array(63 downto 0) when wreq_cnt=0 else 
   	      compr_array(127 downto 64) when wreq_cnt=1 else
   	      compr_array(191 downto 128) when wreq_cnt=2 else
				compr_array(255 downto 192) when wreq_cnt=3 else
				compr_array(319 downto 256) when wreq_cnt=4 else
				compr_array(383 downto 320) when wreq_cnt=5 else
				compr_array(447 downto 384);			
  
-- ----------------------------------------------------------------------------
-- Sample counter
-- ----------------------------------------------------------------------------
 process (clk, reset_n)
	begin
		--
		if (reset_n = '0') then
			smpl_cnt<=(others=>'0');
			data_in_valid_reg<='0';
		elsif (clk'event and clk = '1') then
		  data_in_valid_reg<=data_in_valid;
        if data_in_valid='1' then
          if smpl_cnt<smpl_cnt_max then  
            smpl_cnt<=smpl_cnt+1;
          else 
            smpl_cnt<=(others=>'0');
          end if;
        else 
          smpl_cnt<=smpl_cnt;
        end if;
		end if;
	end process;
	
	
-- ----------------------------------------------------------------------------
-- wreq counter
-- ----------------------------------------------------------------------------
 process (clk, reset_n)
	begin
		--
		if (reset_n = '0') then
			wreq_cnt<=(others=>'0');
		elsif (clk'event and clk = '1') then
        if wreq_sig='1' then
          if wreq_cnt<smpl_cnt_max-1 then  
            wreq_cnt<=wreq_cnt+1;
          else 
            wreq_cnt<=(others=>'0');
          end if;
        else 
          wreq_cnt<=wreq_cnt;
        end if;
		end if;
	end process;
	
-- ----------------------------------------------------------------------------
-- Sample counter
-- ----------------------------------------------------------------------------
 process (clk, reset_n)
	begin
		--
		if (reset_n = '0') then
			wreq_sig<='0';
		elsif (clk'event and clk = '1') then
        if data_in_valid='1' and smpl_cnt>=1 then
          wreq_sig<='1'; 
        else 
          wreq_sig<='0'; 
        end if;
		end if;
	end process;	
	
	
	
-- ----------------------------------------------------------------------------
-- shift reg
-- ----------------------------------------------------------------------------
-- process (clk, reset_n)
--	begin
--		--
--		if (reset_n = '0') then
--				compr_array_reg<=(others=>'0');
--		elsif (clk'event and clk = '1') then
--        if data_in_valid='1' and smpl_cnt>1 then
--          compr_array_reg<=std_logic_vector(unsigned(compr_array) srl 16);
--        else 
--          compr_array_reg<=compr_array;
--        end if;
--		end if;
--	end process;	
	
  
-- ----------------------------------------------------------------------------
-- Sample compression
-- ----------------------------------------------------------------------------
 process (clk, reset_n)
	begin
		--
		if (reset_n = '0') then
			compr_array<=(others=>'0');
		elsif (clk'event and clk = '1') then		  
        if data_in_valid='1' then
            if sample_width="10" then 
              --compr_array(to_integer(smpl_cnt*12+11) downto to_integer(smpl_cnt*12)) <= data_in(11 downto 0);
				  compr_array(to_integer(smpl_cnt)*48+47 downto to_integer(smpl_cnt)*48) <= data_in(47 downto 0);
            elsif sample_width="01" then
              --compr_array(to_integer(smpl_cnt*14+13) downto to_integer(smpl_cnt*13)) <= data_in(13 downto 0);
				  compr_array(to_integer(smpl_cnt)*56+55 downto to_integer(smpl_cnt)*56) <= data_in(55 downto 0);
            else
              --compr_array(15 downto 0)<= data_in;
				  compr_array(63 downto 0)<= data_in;
          end if;
        else 
          compr_array<=compr_array;
        end if;
		end if;
	end process; 

data_out_valid<=data_in_valid_reg when sample_width="00" else wreq_sig;
data_out<=tst_out;
  
end arch;   




