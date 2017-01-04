-- ----------------------------------------------------------------------------	
-- FILE: 	pack_56_to_64.vhd
-- DESCRIPTION:	packs bits from 56 to 64 bits
-- DATE:	Nov 14, 2016
-- AUTHOR(s):	Lime Microsystems
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
      clk       		: in std_logic;
      reset_n   		: in std_logic;
		data_in_wrreq	: in std_logic;
		data56_in		: in std_logic_vector(55 downto 0);
		data64_out		: out std_logic_vector(63 downto 0);
		data_out_valid	: out std_logic
       
        );
end pack_56_to_64;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pack_56_to_64 is
--declare signals,  components here

signal word64_0		: std_logic_vector(63 downto 0);
signal word64_1		: std_logic_vector(63 downto 0);
signal word64_2		: std_logic_vector(63 downto 0);
signal word64_3		: std_logic_vector(63 downto 0);
signal word64_4		: std_logic_vector(63 downto 0);
signal word64_5		: std_logic_vector(63 downto 0);
signal word64_6		: std_logic_vector(63 downto 0);

signal word64_0_en, word64_0_en_reg : std_logic;
signal word64_1_en, word64_1_en_reg	: std_logic;
signal word64_2_en, word64_2_en_reg : std_logic;
signal word64_3_en, word64_3_en_reg : std_logic;
signal word64_4_en, word64_4_en_reg	: std_logic;
signal word64_5_en, word64_5_en_reg	: std_logic;
signal word64_6_en, word64_6_en_reg : std_logic;

signal wr_cnt			: unsigned(2 downto 0);

signal data_in_wr_reg		: std_logic;

signal data56_in_reg			: std_logic_vector(55 downto 0);

--output mux network
signal mux_stage0_X_0	: std_logic_vector(63 downto 0);
signal mux_stage0_2_1	: std_logic_vector(63 downto 0);
signal mux_stage0_4_3	: std_logic_vector(63 downto 0);
signal mux_stage0_6_5	: std_logic_vector(63 downto 0);

signal mux_stage0_X_0_reg	: std_logic_vector(63 downto 0);
signal mux_stage0_2_1_reg	: std_logic_vector(63 downto 0);
signal mux_stage0_4_3_reg	: std_logic_vector(63 downto 0);
signal mux_stage0_6_5_reg	: std_logic_vector(63 downto 0);

signal word64_0_en_reg_stage0 : std_logic;
signal word64_3_en_reg_stage0 : std_logic;
signal word64_4_en_reg_stage0 : std_logic;

signal mux_stage1_2_0	: std_logic_vector(63 downto 0);
signal mux_stage1_6_3	: std_logic_vector(63 downto 0);

signal mux_stage2_6_0	: std_logic_vector(63 downto 0);


 
begin

-- ----------------------------------------------------------------------------
-- Input data register
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
			data56_in_reg<=(others=>'0');
      elsif (clk'event and clk = '1') then
				data56_in_reg<=data56_in;
 	    end if;
    end process;


-- ----------------------------------------------------------------------------
-- Write counter
-- ----------------------------------------------------------------------------
process(clk, reset_n) is 
	begin 
		if reset_n='0' then 
			wr_cnt<=(others=>'0');
			data_in_wr_reg<='0';
		elsif (clk'event and clk='1') then
			data_in_wr_reg<=data_in_wrreq;
			if  data_in_wr_reg='1' then 
				if wr_cnt < 7 then 
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
-- 32b word formation
-- ----------------------------------------------------------------------------
--1 stage
word64_0_en<='1' when wr_cnt=0 and data_in_wr_reg='1' else '0';

  process(reset_n, clk)
    begin
      if reset_n='0' then
			word64_0<=(others=>'0');
      elsif (clk'event and clk = '1') then
			if word64_0_en='1' then 
				word64_0<=data56_in_reg & data56_in(55 downto 48);
			else 
				word64_0<=word64_0;
			end if;
 	    end if;
    end process;
	 
--2 stage
word64_1_en<='1' when wr_cnt=1 and data_in_wr_reg='1' else '0';

  process(reset_n, clk)
    begin
      if reset_n='0' then
			word64_1<=(others=>'0');
      elsif (clk'event and clk = '1') then
			if word64_1_en='1' then 
				word64_1<=data56_in_reg(47 downto 0) & data56_in(55 downto 40);
			else 
				word64_1<=word64_1;
			end if;
 	    end if;
    end process;

--3 stage
word64_2_en<='1' when wr_cnt=2 and data_in_wr_reg='1' else '0';

  process(reset_n, clk)
    begin
      if reset_n='0' then
			word64_2<=(others=>'0');
      elsif (clk'event and clk = '1') then
			if word64_2_en='1' then 
				word64_2<=data56_in_reg(39 downto 0) & data56_in(55 downto 32);
			else 
				word64_2<=word64_2;
			end if;
 	    end if;
    end process;
	 
--4 stage
word64_3_en<='1' when wr_cnt=3 and data_in_wr_reg='1' else '0';

  process(reset_n, clk)
    begin
      if reset_n='0' then
			word64_3<=(others=>'0');
      elsif (clk'event and clk = '1') then
			if word64_3_en='1' then 
				word64_3<=data56_in_reg(31 downto 0) & data56_in(55 downto 24);
			else 
				word64_3<=word64_3;
			end if;
 	    end if;
    end process;

--5 stage
word64_4_en<='1' when wr_cnt=4 and data_in_wr_reg='1' else '0';

  process(reset_n, clk)
    begin
      if reset_n='0' then
			word64_4<=(others=>'0');
      elsif (clk'event and clk = '1') then
			if word64_4_en='1' then 
				word64_4<=data56_in_reg(23 downto 0) & data56_in(55 downto 16);
			else 
				word64_4<=word64_4;
			end if;
 	    end if;
    end process;

--6 stage	 
word64_5_en<='1' when wr_cnt=5 and data_in_wr_reg='1' else '0';

  process(reset_n, clk)
    begin
      if reset_n='0' then
			word64_5<=(others=>'0');
      elsif (clk'event and clk = '1') then
			if word64_5_en='1' then 
				word64_5<=data56_in_reg(15 downto 0) & data56_in(55 downto 8);
			else 
				word64_5<=word64_5;
			end if;
 	    end if;
    end process;

--7 stage	 
word64_6_en<='1' when wr_cnt=6 and data_in_wr_reg='1' else '0';

  process(reset_n, clk)
    begin
      if reset_n='0' then
			word64_6<=(others=>'0');
      elsif (clk'event and clk = '1') then
			if word64_6_en='1' then 
				word64_6<=data56_in_reg(7 downto 0) & data56_in(55 downto 0);
			else 
				word64_6<=word64_6;
			end if;
 	    end if;
    end process;

-- ----------------------------------------------------------------------------
-- Registers to delay word64_en signal
-- ----------------------------------------------------------------------------	 
  process(reset_n, clk)
    begin
      if reset_n='0' then
			word64_0_en_reg<='0';
			word64_1_en_reg<='0';
			word64_2_en_reg<='0';
			word64_3_en_reg<='0';
			word64_4_en_reg<='0';
			word64_5_en_reg<='0';
			word64_6_en_reg<='0';
      elsif (clk'event and clk = '1') then
			word64_0_en_reg<=word64_0_en;
			word64_1_en_reg<=word64_1_en;
			word64_2_en_reg<=word64_2_en;
			word64_3_en_reg<=word64_3_en;
			word64_4_en_reg<=word64_4_en;
			word64_5_en_reg<=word64_5_en;
			word64_6_en_reg<=word64_6_en;
 	    end if;
    end process;
	 

-- ----------------------------------------------------------------------------
-- 32b word output
-- ----------------------------------------------------------------------------
--firts stage of mux
mux_stage0_X_0	<=word64_0 when word64_0_en_reg='1' else (others=>'0');
mux_stage0_2_1	<=word64_1 when word64_1_en_reg='1' else word64_2;
mux_stage0_4_3	<=word64_3 when word64_3_en_reg='1' else word64_4;
mux_stage0_6_5	<=word64_5 when word64_5_en_reg='1' else word64_6;
-- ----------------------------------------------------------------------------
-- Registers to delay word64_en signal
-- ----------------------------------------------------------------------------	 
  process(reset_n, clk)
    begin
      if reset_n='0' then
			mux_stage0_X_0_reg<=(others=>'0');
			mux_stage0_2_1_reg<=(others=>'0');
			mux_stage0_4_3_reg<=(others=>'0');
			mux_stage0_6_5_reg<=(others=>'0');
			word64_0_en_reg_stage0<='0';
			word64_3_en_reg_stage0<='0';
			word64_4_en_reg_stage0<='0';
      elsif (clk'event and clk = '1') then
			mux_stage0_X_0_reg<=mux_stage0_X_0;
			mux_stage0_2_1_reg<=mux_stage0_2_1;
			mux_stage0_4_3_reg<=mux_stage0_4_3;
			mux_stage0_6_5_reg<=mux_stage0_6_5;
			word64_0_en_reg_stage0<=word64_0_en_reg;
			word64_3_en_reg_stage0<=word64_3_en_reg;
			word64_4_en_reg_stage0<=word64_4_en_reg;
 	    end if;
    end process;



--second stage of mux
mux_stage1_2_0	<=mux_stage0_X_0_reg when word64_0_en_reg_stage0='1' else  mux_stage0_2_1_reg;
mux_stage1_6_3	<=mux_stage0_4_3_reg when (word64_3_en_reg_stage0='1' OR word64_4_en_reg_stage0='1') else mux_stage0_6_5_reg;
--last stage of mux
mux_stage2_6_0	<=mux_stage1_2_0 when (word64_0_en_reg='1' OR word64_1_en_reg='1' OR word64_2_en_reg='1') else mux_stage1_6_3;

data64_out		<=mux_stage2_6_0;

-- ----------------------------------------------------------------------------
-- 32b word output valid signal
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
			data_out_valid<='0';
      elsif (clk'event and clk = '1') then
			data_out_valid<=word64_0_en OR word64_1_en OR word64_2_en OR word64_3_en OR word64_4_en OR word64_5_en OR word64_6_en;
 	    end if;
    end process;

 

end arch;   



