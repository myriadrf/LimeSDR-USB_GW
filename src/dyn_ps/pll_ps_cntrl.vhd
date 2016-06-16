-- ----------------------------------------------------------------------------	
-- FILE: 	pll_ps_cntrl.vhd
-- DESCRIPTION:	controls phase shift enable signal
-- DATE:	April 6, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pll_ps_cntrl is
  port (
        --input ports 
        clk             : in std_logic;
        reset_n         : in std_logic;
        phase           : in std_logic_vector(9 downto 0);
        ps_en           : in std_logic; 
        ph_done         : in std_logic;
        pll_locked      : in std_logic;
		  pll_reconfig		: in std_logic;	
        
         --output ports 
        ph_step         : out std_logic;
		  ps_status		 	: out std_logic;
		  psen_cnt_out		: out std_logic_vector(7 downto 0)
        );
end pll_ps_cntrl;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pll_ps_cntrl is
--declare signals,  components here
type state_type is (s0, s1, s2, s3, s4, s5);
signal phase_inc : unsigned (9 downto 0); 
signal state, next_state : state_type;
signal ps_en_r    : std_logic;
signal begin_ps   : std_logic;
signal psen_cnt	: unsigned(7 downto 0);
signal reset_n_const	: std_logic;

  
begin

reset_n_const<='1';
  
  process(reset_n, clk)
    begin
      if reset_n='0' then
        state<=s1;
        ph_step<='0';
        phase_inc<=(others=>'0');
        ps_en_r<='0';
 	    elsif (clk'event and clk = '1') then
 	      ps_en_r<=ps_en;
 	      case (state) is 
 	        when s0 =>
						ph_step<='0';
						phase_inc<=(others=>'0'); 
 	          if begin_ps='1' and unsigned(phase)> 0 then  
						state<=s1;
 	          else
						state<=s0;
 	          end if;
 	        when s1 =>
 	             if pll_locked='1' and pll_reconfig='0' then 
							phase_inc<=phase_inc+1;
 	            	   ph_step<='1'; 
							state<=s2;
					 elsif pll_reconfig='1' then 
							phase_inc<=phase_inc;
 	            	   ph_step<='0'; 
							state<=s0;
 	             else
							phase_inc<=phase_inc;
 	            	   ph_step<='0'; 
							state<=s1;
 	             end if; 
 	        when s2 =>
 	            	ph_step<='1'; 
						state<=s3;
 	        when s3 =>
							ph_step<='0';
 	            	if phase_inc=unsigned(phase) then 
							state<=s0;
						else 
							state<=s1;
						end if;    
        when others =>
              ph_step<='0';
              phase_inc<=(others=>'0');
              state<=s0;
        end case;
 	    end if;
    end process;
    
    
--begin phase shift pulse    
     process(reset_n, clk) 
    begin
      if reset_n='0' then 
        begin_ps<='0';
 	    elsif (clk'event and clk = '1') then
 	      if ps_en_r='0' and ps_en='1' then 
 	         begin_ps<='1';
 	      else 
 	         begin_ps<='0';
 	      end if;
 	     end if;
 	   end process;
		
		
process(state) begin
	if(state = s0 ) then
		ps_status<='0';
	else
		ps_status<='1';
	end if;
end process;

process(reset_n_const, clk)
	begin
		if reset_n_const='0' then 
			psen_cnt<=(others=>'0');
		elsif (clk'event and clk ='1' ) then 
			if begin_ps='1' then 
				psen_cnt<=psen_cnt+1;
			else 
				psen_cnt<=psen_cnt;
			end if;
		end if;
	end process;
	
	psen_cnt_out<=std_logic_vector(psen_cnt);
		

--ph_countersel<="011";
--ph_updn<='0';
--ps_done<='0';

end arch; 