-- ----------------------------------------------------------------------------	
-- FILE: 	rx_pct_data.vhd
-- DESCRIPTION:	Forms LTE pacets, with compressed samples
-- DATE:	Oct 20, 2015
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
entity rx_pct_data_v2 is
  generic (infifo_rdsize  : integer :=7;
           outfifo_wrsize : integer :=7;
           ch_num         : integer :=16;
           pct_size       : integer :=4096 --in bytes
            );
  port (
        --input ports 
        clk             : in std_logic;
        reset_n         : in std_logic;
        diq0            : in std_logic_vector(63 downto 0);
        --infifo
        infifo_empty    : in std_logic; 
        infifo_rdusedw  : in std_logic_vector(infifo_rdsize-1 downto 0);
        infifo_rd       : out std_logic;
        --outfifo
        outfifo_full    : in std_logic; 
        outfifo_wrusedw : in std_logic_vector(outfifo_wrsize-1 downto 0);
        outfifo_wr      : out std_logic;
        outfifo_data    : out std_logic_vector(63 downto 0);
        --general
        en              : in std_logic;
        ch_en           : in std_logic_vector(ch_num-1 downto 0);
        mimo_en         : in std_logic;
        sample_width    : in std_logic_vector(1 downto 0); --"00"-16bit, "01"-14bit, "10"-14bit;
        tx_pct_loss     : in std_logic; -- clock domain of this signal has to be more than 2x slover, othervise 
                                       --implement synchronizer with handshaking
        tx_pct_loss_clr : in std_logic;
		  pct_wr_end		: out std_logic;
		  clr_smpl_nr		: in std_logic
        
        
        );
end rx_pct_data_v2;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of rx_pct_data_v2 is
--sync registers
signal en_reg0, en_reg1 : std_logic;
signal tx_pct_loss_reg0, tx_pct_loss_reg1 : std_logic;
signal tx_pct_loss_clr_reg0, tx_pct_loss_clr_reg1 : std_logic;
--counters
signal head_cnt         : unsigned(1 downto 0);
signal compr_size       : unsigned(3 downto 0);
signal pct_wr_cnt       : unsigned(3 downto 0);
signal allpct_wr_cnt    : unsigned(11 downto 0);
signal compr_cnt        : unsigned(2 downto 0);
signal check_cnt        : unsigned (15 downto 0); -- can be removed, used for debuging
--packet signals and registers
signal pct_header       : std_logic_vector(15 downto 0);
signal pct_smplnr       : std_logic_vector(15 downto 0);
signal pct_rsrvd0, pct_rsrvd1, pct_rsrvd2, pct_rsrvd3   : std_logic_vector(15 downto 0);
signal pct_rsrvd			: std_logic_vector(63 downto 0); 
signal sample_nrcnt     : unsigned(7 downto 0);
--lpm counter 
--signal lpmcnt_aclr      : std_logic;
signal lpmcnt_q         : std_logic_vector(63 downto 0);
signal lpmcnt_cnten     : std_logic;

signal head_wr_sig      : std_logic;

signal infifo_rd_sig    : std_logic;
signal outfifo_wr_sig   : std_logic;
signal outfifo_reserve  : unsigned(outfifo_wrsize-2 downto 0);
--signal outfifo_reserve  : unsigned(outfifo_wrsize-5 downto 0); --(use when testing loopback in FPGA)
--and this also if unsigned(outfifo_wrusedw)<outfifo_reserve-pct_size/8 or skip_packets_sig='1' then
signal outfifo_limit    : unsigned(outfifo_wrsize-1 downto 0);
signal compr_reserve  	: integer;


signal active_ch_cnt       : unsigned(4 downto 0);
signal active_ch_cnt_reg0, active_ch_cnt_reg1 : unsigned(4 downto 0);
signal tx_pct_loss_detect  : std_logic;


signal cmprsd_data       : std_logic_vector(63 downto 0);
signal cmprsd_data_valid : std_logic;
signal cmpr_dain         : std_logic_vector(63 downto 0); 
signal sample_width_reg0, sample_width_reg1 : std_logic_vector(1 downto 0); 
signal skip_packets_sig	 : std_logic; 

--state machine signals
type main_states   is (idle, check_infifo, check_outfifo, wr_head, wr_cnt, check_fifo,  
                       wr_samples);
signal current_main_state, next_main_state :   main_states;

--state machine signals
type states   is (idle, wait_pct_end, skip_packets);
signal current_state, next_state :   states;



component compress_v2 is
  port (
        --input ports 
        clk             : in std_logic;
        reset_n         : in std_logic;
        data_in         : in std_logic_vector(63 downto 0);
        data_in_valid   : in std_logic;
        sample_width    : in std_logic_vector(1 downto 0);
        --output ports 
        data_out        : out std_logic_vector(63 downto 0);
        data_out_valid  : out std_logic       
        );
end component;

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

--
--	pct_wr_end<='1' when allpct_wr_cnt=pct_size/2-1 else 
--	            '0';


	pct_wr_end<='1' when allpct_wr_cnt=pct_size/8-1 else 
	            '0';
  
  
--  cmpr_dain<="0000"  & diq0(11 downto 0) when sample_width_reg1="10" else 
--             "00" 	& diq0(13 downto 0) when sample_width_reg1="01" else
--              diq0;

  cmpr_dain<="0000000000000000"  & diq0(47 downto 0) when sample_width_reg1="10" else 
             "00000000" 	& diq0(55 downto 0) when sample_width_reg1="01" else
              diq0;
  
--packet reserved bits  
  pct_rsrvd0<="000000000000" & tx_pct_loss_detect & infifo_rdusedw(infifo_rdsize-1 downto infifo_rdsize-3);

  --pct_rsrvd0<="0000000" & infifo_rdusedw;
  pct_rsrvd1<=x"0201";
  pct_rsrvd2<=x"0403";
  pct_rsrvd3<=x"0605";
  
  pct_rsrvd<=pct_rsrvd3 & pct_rsrvd2 & pct_rsrvd1 & pct_rsrvd0;
  


--for calculating out fifo limit  
  compr_size<="0001" when sample_width_reg1="00" else 
              "1000" when sample_width_reg1="01" else
              "0100";
  outfifo_reserve<=(others=>'1'); 
--  compr_reserve<= 0 when sample_width_reg1="00" else 
--                  6 when sample_width_reg1="01" else
--                  2;  
  
-------------------------------------------------------------------------------
-- out fifo wr signal when writing header
-------------------------------------------------------------------------------  
 process(current_main_state)begin
	if(current_main_state = wr_head or current_main_state = wr_cnt) then
		head_wr_sig<='1';
	else
		head_wr_sig<='0';
	end if;
end process; 

-------------------------------------------------------------------------------
-- infifo rd  signal
-------------------------------------------------------------------------------  
 process(current_main_state, infifo_empty) begin
	if(current_main_state = wr_samples and infifo_empty='0') then
		infifo_rd_sig<='1';
	else
		infifo_rd_sig<='0';
	end if;
end process; 

infifo_rd<=infifo_rd_sig;
-------------------------------------------------------------------------------
-- out fifo wr signal
-------------------------------------------------------------------------------  
 process(current_main_state, head_wr_sig, cmprsd_data_valid)begin
	if(current_main_state = wr_head or current_main_state = wr_cnt) then
		outfifo_wr_sig<=head_wr_sig;
	else
		outfifo_wr_sig<=cmprsd_data_valid;
	end if;
end process; 


outfifo_wr<=outfifo_wr_sig when skip_packets_sig='0' else '0';
  
-------------------------------------------------------------------------------
--main packet formation state machine
-------------------------------------------------------------------------------
main_fsm_f : process(clk, reset_n) begin
	if(reset_n = '0')then
		current_main_state <= idle;
	elsif(clk'event and clk = '1')then 
		current_main_state <= next_main_state;
	end if;	
end process;

-------------------------------------------------------------------------------
--main state machine combo
-------------------------------------------------------------------------------
main_fsm : process(current_main_state, en_reg1, infifo_rdusedw, outfifo_wrusedw, head_cnt, 
                    allpct_wr_cnt, infifo_empty, compr_cnt, compr_size, outfifo_reserve, compr_reserve, skip_packets_sig) begin
  next_main_state <= current_main_state;
  case current_main_state is
    
    when idle =>
      if en_reg1='1' then 
        next_main_state<=check_outfifo;
      else
        next_main_state<=idle;
      end if;
		
    when check_outfifo => --check that there is enough space for one packet 
--		if unsigned(outfifo_wrusedw)<outfifo_reserve-pct_size/2 or skip_packets_sig='1' then
		if unsigned(outfifo_wrusedw)<outfifo_reserve-pct_size/8 or skip_packets_sig='1' then
		--if unsigned(outfifo_wrusedw)<outfifo_reserve-pct_size/8 or skip_packets_sig='1' then --(use when testing loopback in FPGA)
        next_main_state<=wr_head; 
      else
        next_main_state<=idle;
      end if;
      
    when wr_head =>       --write reserved bits to packet
--        if head_cnt<3 then 
--          next_main_state<=wr_head;
--        else
--          next_main_state<=wr_cnt;
--        end if;
		  
          next_main_state<=wr_cnt;
		  
    when wr_cnt =>        --write sample nr counter value to packet          
--        if head_cnt<3 then 
--          next_main_state<=wr_cnt;
--        else
--			 if unsigned(infifo_rdusedw)>=2  then -- to check that there is enough samples to write compress 
--            next_main_state<=wr_samples;
--          else 
--            next_main_state<=check_fifo;
--          end if;
--        end if;

			 if unsigned(infifo_rdusedw)>=compr_size  then --2-- to check that there is enough samples to write compress 
            next_main_state<=wr_samples;
          else 
            next_main_state<=check_fifo;
          end if;


		  
    when check_fifo =>   --check that there is enough samples for compressing data in infifo
		if allpct_wr_cnt<pct_size/8-1 then  
		  if unsigned(infifo_rdusedw)>=compr_size then --2
            next_main_state<=wr_samples;
          else 
            next_main_state<=check_fifo;
          end if;
		else 
			next_main_state<=idle;
		end if;
          
    when wr_samples =>  --fill rest of the packet with compressed samples
--        if allpct_wr_cnt<pct_size/2-1 then 
        if allpct_wr_cnt<pct_size/8-1 then 
			 if infifo_empty='1' then 
				next_main_state<=check_fifo;
          elsif compr_cnt=compr_size-1 then 
				if unsigned(infifo_rdusedw)>=compr_size and infifo_empty='0' then
              next_main_state<=wr_samples;
            else 
              next_main_state<=check_fifo;
            end if;
          else
            next_main_state<=wr_samples;
          end if;
        else
			--if unsigned(outfifo_wrusedw)<outfifo_reserve-pct_size/2 or skip_packets_sig='1' then
			if unsigned(outfifo_wrusedw)<outfifo_reserve-pct_size/8-1 or skip_packets_sig='1' then
			--if unsigned(outfifo_wrusedw)<outfifo_reserve-pct_size/8 or skip_packets_sig='1' then --(use when testing loopback in FPGA) 			 
            next_main_state<=wr_head; 
          else
            next_main_state<=idle;
          end if;
        end if;
		  
    when others =>
        next_main_state<=idle;
  end case;
end process;


-------------------------------------------------------------------------------
-- sync registers to sync signals to current clock domain
-------------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
			en_reg0<='0';
			en_reg1<='0';
			tx_pct_loss_reg0<='0';
			tx_pct_loss_reg1<='0';
			tx_pct_loss_clr_reg0<='0';
			tx_pct_loss_clr_reg1<='0';
			sample_width_reg0<="10";
			sample_width_reg1<="10";
 	    elsif (clk'event and clk = '1') then
 	      en_reg0<=en;
 	      en_reg1<=en_reg0;
 	      tx_pct_loss_reg0<=tx_pct_loss;
 	      tx_pct_loss_reg1<=tx_pct_loss_reg0;
 	      tx_pct_loss_clr_reg0<=tx_pct_loss_clr;
 	      tx_pct_loss_clr_reg1<=tx_pct_loss_clr_reg0;
			sample_width_reg0<=sample_width;
			sample_width_reg1<=sample_width_reg0;
 	    end if;
    end process;
-------------------------------------------------------------------------------
-- to count when to write header or sample nr to packet
-------------------------------------------------------------------------------   
      process(reset_n, clk)
    begin
      if reset_n='0' then
          head_cnt<=(others=>'0');
 	    elsif (clk'event and clk = '1') then
 	      if current_main_state=wr_head or current_main_state=wr_cnt then 
 	        head_cnt<=head_cnt+1;
 	      else 
 	        head_cnt<=(others=>'0');
 	      end if;
 	    end if;
    end process;
-------------------------------------------------------------------------------
-- counter for data mux
-------------------------------------------------------------------------------   
      process(reset_n, clk)
    begin
      if reset_n='0' then
          pct_wr_cnt<=(others=>'0');
 	    elsif (clk'event and clk = '1') then
 	      if current_main_state=wr_head or current_main_state=wr_cnt then 
 	        pct_wr_cnt<=pct_wr_cnt+1;
 	      end if;
 	    end if;
    end process;
 -------------------------------------------------------------------------------
-- counter for packet
-------------------------------------------------------------------------------   
      process(reset_n, clk)
    begin
      if reset_n='0' then
          allpct_wr_cnt<=(others=>'0');
 	    elsif (clk'event and clk = '1') then
 	      if outfifo_wr_sig='1' then
 	        --if allpct_wr_cnt<pct_size/2-1 then 
				if allpct_wr_cnt<pct_size/8-1 then
 	          allpct_wr_cnt<=allpct_wr_cnt+1;
 	        else 
 	          allpct_wr_cnt<=(others=>'0');
 	        end if;
 	      end if;
 	    end if;
    end process;  
    
-------------------------------------------------------------------------------
-- to check overal writes to outfifo
-------------------------------------------------------------------------------   
      process(reset_n, clk)
    begin
      if reset_n='0' then
          check_cnt<=(others=>'0');
 	    elsif (clk'event and clk = '1') then
 	      if outfifo_wr_sig='1' then
 	          check_cnt<=check_cnt+1;
 	      end if;
 	    end if;
    end process;     
         
-------------------------------------------------------------------------------
-- counter for compressing data
-------------------------------------------------------------------------------   
      process(reset_n, clk)
    begin
      if reset_n='0' then
          compr_cnt<=(others=>'0');
 	    elsif (clk'event and clk = '1') then
 	      if current_main_state=wr_samples then
 	        if compr_cnt<compr_size-1 then   
 	          compr_cnt<=compr_cnt+1;
 	        else 
 	          compr_cnt<=(others=>'0');
 	        end if;
 	      end if;
 	    end if;
    end process; 
-------------------------------------------------------------------------------
-- to count active channels (!!! not sure if this will work on high frequency !!!)
-------------------------------------------------------------------------------    
      process (reset_n, clk) 
        variable sum : integer := 0; 
    begin 
      if (reset_n = '0') then 
        active_ch_cnt <= (others=>'0');
		  active_ch_cnt_reg0<=(others=>'0');
		  active_ch_cnt_reg1<=(others=>'0');
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
			active_ch_cnt_reg0<=active_ch_cnt;
			active_ch_cnt_reg1<=active_ch_cnt_reg0; 
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
 	        if infifo_rd_sig='1' then 
 	            if sample_nrcnt<active_ch_cnt_reg1*2-1 then   
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
    
    
-------------------------------------------------------------------------------
-- detect cleared packets in tx path
-------------------------------------------------------------------------------   
      process(reset_n, clk)
    begin
      if reset_n='0' then
          tx_pct_loss_detect<='0';
 	    elsif (clk'event and clk = '1') then
 	      if en_reg1='1' then
 	        if tx_pct_loss_reg1='1' then 
 	          tx_pct_loss_detect<='1';
 	        elsif  tx_pct_loss_clr_reg1='1' then 
 	          tx_pct_loss_detect<='0';
 	        else 
 	          tx_pct_loss_detect<=tx_pct_loss_detect;
 	        end if;
 	      else 
 	         tx_pct_loss_detect<='0';
 	      end if;
 	    end if;
    end process;  

-------------------------------------------------------------------------------
-- pct header and sample nr muxes
-------------------------------------------------------------------------------
--pct_header<=pct_rsrvd0 when head_cnt="00" else 
--            pct_rsrvd1 when head_cnt="01" else 
--            pct_rsrvd2 when head_cnt="10" else
--            pct_rsrvd3;
--            
--pct_smplnr<=lpmcnt_q(15 downto 0) when head_cnt="00" else 
--            lpmcnt_q(31 downto 16) when head_cnt="01" else 
--            lpmcnt_q(47 downto 32) when head_cnt="10" else
--            lpmcnt_q(63 downto 48);            
--                      
--outfifo_data<=pct_header when allpct_wr_cnt<4 else 
--              pct_smplnr when allpct_wr_cnt<8 else 
--              cmprsd_data;
				           
                      
outfifo_data<=pct_rsrvd when allpct_wr_cnt<1 else 
              lpmcnt_q(61 downto 0) & "00" 	when allpct_wr_cnt<2 else 
              cmprsd_data;
-------------------------------------------------------------------------------
-- port maps of modules
-------------------------------------------------------------------------------              
cmpr_inst : compress_v2 
  port map(
        clk             => clk, 
        reset_n         => reset_n,
        data_in         => cmpr_dain,
        data_in_valid   => infifo_rd_sig,
        sample_width    => sample_width_reg1, 
        data_out        => cmprsd_data,
        data_out_valid  => cmprsd_data_valid     
        );
        
		cnt_inst : LPM_COUNTER
	GENERIC MAP (
		lpm_direction 		=> "UP",
		lpm_port_updown 	=> "PORT_UNUSED",
		lpm_type 			=> "LPM_COUNTER",
		lpm_width 			=> 64
	)
	PORT MAP (
		aclr 		=> clr_smpl_nr,
		clock 	=> clk,
		cnt_en 	=> lpmcnt_cnten,
		q 			=> lpmcnt_q
	);
	
	
	
	--lpmcnt_aclr<= not en_reg1;
	lpmcnt_cnten<='1' when sample_nrcnt=active_ch_cnt_reg1*2-1 and infifo_rd_sig='1' else '0'; 


	
-------------------------------------------------------------------------------
--packet skipping signal
-------------------------------------------------------------------------------	
 process(current_state)begin
	if(current_state = skip_packets) then
		skip_packets_sig<='1';
	else
		skip_packets_sig<='0';
	end if;
end process; 
	
-------------------------------------------------------------------------------
--packet skipping state machine
-------------------------------------------------------------------------------
fsm_f : process(clk, reset_n) begin
	if(reset_n = '0')then
		current_state <= idle;
	elsif(clk'event and clk = '1')then 
		current_state <= next_state;
	end if;	
end process;

-------------------------------------------------------------------------------
--packet skipping state combo
-------------------------------------------------------------------------------
fsm : process(current_state, infifo_rdusedw, allpct_wr_cnt, outfifo_wrusedw, outfifo_reserve) begin
  next_state <= current_state;
  case current_state is
    when idle =>
		--if unsigned(infifo_rdusedw)>30719 then --detect when infifo is about to become full(change this value depending on fifo size)
		if unsigned(infifo_rdusedw)>512 then --detect when infifo is about to become full(change this value depending on fifo size)
			next_state<=wait_pct_end;
		else 
			next_state<=idle;
		end if;
	when wait_pct_end =>                      --make sure that full packet is written to outfifo
			--if allpct_wr_cnt>=pct_size/2-1 or allpct_wr_cnt=0 then
			if allpct_wr_cnt>=pct_size/8-1 or allpct_wr_cnt=0 then 	
					next_state<=skip_packets;
			else 
				next_state<=wait_pct_end;
			end if;
	when skip_packets =>								--skip some packets to freeup some space in outfifo and infifo 
			--if allpct_wr_cnt>=pct_size/2-1 and unsigned(infifo_rdusedw)<256 and unsigned(outfifo_wrusedw)<outfifo_reserve-pct_size/2 then 
			if allpct_wr_cnt>=pct_size/8-1 and unsigned(infifo_rdusedw)<256 and unsigned(outfifo_wrusedw)<outfifo_reserve-pct_size/8 then
					next_state<=idle;
			else 
					next_state<=skip_packets;
			end if;		
	 when others=>
			next_state<=idle;
	 end case;
end process;
 
  
end arch;   




