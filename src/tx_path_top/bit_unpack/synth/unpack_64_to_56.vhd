-- ----------------------------------------------------------------------------	
-- FILE: 	unpack_64_to_56.vhd
-- DESCRIPTION:	unpacks bits from 64b words to 14 bit samples
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
entity unpack_64_to_56 is
  port (
      --input ports 
      clk       		: in std_logic;
      reset_n   		: in std_logic;
		data_in_wrreq	: in std_logic;
		data64_in		: in std_logic_vector(63 downto 0);
		data56_out		: out std_logic_vector(127 downto 0);
		data_out_valid	: out std_logic
       
        );
end unpack_64_to_56;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of unpack_64_to_56 is
--declare signals,  components here

signal word128_0					: std_logic_vector(127 downto 0);
signal word128_1					: std_logic_vector(127 downto 0);
signal word128_2					: std_logic_vector(127 downto 0);
signal word128_3					: std_logic_vector(127 downto 0);

signal word128_0_valid 	   	: std_logic;
signal word128_1_valid	   	: std_logic;
signal word128_2_valid 	   	: std_logic;
signal word128_3_valid 	   	: std_logic;

signal wr_cnt						: unsigned(2 downto 0);


signal data64_in_reg_0		   : std_logic_vector(63 downto 0);
signal data64_in_reg_1		   : std_logic_vector(63 downto 0);

--output mux network
signal mux_stage0_1_0			: std_logic_vector(127 downto 0);
signal mux_stage0_3_2			: std_logic_vector(127 downto 0);

signal mux_stage0_1_0_reg		: std_logic_vector(127 downto 0);
signal mux_stage0_3_2_reg		: std_logic_vector(127 downto 0);

signal mux_stage1_3_0			: std_logic_vector(127 downto 0);
signal mux_stage1_3_0_reg		: std_logic_vector(127 downto 0);
signal mux_stage1_3_0_sel	   : std_logic;


signal data_out_valid_reg  	: std_logic;
signal data_out_valid_pipe 	: std_logic;


 
begin

-- ----------------------------------------------------------------------------
-- Input data register
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
         data64_in_reg_0<=(others=>'0');
      elsif (clk'event and clk = '1') then
         if data_in_wrreq = '1' then 
            data64_in_reg_0<=data64_in;
            data64_in_reg_1<=data64_in_reg_0;
         else 
            data64_in_reg_0<=data64_in_reg_0;
            data64_in_reg_1<=data64_in_reg_1;
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
				if wr_cnt < 6 then 
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
-- 64b word formation
-- ----------------------------------------------------------------------------
--1 stage

  process(reset_n, clk)
    begin
      if reset_n='0' then
			word128_0<=(others=>'0');
         word128_0_valid<='0';
      elsif (clk'event and clk = '1') then
			if wr_cnt=1 and data_in_wrreq='1' then 
            word128_0<= data64_in(47 downto 34) & "00" &
                        data64_in(33 downto 20) & "00" &
                        data64_in(19 downto 6) & "00" & 
                        data64_in(5 downto 0) & data64_in_reg_0(63 downto 56) & "00" &                        
                        data64_in_reg_0(55 downto 42) & "00" &
                        data64_in_reg_0(41 downto 28) & "00" &
                        data64_in_reg_0(27 downto 14) & "00" &
                        data64_in_reg_0(13 downto 0) & "00";
            word128_0_valid<='1';
			else 
				word128_0<=word128_0;
            word128_0_valid<='0';
			end if;
 	    end if;
    end process;
	 
--2 stage

  process(reset_n, clk)
    begin
      if reset_n='0' then
			word128_1<=(others=>'0');
         word128_1_valid<='0';
      elsif (clk'event and clk = '1') then
			if wr_cnt=3 and data_in_wrreq='1' then        
				word128_1<= data64_in(31 downto 18) & "00" &
                        data64_in(17 downto 4) & "00" &
                        data64_in(3 downto 0) & data64_in_reg_0(63 downto 54) & "00" &
                        data64_in_reg_0(53 downto 40) & "00" &
                        data64_in_reg_0(39 downto 26) & "00" &
                        data64_in_reg_0(25 downto 12) & "00" &
                        data64_in_reg_0(11 downto 0) & data64_in_reg_1(63 downto 62) & "00" &
                        data64_in_reg_1(61 downto 48) & "00";
            word128_1_valid<='1';
			else 
				word128_1<=word128_1;
            word128_1_valid<='0';
			end if;
 	    end if;
    end process;

--3 stage

  process(reset_n, clk)
    begin
      if reset_n='0' then
			word128_2<=(others=>'0');
         word128_2_valid<='0';
      elsif (clk'event and clk = '1') then
			if wr_cnt=5 and data_in_wrreq='1' then
				word128_2<= data64_in(15 downto 2) & "00" &
                        data64_in(1 downto 0) & data64_in_reg_0(63 downto 52) & "00" &
                        data64_in_reg_0(51 downto 38) & "00" &
                        data64_in_reg_0(37 downto 24) & "00" &
                        data64_in_reg_0(23 downto 10) & "00" &
                        data64_in_reg_0(9 downto 0) & data64_in_reg_1(63 downto 60) & "00" &
                        data64_in_reg_1(59 downto 46) & "00" & 
                        data64_in_reg_1(45 downto 32) & "00";
            word128_2_valid<='1';
			else 
				word128_2<=word128_2;
            word128_2_valid<='0';
			end if;
 	    end if;
    end process;
	 
--4 stage

  process(reset_n, clk)
    begin
      if reset_n='0' then
			word128_3<=(others=>'0');
         word128_3_valid<='0';
      elsif (clk'event and clk = '1') then
			if wr_cnt=6 and data_in_wrreq='1' then
				word128_3<= data64_in(63 downto 50) & "00" &
                        data64_in(49 downto 36) & "00" &
                        data64_in(35 downto 22) & "00" &
                        data64_in(21 downto 8) & "00" &
                        data64_in(7 downto 0) & data64_in_reg_0(63 downto 58) & "00" &
                        data64_in_reg_0(57 downto 44) & "00" & 
                        data64_in_reg_0(43 downto 30) & "00" & 
                        data64_in_reg_0(29 downto 16) & "00";
            word128_3_valid<='1';
			else 
				word128_3<=word128_3;
            word128_3_valid<='0';
			end if;
 	    end if;
    end process;


	 

-- ----------------------------------------------------------------------------
-- 32b word output
-- ----------------------------------------------------------------------------
--firts stage of mux
mux_stage0_1_0	<=word128_0 when word128_0_valid='1' else word128_1;
mux_stage0_3_2	<=word128_2 when word128_2_valid='1' else word128_3;

-- ----------------------------------------------------------------------------
-- Registers for MUX stage 0
-- ----------------------------------------------------------------------------	 
  process(reset_n, clk)
    begin
      if reset_n='0' then
			mux_stage0_1_0_reg<=(others=>'0');
			mux_stage0_3_2_reg<=(others=>'0');
         mux_stage1_3_0_sel<='0';
      elsif (clk'event and clk = '1') then
			mux_stage0_1_0_reg <= mux_stage0_1_0;
			mux_stage0_3_2_reg <= mux_stage0_3_2;
         mux_stage1_3_0_sel <= (word128_0_valid OR word128_1_valid);     
 	    end if;
    end process;



--second stage of mux
mux_stage1_3_0	<=mux_stage0_1_0_reg when mux_stage1_3_0_sel='1' else mux_stage0_3_2_reg;

-- ----------------------------------------------------------------------------
-- Registers for MUX stage 1
-- ----------------------------------------------------------------------------	 
  process(reset_n, clk)
    begin
      if reset_n='0' then
			mux_stage1_3_0_reg<=(others=>'0');
      elsif (clk'event and clk = '1') then
			mux_stage1_3_0_reg<=mux_stage1_3_0;
 	    end if;
    end process;


-- ----------------------------------------------------------------------------
-- 32b word output valid signal
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
			data_out_valid_reg<='0';
         data_out_valid_pipe<='0';
      elsif (clk'event and clk = '1') then
			data_out_valid_reg<=word128_0_valid OR word128_1_valid OR word128_2_valid OR word128_3_valid;
         data_out_valid_pipe<=data_out_valid_reg; 
 	    end if;
    end process;
    
    data56_out		   <= mux_stage1_3_0_reg;
    data_out_valid   <= data_out_valid_pipe;



 

end arch;   



