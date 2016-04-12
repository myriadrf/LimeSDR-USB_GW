-- ----------------------------------------------------------------------------	
-- FILE: 	rd_tx_fifo.vhd
-- DESCRIPTION:	reads data from fifo and forms IQ samples
-- DATE:	Apr 11, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity rd_tx_fifo is
  generic(sampl_width : integer:=12);
  port (
        --input ports 
      clk			: in std_logic;
      reset_n		: in std_logic;
      fr_start  : in std_logic;
      ch_en			: in std_logic_vector(1 downto 0);
      mimo_en		: in std_logic;
      fifo_empty	: in std_logic;
      fifo_data	: in std_logic_vector(31 downto 0);
		--output ports 
      fifo_read	: out std_logic;
      diq_h			: out std_logic_vector(15 downto 0);
      diq_l			: out std_logic_vector(15 downto 0)
        );
end rd_tx_fifo;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of rd_tx_fifo is
--declare signals,  components here

  type smpl_state is (idle, tx_A, tx_B);
  signal current_smpl_state, next_smpl_state :  smpl_state; 
  
  signal read_sig   : std_logic;
  signal iq_sel_sig : std_logic;
  signal iq_sel     : std_logic;
  signal fifo_data_reg  : std_logic_vector(31 downto 0);

  
begin
  
------------------------------------------------------------------------------
--iq sel formation
------------------------------------------------------------------------------        
process(current_smpl_state, fifo_empty)begin
	if (current_smpl_state=tx_A and fifo_empty='0') then
			iq_sel_sig<='1'; 
	else
		  iq_sel_sig<='0';
	end if;	
end process;


iq_sel<=iq_sel_sig when fr_start='1' else 
        not iq_sel_sig; 
  
------------------------------------------------------------------------------
--sample formatyion
------------------------------------------------------------------------------   
 process(current_smpl_state, ch_en, iq_sel, fifo_data, mimo_en, fifo_data_reg) begin 
    if (current_smpl_state=tx_A) then
      if ( ch_en(0)='1' and mimo_en='1') then 
        diq_l(15 downto sampl_width+1)<=(others=>'0');
        diq_l(sampl_width)<=iq_sel;
        diq_l(sampl_width-1 downto 0)<=fifo_data(sampl_width-1 downto 0);
      
        diq_h(15 downto sampl_width+1)<=(others=>'0');
        diq_h(sampl_width)<=iq_sel;
        diq_h(sampl_width-1 downto 0)<=fifo_data(sampl_width+16-1 downto 16);
      elsif (ch_en(0)='0' and mimo_en='1') then  
        diq_l(15 downto sampl_width+1)<=(others=>'0');
        diq_l(sampl_width)<=iq_sel;
        diq_l(sampl_width-1 downto 0)<=(others=>'0');
      
        diq_h(15 downto sampl_width+1)<=(others=>'0');
        diq_h(sampl_width)<=iq_sel;
        diq_h(sampl_width-1 downto 0)<=(others=>'0');
      else
        diq_l(15 downto sampl_width+1)<=(others=>'0');
        diq_l(sampl_width)<=iq_sel;
        diq_l(sampl_width-1 downto 0)<=fifo_data(sampl_width-1 downto 0);
        diq_h(15 downto sampl_width+1)<=(others=>'0');
        diq_h(sampl_width)<=iq_sel;
        diq_h(sampl_width-1 downto 0)<=fifo_data(sampl_width-1 downto 0);
      end if;
      
    elsif (current_smpl_state=tx_b) then 
        if  (ch_en(1)='1' and mimo_en='1') then 
          diq_l(15 downto sampl_width+1)<=(others=>'0');
          diq_l(sampl_width)<=iq_sel;
          diq_l(sampl_width-1 downto 0)<=fifo_data(sampl_width-1 downto 0);
      
          diq_h(15 downto sampl_width+1)<=(others=>'0');
          diq_h(sampl_width)<=iq_sel;
          diq_h(sampl_width-1 downto 0)<=fifo_data(sampl_width+16-1 downto 16);
        elsif (ch_en(1)='0' and mimo_en='1') then 
          diq_l(15 downto sampl_width+1)<=(others=>'0');
          diq_l(sampl_width)<=iq_sel;
          diq_l(sampl_width-1 downto 0)<=(others=>'0');
      
          diq_h(15 downto sampl_width+1)<=(others=>'0');
          diq_h(sampl_width)<=iq_sel;
          diq_h(sampl_width-1 downto 0)<=(others=>'0');
        else
          diq_l(15 downto sampl_width+1)<=(others=>'0');
          diq_l(sampl_width)<=iq_sel;
          diq_l(sampl_width-1 downto 0)<=fifo_data_reg(sampl_width+16-1 downto 16);
          diq_h(15 downto sampl_width+1)<=(others=>'0');
          diq_h(sampl_width)<=iq_sel;
          diq_h(sampl_width-1 downto 0)<=fifo_data_reg(sampl_width+16-1 downto 16);
        end if;
		else 
			diq_h<=(others=>'0');
			diq_l<=(others=>'0');
     end if;
   
 end process;
  

-------------------------------------------------------------------------------
--fifo read signal
-------------------------------------------------------------------------------  
process(current_smpl_state, fifo_empty, ch_en, mimo_en) begin
	if(current_smpl_state = tx_A and fifo_empty='0') then
	   if ch_en(0)='1' or mimo_en='0' then 
		    read_sig<='1';
	   else
		    read_sig<='0';
		 end if;
	elsif(current_smpl_state = tx_B and fifo_empty='0' ) then
	   if ch_en(1)='1' and mimo_en='1' then 
		    read_sig<='1';
	   else
		    read_sig<='0';
		 end if;
	else 
	  	read_sig<='0';
	end if;
end process;

fifo_read<=read_sig;

-------------------------------------------------------------------------------
--sample formation state machine
-------------------------------------------------------------------------------
smpl_fsm_f : process(clk, reset_n) begin
	if(reset_n = '0')then
		current_smpl_state <= idle;
		fifo_data_reg<=(others=>'0');
	elsif(clk'event and clk = '1')then
		current_smpl_state <= next_smpl_state;
		fifo_data_reg<=fifo_data;
	end if;	
end process;

smpl_fsm : process(current_smpl_state, fifo_empty)
begin
  
    next_smpl_state <= current_smpl_state;
    
    case current_smpl_state is

      when idle=>
       if fifo_empty='0' then
          next_smpl_state<=tx_A;
      else
          next_smpl_state<=idle;
      end if; 
   
      when tx_A=> 
          if fifo_empty='1' then
              next_smpl_state<=tx_A;           
          else
              next_smpl_state<=tx_B;
          end if;
          
      when tx_B=> 
          if fifo_empty='1' then
              next_smpl_state<=tx_B;
          else
              next_smpl_state<=tx_A;
          end if;  
      when others => 
        
      end case;
end process; 
  
end arch;




