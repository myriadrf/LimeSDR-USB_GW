-- ----------------------------------------------------------------------------	
-- FILE: 	decompress.vhd
-- DESCRIPTION:	data decompressor
-- DATE:	Oct 13, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
LIBRARY altera_mf;
USE altera_mf.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity decompress is
  generic (
				dev_family 	: string  := "Cyclone IV E";
				data_width 	: integer := 31;
				fifo_rsize	: integer := 9;
				fifo_wsize	: integer := 10);
  port (
        --input ports 
        wclk          : in std_logic;
        rclk          : in std_logic;
        reset_n       : in std_logic;
        data_in       : in std_logic_vector(data_width-1 downto 0);
        data_in_valid : in std_logic; -- data_in leading signal which indicates valid incomong data
        sample_width  : in std_logic_vector(1 downto 0); -- "00"-16bit, "01"-14bit, "10"-12bit
        rdreq         : in std_logic;
		   --output ports  
        rdempty       : out std_logic;
        rdusedw       : out std_logic_vector(fifo_rsize-1 downto 0);
        wfull         : out std_logic;
        wusedw        : out std_logic_vector(fifo_wsize-1 downto 0);
        dataout_valid : out std_logic;
        decmpr_data   : out std_logic_vector(31 downto 0)

     
        );
end decompress;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of decompress is
--declare signals,  components here
signal data_in_reg : std_logic_vector (data_width-1 downto 0);
--signal reset : std_logic;
signal data_in_valid_reg : std_logic; 

-- States
	type cmds is (Idle, dec12_0, dec12_1, dec12_2, dec12_3, 
	               dec14_0, dec14_1, dec14_2, dec14_3, dec14_4, dec14_5, dec14_6,
	               dec16_0, dec16_1, dec16_2, dec16_3);
	signal state, next_state : cmds;
	
--fifo data
signal fifo_d0, fifo_d1, fifo_d2, fifo_d3  : std_logic_vector(15 downto 0);
signal fifo_d0_reg, fifo_d1_reg, fifo_d2_reg, fifo_d3_reg  : std_logic_vector(15 downto 0);
signal fifo_d4, fifo_d5, fifo_d6, fifo_d7  : std_logic_vector(15 downto 0);
signal fifo_d4_reg, fifo_d5_reg, fifo_d6_reg, fifo_d7_reg  : std_logic_vector(15 downto 0);
signal fifo_d : std_logic_vector(127 downto 0);
signal dec_fifo_wr  : std_logic;
signal fifo_rdreq : std_logic;
signal fifo_rdempty : std_logic;


component fifo_inst is
  generic(dev_family	     : string  := "Cyclone IV E";
          wrwidth         : integer := 24;
          wrusedw_witdth  : integer := 12; --12=2048 words 
          rdwidth         : integer := 48;
          rdusedw_width   : integer := 11;
          show_ahead      : string  := "ON"
  );  

  port (
      --input ports 
      reset_n       : in std_logic;
      wrclk         : in std_logic;
      wrreq         : in std_logic;
      data          : in std_logic_vector(wrwidth-1 downto 0);
      wrfull        : out std_logic;
		wrempty		  : out std_logic;
      wrusedw       : out std_logic_vector(wrusedw_witdth-1 downto 0);
      rdclk 	     : in std_logic;
      rdreq         : in std_logic;
      q             : out std_logic_vector(rdwidth-1 downto 0);
      rdempty       : out std_logic;
      rdusedw       : out std_logic_vector(rdusedw_width-1 downto 0)     



      --output ports 
        
        );
end component;
  
begin
  
dataout_valid<=dec_fifo_wr;


fifo_d<=fifo_d7 & fifo_d6 & fifo_d5 & fifo_d4 & fifo_d3 & fifo_d2 & fifo_d1 & fifo_d0; 
--reset<=not reset_n;
  
  
 process(state, data_in_valid) begin
	if ((state = dec12_2 or state = dec14_3 or state = dec14_6 or state = dec16_3) and data_in_valid='1') then
			dec_fifo_wr <= '1'; 
	else
		  dec_fifo_wr <= '0';
	end if;	
end process;

 
-- ----------------------------------------------------------------------------
-- Next state 00
-- ----------------------------------------------------------------------------
	NextStateReg00: process (wclk, reset_n)
	begin
		--
		if (reset_n = '0') then
			state <= idle;
			data_in_reg<=(others=>'0'); 
		elsif (wclk'event and wclk = '1') then
       state <= next_state;
       data_in_reg<=data_in;
		end if;
	end process NextStateReg00;
	
-- ----------------------------------------------------------------------------
-- Next state logic 00
-- ----------------------------------------------------------------------------
	nxt_state_decoder00 : process (state, sample_width, data_in_valid, data_in, data_in_reg, 
											fifo_d0_reg, fifo_d1_reg, fifo_d2_reg, fifo_d3_reg, 
											fifo_d4_reg, fifo_d5_reg, fifo_d6_reg, fifo_d7_reg)
	begin
	  next_state<=state;
	  fifo_d0<=fifo_d0_reg;
		fifo_d1<=fifo_d1_reg;
		fifo_d2<=fifo_d2_reg;
		fifo_d3<=fifo_d3_reg;
		fifo_d4<=fifo_d4_reg;
		fifo_d5<=fifo_d5_reg;
		fifo_d6<=fifo_d6_reg;
		fifo_d7<=fifo_d7_reg;  
			case (state) is
			 when Idle =>
			   if sample_width="10" then 			     
			       next_state<=dec12_0;
			   elsif sample_width="01" then
			     		next_state<=dec14_0;
			   else 
			       next_state<=dec16_0;
			   end if;
--for 12 bit data samples decoding
			 when dec12_0 =>
			   if data_in_valid='1' then 
			     next_state<=dec12_1;
			     fifo_d0<="0000" & data_in(11 downto 0);
			     fifo_d1<="0000" & data_in(23 downto 12);	   
			   else 
			     next_state<=dec12_0;
			     fifo_d0<=(others=>'0');
			   end if;
			 when dec12_1 =>
			   if data_in_valid='1' then
			     next_state<=dec12_2;

			   else 
			     next_state<=dec12_1;
			   end if;
			   		fifo_d2<="0000" & data_in(3 downto 0) & data_in_reg(31 downto 24);
			     fifo_d3<="0000" & data_in(15 downto 4);
			     fifo_d4<="0000" & data_in(27 downto 16); 
			   
			 when dec12_2 =>
			   if data_in_valid='1' then
			     next_state<=dec12_0;
			   else 
			     next_state<=dec12_2;
			   end if; 
			   fifo_d5<="0000" & data_in(7 downto 0) & data_in_reg(31 downto 28);
			   fifo_d6<="0000" & data_in(19 downto 8);
			   fifo_d7<="0000" & data_in(31 downto 20);
			   
--for 14 bit data samples decoding	
       when dec14_0 => --1
  			   if data_in_valid='1' then 
			     next_state<=dec14_1;
			     fifo_d0<="00" & data_in(13 downto 0);		   
			  	else  
			  	  next_state<=dec14_0;
			  	  fifo_d0<=(others=>'0');
			  	end if;
			 when dec14_1 => --2 ---not works
			   if data_in_valid='1' then
			     next_state<=dec14_2;
			   else
			     next_state<=dec14_1;
			   end if;  
			   fifo_d1<="00" &  data_in(11 downto 0) & data_in_reg(15 downto 14);
			 when dec14_2 => --3
			   if data_in_valid='1' then
			     next_state<=dec14_3;
			   else
			     next_state<=dec14_2;
			   end if;   
			   fifo_d2<="00" &  data_in(9 downto 0) & data_in_reg(15 downto 12);
			 when dec14_3 => --4
			   if data_in_valid='1' then
			     next_state<=dec14_4;
			   else
			     next_state<=dec14_3;
			   end if; 			     
			   fifo_d3<="00" &  data_in(7 downto 0) & data_in_reg(15 downto 10);
			 when dec14_4 => --5
			   if data_in_valid='1' then
			     next_state<=dec14_5;
			   else
			     next_state<=dec14_4;
			   end if; 			     
			   fifo_d0<="00" &  data_in(5 downto 0) & data_in_reg(15 downto 8);
			 when dec14_5 => --6
			   if data_in_valid='1' then
			     next_state<=dec14_6;
			   else
			     next_state<=dec14_5;
			   end if; 			     
			   fifo_d1<="00" &  data_in(3 downto 0) & data_in_reg(15 downto 6);
			 when dec14_6 => --7
			   next_state<=dec14_0;
			   fifo_d2<="00" &  data_in(1 downto 0) & data_in_reg(15 downto 4);
			   fifo_d3<="00" &  data_in(15 downto 2);
			   
	--for 16 bit data samples decoding
       when dec16_0 => --1
  			   if data_in_valid='1' then 
			     next_state<=dec16_1;
			     fifo_d0<=data_in(15 downto 0);
			     fifo_d1<=data_in(31 downto 16);		   
			  	else  
			  	  next_state<=dec16_0;
			  	  fifo_d0<=(others=>'0');
			  	  fifo_d1<=(others=>'0');
			  	end if;	     			   
			 when dec16_1 => --2
			   if data_in_valid='1' then
			     next_state<=dec16_2;
			   else 
			     next_state<=dec16_1;
			   end if;
			   	fifo_d2<=data_in(15 downto 0);
			    fifo_d3<=data_in(31 downto 16);		 
			 when dec16_2 => --2
			   if data_in_valid='1' then
			     next_state<=dec16_3;
			   else 
			     next_state<=dec16_2;
			   end if;
			   	fifo_d4<=data_in(15 downto 0);
			    fifo_d5<=data_in(31 downto 16);			      
			 when dec16_3 => --2
			   next_state<=dec16_0;
			   	fifo_d6<=data_in(15 downto 0);
			    fifo_d7<=data_in(31 downto 16);			 		 
			   	  
			 when others =>
				 next_state <= idle;

		end case;
		
	end process nxt_state_decoder00;

	
	
	
	    fifo :  fifo_inst 
  generic map (
			dev_family	    => dev_family, 
			wrwidth         => 128, 
			wrusedw_witdth  => fifo_wsize, 
			rdwidth         => 32, 
			rdusedw_width   => fifo_rsize,
			show_ahead      => "ON"
  )  
  port map (
      --input ports 
      reset_n       => reset_n, 
      wrclk         => wclk,
      wrreq         => dec_fifo_wr,
      data          => fifo_d, 
      wrfull        => open,
		wrempty		  => open, 
      wrusedw       => wusedw,
      rdclk 	     => rclk,
      rdreq         => rdreq,
      q             => decmpr_data,
      rdempty       => rdempty,
      rdusedw       => open    		
        );
	

--data registers
  process(reset_n, wclk)
    begin
      if reset_n='0' then
        --data_in_valid_reg<='0';
		  fifo_d0_reg<=(others=>'0');
		  fifo_d1_reg<=(others=>'0');
		  fifo_d2_reg<=(others=>'0');
		  fifo_d3_reg<=(others=>'0');
		  fifo_d4_reg<=(others=>'0');
		  fifo_d5_reg<=(others=>'0');
		  fifo_d6_reg<=(others=>'0');
		  fifo_d7_reg<=(others=>'0');
 	    elsif (wclk'event and wclk = '1') then
 	     --data_in_valid_reg<=data_in_valid;
		  fifo_d0_reg<=fifo_d0;
		  fifo_d1_reg<=fifo_d1;
		  fifo_d2_reg<=fifo_d2;
		  fifo_d3_reg<=fifo_d3;
		  fifo_d4_reg<=fifo_d4;
		  fifo_d5_reg<=fifo_d5;
		  fifo_d6_reg<=fifo_d6;
		  fifo_d7_reg<=fifo_d7;
 	    end if;
    end process;
	 
	 rdusedw<=(others=>'0');
	 wfull<='0';
  
end arch;   




