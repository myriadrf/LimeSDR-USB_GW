-- ----------------------------------------------------------------------------	
-- FILE: 	p2d_clr_fsm.vhd
-- DESCRIPTION:	FSm for data reading from packets.
-- DATE:	April 6, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	

-- ----------------------------------------------------------------------------
-- Notes:
-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY lpm;
USE lpm.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity p2d_clr_fsm is
   generic (
      pct_size_w           : integer := 16;
      n_buff               : integer := 2 -- 2,4 valid values
   );
   port (
      clk                  : in std_logic;
      reset_n              : in std_logic;
      pct_size             : in std_logic_vector(pct_size_w-1 downto 0);   --Whole packet size in 
                                                                           --in_pct_data_w words
                                                                           
      smpl_nr              : in std_logic_vector(63 downto 0);
                                                                           
      pct_hdr_0            : in std_logic_vector(63 downto 0);
      pct_hdr_0_valid      : in std_logic_vector(n_buff-1 downto 0);
      
      pct_hdr_1            : in std_logic_vector(63 downto 0);
      pct_hdr_1_valid      : in std_logic_vector(n_buff-1 downto 0);
     
      pct_data_clr_n       : out std_logic_vector(n_buff-1 downto 0);
      pct_data_clr_dis     : in std_logic_vector(n_buff-1 downto 0);

      pct_buff_rdy         : in std_logic_vector(n_buff-1 downto 0)   
      
        );
end p2d_clr_fsm;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of p2d_clr_fsm is
--declare signals,  components here

type state_type is (idle, sel_buff, rd_buff);
signal current_state, next_state : state_type; 

type smpl_nr_array_type  is array (0 to n_buff-1) of std_logic_vector(63 downto 0);  
signal smpl_nr_array       : smpl_nr_array_type;

signal pct_smpl_nr_less       : std_logic_vector(n_buff-1 downto 0);
signal pct_smpl_nr_sync_dis   : std_logic_vector(n_buff-1 downto 0);
signal pct_buff_rdy_reg0      : std_logic_vector(n_buff-1 downto 0);
signal pct_buff_rdy_reg1      : std_logic_vector(n_buff-1 downto 0);
signal pct_buff_rdy_reg2      : std_logic_vector(n_buff-1 downto 0);
signal pct_buff_rdy_reg3      : std_logic_vector(n_buff-1 downto 0);


COMPONENT lpm_compare
	GENERIC (
		lpm_pipeline		: NATURAL;
		lpm_representation		: STRING;
		lpm_type		: STRING;
		lpm_width		: NATURAL
	);
	PORT (
			clock	: IN STD_LOGIC ;
			dataa	: IN STD_LOGIC_VECTOR (63 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (63 DOWNTO 0);
			aeb	: OUT STD_LOGIC ;
			alb	: OUT STD_LOGIC 
	);
	END COMPONENT;



begin


-- ----------------------------------------------------------------------------
-- Capture sample numbers from packets to reg array
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      smpl_nr_array <= (others=>(others=>'0'));
   elsif (clk'event AND clk='1') then 
      for i in 0 to n_buff-1 loop
         if pct_hdr_1_valid(i) = '1' then 
            smpl_nr_array(i)<= pct_hdr_1;
         else 
            smpl_nr_array(i)<=smpl_nr_array(i);
         end if;
      end loop;
   end if;
end process;




-- ----------------------------------------------------------------------------
-- Pipelined comparators
-- ----------------------------------------------------------------------------
gen_lpm_compare : 
for i in 0 to n_buff-1 generate
LPM_COMPARE_component : LPM_COMPARE
	GENERIC MAP (
		lpm_pipeline         => 3,
		lpm_representation   => "UNSIGNED",
		lpm_type             => "LPM_COMPARE",
		lpm_width            => 64
	)
	PORT MAP (
		clock                => clk,
		dataa                => smpl_nr_array(i),
		datab                => smpl_nr,
		aeb                  => open,
		alb                  => pct_smpl_nr_less(i)
	);
   
end generate gen_lpm_compare;


-- ----------------------------------------------------------------------------
-- Capture pct synch disable bit
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      pct_smpl_nr_sync_dis <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      for i in 0 to n_buff-1 loop
         if pct_hdr_0_valid(i) = '1' then 
            pct_smpl_nr_sync_dis(i)<= pct_hdr_0(4);
         else 
            pct_smpl_nr_sync_dis(i)<=pct_smpl_nr_sync_dis(i);
         end if;
      end loop;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- Clear packet buffer when received sample number is to old
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      pct_data_clr_n <= (others=>'0');
      pct_buff_rdy_reg0 <=(others=>'0');
      pct_buff_rdy_reg1 <=(others=>'0');
      pct_buff_rdy_reg2 <=(others=>'0');
      pct_buff_rdy_reg3 <=(others=>'0');
   elsif (clk'event AND clk='1') then
      pct_buff_rdy_reg0 <= pct_buff_rdy;
      pct_buff_rdy_reg1 <= pct_buff_rdy_reg0;
      pct_buff_rdy_reg2 <= pct_buff_rdy_reg1;
      pct_buff_rdy_reg3 <= pct_buff_rdy_reg2;
      for i in 0 to n_buff-1 loop
         if pct_data_clr_dis(i) = '0' AND pct_smpl_nr_sync_dis(i) = '0' AND 
            pct_smpl_nr_less(i) = '1' AND pct_buff_rdy_reg3(i) = '1' then 
            pct_data_clr_n(i)<= '0';
         else 
            pct_data_clr_n(i)<= '1';
         end if;
      end loop;
   end if;
end process;



end arch;   





