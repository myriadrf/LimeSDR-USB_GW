-- ----------------------------------------------------------------------------	
-- FILE: 	tx_pct_data_mimo.vhd
-- DESCRIPTION:	reads packets from 4 fifo
-- DATE:	June 25, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity tx_pct_data_mimo is
  generic ( num_of_fifo : integer := 3;
            fifo_size   : integer := 10;
            pct_size    : integer := 1024;
            dcmpr_fifo  : integer := 10;
            smpl_width  : integer := 12  
          );
  
  port (
        --input ports 
        clk           : in std_logic;
        reset_n       : in std_logic;
        pct_samplenr  : in std_logic_vector(63 downto 0);
        fifo_wclk     : in std_logic;
        fifo_wrreq    : in std_logic;
        fifo_data     : in std_logic_vector(15 downto 0);
        fifo_rclk     : in std_logic;
        --output ports 
        tx_outfifo_rdy  : out std_logic;
        fifo_q        	: out std_logic_vector(15 downto 0);
        sample_width    : in std_logic_vector(1 downto 0); -- "00"-16bit, "01"-14bit, "10"-12bit
        tx_en         	: in std_logic;
		  tst_aclr_ext		: out std_logic;
		  lte_synch_dis	: in std_logic;
		  mimo_en         : in std_logic;
		  dd_data_h       : out std_logic_vector(smpl_width downto 0);
		  dd_data_l       : out std_logic_vector(smpl_width downto 0);
		  fr_start        : in std_logic;
		  dd_data_h_r     : out std_logic_vector(smpl_width downto 0);
		  dd_data_l_r     : out std_logic_vector(smpl_width downto 0);
		  rd_cnt_ext		: out std_logic_vector(15 downto 0);
		  test_data_out	: out std_logic_vector(31 downto 0);
		  error_out			: out std_logic;
		  error_out_fx3	: out std_logic;
		  test_fx3_cnt		: out std_LOGIC_VECTOR(15 downto 0)
        );
end tx_pct_data_mimo;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of tx_pct_data_mimo is
  
  signal aclr0, aclr1, aclr2, aclr3          : std_logic;
  signal rdreq0, rdreq1, rdreq2, rdreq3, fifo_read_en      : std_logic;
  signal wrreq0, wrreq1, wrreq2, wrreq3      : std_logic;
  
  signal wrempty0, wrempty1, wrempty2, wrempty3 : std_logic;

  signal q0, q1, q2, q3 			: std_logic_vector(31 downto 0);
  signal fifo_wsel, fifo_rsel   	: std_logic_vector(1 downto 0);
  
  signal fifo_rdreq : std_logic;
  signal wrreq_cnt  : unsigned(15 downto 0);
  signal wreq_en    : std_logic;
  signal aclr       : std_logic;
  
  signal fifo0_samplenr, fifo1_samplenr, fifo2_samplenr, fifo3_samplenr   				  : std_logic_vector(63 downto 0);
  signal fifo0_samplenr_d0, fifo1_samplenr_d0, fifo2_samplenr_d0, fifo3_samplenr_d0   : std_logic_vector(63 downto 0);
  signal fifo0_samplenr_d1, fifo1_samplenr_d1, fifo2_samplenr_d1, fifo3_samplenr_d1   : std_logic_vector(63 downto 0);
  signal rdusedw0, rdusedw1, rdusedw2, rdusedw3 											     : std_logic_vector(9 downto 0);
  
  signal fifo0_pctrsvd, fifo1_pctrsvd, fifo2_pctrsvd, fifo3_pctrsvd						: std_logic_vector(63 downto 0);
  signal fifo0_pctrsvd_d0, fifo1_pctrsvd_d0, fifo2_pctrsvd_d0, fifo3_pctrsvd_d0		: std_logic_vector(63 downto 0);
  signal fifo0_pctrsvd_d1, fifo1_pctrsvd_d1, fifo2_pctrsvd_d1, fifo3_pctrsvd_d1		: std_logic_vector(63 downto 0);
  signal rdusedw_mux : std_logic_vector(9 downto 0);
  
  signal rdusedw0_reg, rdusedw1_reg, rdusedw2_reg, rdusedw3_reg 			: std_logic_vector(9 downto 0);
  signal fifo0_data_rdy, fifo1_data_rdy, fifo2_data_rdy, fifo3_data_rdy : std_logic;
  
  signal tx_mux_sel     : std_logic_vector(1 downto 0);
  signal tx_mux_sel_d   : std_logic_vector(1 downto 0); 
  
  signal wr_status 		: std_logic;
  signal diq_ready  		: std_logic;
  signal fifo_rd_cnt  	: unsigned(15 downto 0);
  signal pct_samplenr_d0,  pct_samplenr_d1 : std_logic_vector(63 downto 0);
  
  signal decompr_wr : std_logic;
  signal decompr_dataout_valid 	: std_logic;
  signal decompr_data         	: std_logic_vector(31 downto 0); 
  signal decompr_fifo_rd      	: std_logic;
  signal decompr_fifo_empty   	: std_logic; 
  signal dec_wr0    : std_logic;
  signal dec_wr1    : std_logic;
  signal dec_wr2    : std_logic;
  signal dec_wr3    : std_logic;
  signal decopr_min : unsigned(2 downto 0);
  signal rd_en_cnt  : unsigned(2 downto 0);
  signal decompr_wusedw : std_logic_vector(dcmpr_fifo-1 downto 0);
  signal iq_sel     		: std_logic;
  signal iq_sel_sig 		: std_logic;
  signal rd_cnt			: unsigned(15 downto 0);
  signal test_cnt0		: unsigned(11 downto 0);
  signal test_cnt1		: unsigned(11 downto 0);
  signal fx3_testcnt		: unsigned(15 downto 0);
  
  signal compressed_data  : std_logic_vector(31 downto 0);
  
 
  type fifo_state is (idle, check0, check1, check2, check3);
  signal current_fifo_st, nex_fifo_st :  fifo_state;
  
  type mux_state is (idle, mux0, mux1, mux2, mux3);
  signal current_mux_state, next_mux_state :  mux_state; 
  
  type read_state is (idle, read0, read1, read2, read3);
  signal current_read_state, next_read_state :  read_state; 
  
  type readen_state is (idle, wait_rd, rd_en);
  signal current_readen_state, next_readen_state :  readen_state; 
  signal valid_en_limit 	 : unsigned(11 downto 0);
  
  
	signal dd_data_h_s       : std_logic_vector(smpl_width downto 0);
	signal dd_data_l_s       : std_logic_vector(smpl_width downto 0);
	signal test_data_out_s   : std_logic_VECTOR(31 downto 0);

  
  type smpl_state is (idle, tx_i, tx_q);
  signal current_smpl_state, next_smpl_state :  smpl_state; 

  
  component tx_outfifo_16_to_32 IS 
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdempty	: OUT STD_LOGIC ;
		rdfull	: OUT STD_LOGIC ;
		rdusedw	: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		wrempty	: OUT STD_LOGIC ;
		wrfull	: OUT STD_LOGIC ;
		wrusedw	: OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
	);
END component;


component decompress is
  generic (data_width : integer:= 31;
          fifo_rsize: integer:= 9 );
  port (
        --input ports 
        wclk          : in std_logic;
        rclk          : in std_logic;
        reset_n       : in std_logic;
        data_in       : in std_logic_vector(data_width-1 downto 0);
        data_in_valid : in std_logic; -- data_in leading signal which indicates valid incomong data
        sample_width  : in std_logic_vector(1 downto 0); -- "00"-16bit, "01"-14bit, "10"-12bit
        rdreq         : in std_logic;
        rdempty       : out std_logic;
        rdusedw       : out std_logic_vector(fifo_rsize-1 downto 0);
        wfull         : out std_logic;
        wusedw        : out std_logic_vector(dcmpr_fifo-1 downto 0);
        dataout_valid : out std_logic;
        decmpr_data   : out std_logic_vector(31 downto 0) 

        --output ports       
        );
end component;


  
begin
  
  rd_cnt_ext<=std_logic_vector(rd_cnt);
  
-- valid_en_limit<= x"7F5" when sample_width="01" else
--                  x"7F8";

                   
                     
  valid_en_limit<= x"3F7" when sample_width="01" else
                   x"3FC";
  
  
--  decopr_min<="011" when sample_width="10" else 
--              "111" when sample_width="01" else
--              "000";
  
  decopr_min<="011" when sample_width="10" else 
              "111" when sample_width="01" else
              "100";

fifo_rdreq<=rdreq0 or rdreq1 or rdreq2 or rdreq3;
--diq_ready<=fifo0_data_rdy or fifo1_data_rdy or fifo2_data_rdy or fifo3_data_rdy;



-------------------------------------------------------------------------------         
-- fifo rdreq signal
-------------------------------------------------------------------------------

--fifo0
process(current_read_state, fifo_read_en) begin
	if (current_read_state=read0 and fifo_read_en='1') then
			rdreq0 <= '1'; 
	else
		  rdreq0<='0';
	end if;	
end process; 

--fifo1
process(current_read_state, fifo_read_en) begin
	if (current_read_state=read1 and fifo_read_en='1') then
			rdreq1 <= '1'; 
	else
		  rdreq1<='0';
	end if;	
end process;
 
--fifo2
process(current_read_state, fifo_read_en) begin
	if (current_read_state=read2 and fifo_read_en='1') then
			rdreq2 <= '1'; 
	else
		  rdreq2<='0';
	end if;	
end process; 

--fifo3
process(current_read_state, fifo_read_en) begin
	if (current_read_state=read3 and fifo_read_en='1') then
			rdreq3 <= '1'; 
	else
		  rdreq3<='0';
	end if;	
end process;

--read enable

process(current_readen_state)begin
	if (current_readen_state=rd_en) then
			fifo_read_en<='1'; 
	else
		  fifo_read_en<='0';
	end if;	
end process;


--rd_en_cnt

process(fifo_rclk, reset_n) begin
	if(reset_n = '0')then
		rd_en_cnt <= (others=>'0');
	elsif(fifo_rclk'event and fifo_rclk = '1')then 
		if fifo_rdreq='1' and fifo_rd_cnt<valid_en_limit then 
		  if rd_en_cnt<decopr_min-1 then 
		     rd_en_cnt<=rd_en_cnt+1;
		  else 
		    rd_en_cnt <= (others=>'0');
		  end if;
		else 
		  rd_en_cnt<=rd_en_cnt;
		end if;
	end if;	
end process;

-------------------------------------------------------------------------------
--read en state machine
-------------------------------------------------------------------------------
readen_fsm_f : process(fifo_rclk, reset_n) begin
	if(reset_n = '0')then
		current_readen_state <= rd_en;
	elsif(fifo_rclk'event and fifo_rclk = '1')then 
		current_readen_state <= next_readen_state;
	end if;	
end process;

readen_fsm : process(current_readen_state, decompr_wusedw, rd_en_cnt, decopr_min)
begin
  
    next_readen_state <= current_readen_state;
    
    case current_readen_state is

      when rd_en=>
        --if rd_en_cnt=decopr_min-1 and unsigned(decompr_wusedw)>=254 then
        if rd_en_cnt=decopr_min-1 and unsigned(decompr_wusedw)>=498 then --249 
            next_readen_state<=wait_rd;
        else
            next_readen_state<=rd_en; 
        end if;
      when wait_rd=>
				--if  unsigned(decompr_wusedw)<254 then
				if  unsigned(decompr_wusedw)<498 then  
					next_readen_state<=rd_en;    
				else
					next_readen_state<=wait_rd;
				end if;  
      when others => 
      end case;
end process; 




-------------------------------------------------------------------------------
--fifo read state machine
-------------------------------------------------------------------------------
read_fsm_f : process(fifo_rclk, reset_n) begin
	if(reset_n = '0')then
		current_read_state <= idle;
	elsif(fifo_rclk'event and fifo_rclk = '1')then 
		current_read_state <= next_read_state;
	end if;	
end process;

-------------------------------------------------------------------------------
--fifo read machine combo
-------------------------------------------------------------------------------
read_fsm : process(current_read_state, fifo0_data_rdy, fifo1_data_rdy, fifo2_data_rdy, fifo3_data_rdy,
							fifo_rd_cnt, pct_samplenr, fifo0_samplenr_d1, fifo1_samplenr_d1, fifo2_samplenr_d1, fifo3_samplenr_d1, lte_synch_dis,
							fifo0_pctrsvd_d1(4), fifo1_pctrsvd_d1(4), fifo2_pctrsvd_d1(4), fifo3_pctrsvd_d1(4)) 
begin
    next_read_state <= current_read_state;
    
    case current_read_state is
      when idle =>
        if fifo0_data_rdy='1'  and (unsigned(fifo0_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo0_pctrsvd_d1(4)='1') then 
            next_read_state<=read0;
        elsif fifo1_data_rdy='1'  and (unsigned(fifo1_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo1_pctrsvd_d1(4)='1') then 
            next_read_state<=read1;
        elsif fifo2_data_rdy='1'  and (unsigned(fifo2_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo2_pctrsvd_d1(4)='1')then 
            next_read_state<=read2; 
	     elsif fifo3_data_rdy='1'  and (unsigned(fifo3_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo3_pctrsvd_d1(4)='1') then 
            next_read_state<=read3; 			
        else
            next_read_state<=idle;
        end if;
        
      when read0 => 
           --if fifo_rd_cnt=pct_size-9 then --??
           if fifo_rd_cnt=((pct_size-8)/2-1) then --??
              if fifo1_data_rdy='1' and (unsigned(fifo1_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo1_pctrsvd_d1(4)='1') then 
                next_read_state<=read1;
              elsif fifo2_data_rdy='1' and (unsigned(fifo2_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo2_pctrsvd_d1(4)='1') then
                next_read_state<=read2;
				 elsif fifo3_data_rdy='1' and (unsigned(fifo3_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo3_pctrsvd_d1(4)='1') then
                next_read_state<=read3;
              else
               next_read_state<=idle;
              end if;     
           else 
              next_read_state<=read0;
          end if;
          
      when read1 =>   
          --if fifo_rd_cnt=pct_size-9 then --??
          if fifo_rd_cnt=((pct_size-8)/2-1) then --??
              if fifo2_data_rdy='1' and (unsigned(fifo2_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo2_pctrsvd_d1(4)='1')then 
                next_read_state<=read2;
				  elsif fifo3_data_rdy='1' and (unsigned(fifo3_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo3_pctrsvd_d1(4)='1') then
                next_read_state<=read3; 
              elsif fifo0_data_rdy='1'  and (unsigned(fifo0_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo0_pctrsvd_d1(4)='1') then
                next_read_state<=read0;
              else
               next_read_state<=idle;
              end if;   
          else 
              next_read_state<=read1;
          end if;
			 
      when read2 =>   
          --if fifo_rd_cnt=pct_size-9 then --??
          if fifo_rd_cnt=((pct_size-8)/2-1) then --??
			 	  if fifo3_data_rdy='1' and (unsigned(fifo3_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo3_pctrsvd_d1(4)='1') then
                next_read_state<=read3;
              elsif fifo0_data_rdy='1' and (unsigned(fifo0_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo0_pctrsvd_d1(4)='1') then 
                next_read_state<=read0;
              elsif fifo1_data_rdy='1' and (unsigned(fifo1_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo1_pctrsvd_d1(4)='1') then
                next_read_state<=read1;
              else
               next_read_state<=idle;
              end if;   
          else 
              next_read_state<=read2;
          end if;
			 
		when read3 =>   
          --if fifo_rd_cnt=pct_size-9 then --??
          if fifo_rd_cnt=((pct_size-8)/2-1) then --??
              if fifo0_data_rdy='1' and (unsigned(fifo0_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo0_pctrsvd_d1(4)='1') then 
                next_read_state<=read0;
              elsif fifo1_data_rdy='1' and (unsigned(fifo1_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo1_pctrsvd_d1(4)='1') then
                next_read_state<=read1;
				  elsif fifo2_data_rdy='1' and (unsigned(fifo2_samplenr_d1)=unsigned(pct_samplenr)+1 or lte_synch_dis='1' or fifo2_pctrsvd_d1(4)='1') then
                next_read_state<=read2; 
              else
               next_read_state<=idle;
              end if;   
          else 
              next_read_state<=read3;
          end if;
			 
      when others => 
      end case;
end process;


-------------------------------------------------------------------------------
--fifo select state machine
-------------------------------------------------------------------------------
fifo_fsm_f : process(fifo_wclk, reset_n) begin
	if(reset_n = '0')then
		current_fifo_st <= idle;
	elsif(fifo_wclk'event and fifo_wclk = '1')then 
		current_fifo_st <= nex_fifo_st;
	end if;	
end process;

-------------------------------------------------------------------------------
--fifo state machine combo
-------------------------------------------------------------------------------
fifo_fsm : process(current_fifo_st, wrempty0, wrempty1, wrempty2, wrempty3, wrreq_cnt) 
begin
    nex_fifo_st <= current_fifo_st;
    
    case current_fifo_st is
      when idle =>
            if wrempty0='1' then 
              nex_fifo_st<=check0;
            elsif wrempty1='1' then 
              nex_fifo_st<=check1;
            elsif wrempty2='1' then
               nex_fifo_st<=check2;
            elsif wrempty3='1' then
               nex_fifo_st<=check3; 					
            else 
              nex_fifo_st<=idle;
            end if;
            
      when check0 => -- select fifo0 for writting
            if wrreq_cnt=pct_size-1  then 
              if wrempty1='1' then 
                  nex_fifo_st<=check1;
              elsif wrempty2='1' then 
                  nex_fifo_st<=check2;
				  elsif wrempty3='1' then 
                  nex_fifo_st<=check3;
              else
                 nex_fifo_st<=idle;
              end if;  
            else
              nex_fifo_st<=check0;
          	 end if;
          	  
      when check1 => -- select fifo1 for writting
            if wrreq_cnt=pct_size-1 then 
              if wrempty2='1' then 
                  nex_fifo_st<=check2;
				  elsif wrempty3='1' then 
                  nex_fifo_st<=check3;	
              elsif wrempty0='1' then 
                  nex_fifo_st<=check0;
              else
                 nex_fifo_st<=idle;
              end if;
            else
              nex_fifo_st<=check1;
          	 end if;
          	 
      when check2 => -- select fifo2 for writting
            if wrreq_cnt=pct_size-1 then
			     if wrempty3='1' then 
                  nex_fifo_st<=check3;	
              elsif wrempty0='1' then 
                  nex_fifo_st<=check0;
              elsif wrempty1='1' then 
                  nex_fifo_st<=check1;
              else
                 nex_fifo_st<=idle;
              end if;
            else
              nex_fifo_st<=check2;
          	end if;


      when check3 => -- select fifo3 for writting
            if wrreq_cnt=pct_size-1 then
              if wrempty0='1' then 
                  nex_fifo_st<=check0;
              elsif wrempty1='1' then 
                  nex_fifo_st<=check1;
				  elsif wrempty2='1' then 
                  nex_fifo_st<=check2;		
              else
                 nex_fifo_st<=idle;
              end if;             
            else
              nex_fifo_st<=check3;
          	end if; 				 
        
     when others =>
     end case;
  end process; 
  
-------------------------------------------------------------------------------    
 --wrreq counter
------------------------------------------------------------------------------- 
  process(reset_n, fifo_wclk)
    begin
      if reset_n='0' then
        wrreq_cnt<=(others=>'0'); 
 	    elsif (fifo_wclk'event and fifo_wclk = '1') then
 	      if fifo_wrreq='1' then 
 	          if wrreq_cnt<pct_size-1 then  
 	              wrreq_cnt<=wrreq_cnt+1;
 	          else 
 	              wrreq_cnt<=(others=>'0');
 	          end if;
 	      else 
 	          wrreq_cnt<=wrreq_cnt;
 	      end if;
 	    end if;
    end process;
    
    
-------------------------------------------------------------------------------    
 --rdreq counter
------------------------------------------------------------------------------- 
  process(reset_n, fifo_rclk)
    begin
      if reset_n='0' then
        fifo_rd_cnt<=(others=>'0'); 
		  --pct_samplenr_d0<=(others=>'0');
		  --pct_samplenr_d1<=(others=>'0');
		  
		   fifo0_samplenr_d0<=(others=>'0');
			fifo1_samplenr_d0<=(others=>'0');
			fifo2_samplenr_d0<=(others=>'0');
			fifo3_samplenr_d0<=(others=>'0');
			
			
			fifo0_samplenr_d1<=(others=>'0');
			fifo1_samplenr_d1<=(others=>'0');
			fifo2_samplenr_d1<=(others=>'0');
			fifo3_samplenr_d1<=(others=>'0');
			
			fifo0_pctrsvd_d0<=(others=>'0');
			fifo1_pctrsvd_d0<=(others=>'0');
			fifo2_pctrsvd_d0<=(others=>'0');
			fifo3_pctrsvd_d0<=(others=>'0');
			
			fifo0_pctrsvd_d1<=(others=>'0');
			fifo1_pctrsvd_d1<=(others=>'0');
			fifo2_pctrsvd_d1<=(others=>'0');
			fifo3_pctrsvd_d1<=(others=>'0');
			
 	    elsif (fifo_rclk'event and fifo_rclk = '1') then
			--synchronize pct_samplenr to fifo_rclk
		   --pct_samplenr_d0<=pct_samplenr;
			--pct_samplenr_d1<=pct_samplenr_d0;
			--synchronize fifox_samplenr to fifo_rclk
			fifo0_samplenr_d0<=fifo0_samplenr;
			fifo1_samplenr_d0<=fifo1_samplenr;
			fifo2_samplenr_d0<=fifo2_samplenr;
			fifo3_samplenr_d0<=fifo3_samplenr;
			
			fifo0_samplenr_d1<=fifo0_samplenr_d0;
			fifo1_samplenr_d1<=fifo1_samplenr_d0;
			fifo2_samplenr_d1<=fifo2_samplenr_d0;
			fifo3_samplenr_d1<=fifo3_samplenr_d0;
			
			fifo0_pctrsvd_d0<=fifo0_pctrsvd;
			fifo1_pctrsvd_d0<=fifo1_pctrsvd;
			fifo2_pctrsvd_d0<=fifo2_pctrsvd;
			fifo3_pctrsvd_d0<=fifo3_pctrsvd;
			
			fifo0_pctrsvd_d1<=fifo0_pctrsvd_d0;
			fifo1_pctrsvd_d1<=fifo1_pctrsvd_d0;
			fifo2_pctrsvd_d1<=fifo2_pctrsvd_d0;
			fifo3_pctrsvd_d1<=fifo3_pctrsvd_d0;
			
			
 	      if fifo_rdreq='1' then 
 	          --if fifo_rd_cnt<pct_size-9 then 
 	          if fifo_rd_cnt<((pct_size-8)/2-1) then 
 	              fifo_rd_cnt<=fifo_rd_cnt+1;
 	          else 
 	              fifo_rd_cnt<=(others=>'0');
 	          end if;
 	      else 
 	          fifo_rd_cnt<=fifo_rd_cnt;
 	      end if;
 	    end if;
    end process;
    
    
    
-------------------------------------------------------------------------------    
--to store sample nr
-------------------------------------------------------------------------------
  process(reset_n, fifo_wclk)
    begin
      if reset_n='0' then
        fifo0_samplenr<=(others=>'0');
        fifo1_samplenr<=(others=>'0');
        fifo2_samplenr<=(others=>'0');
		  fifo3_samplenr<=(others=>'0');
 	    elsif (fifo_wclk'event and fifo_wclk = '1') then
		 
 	      --fifo0
 	      if (wrreq_cnt=4 and current_fifo_st=check0) then 
 	        fifo0_samplenr(15 downto 0) <= fifo_data;
 	      elsif (wrreq_cnt=5 and current_fifo_st=check0) then
 	        fifo0_samplenr(31 downto 16) <= fifo_data;
 	      elsif (wrreq_cnt=6 and current_fifo_st=check0) then
 	        fifo0_samplenr(47 downto 32) <= fifo_data; 
 	      elsif (wrreq_cnt=7 and current_fifo_st=check0) then
 	        fifo0_samplenr(63 downto 48) <= fifo_data;    
 	      else
 	        if aclr0='1' then 
 	          fifo0_samplenr<=(others=>'0');
 	        else  
 	          fifo0_samplenr<=fifo0_samplenr;
 	        end if;
 	      end if;
			
 	      --fifo1 	      	      
 	      if (wrreq_cnt=4 and current_fifo_st=check1) then 
 	        fifo1_samplenr(15 downto 0) <= fifo_data;
 	      elsif (wrreq_cnt=5 and current_fifo_st=check1) then
 	        fifo1_samplenr(31 downto 16) <= fifo_data;
 	      elsif (wrreq_cnt=6 and current_fifo_st=check1) then
 	        fifo1_samplenr(47 downto 32) <= fifo_data; 
 	      elsif (wrreq_cnt=7 and current_fifo_st=check1) then
 	        fifo1_samplenr(63 downto 48) <= fifo_data; 
 	      else 
 	        if aclr1='1' then 
 	          fifo1_samplenr<=(others=>'0');
 	        else 
 	          fifo1_samplenr<=fifo1_samplenr;
 	        end if;
 	      end if;
 	      
 	      --fifo2			
 	      if (wrreq_cnt=4 and current_fifo_st=check2) then 
 	        fifo2_samplenr(15 downto 0) <= fifo_data;
 	      elsif (wrreq_cnt=5 and current_fifo_st=check2) then
 	        fifo2_samplenr(31 downto 16) <= fifo_data;
 	      elsif (wrreq_cnt=6 and current_fifo_st=check2) then
 	        fifo2_samplenr(47 downto 32) <= fifo_data; 
 	      elsif (wrreq_cnt=7 and current_fifo_st=check2) then
 	        fifo2_samplenr(63 downto 48) <= fifo_data; 
 	      else
 	       	if aclr2='1' then 
 	          fifo2_samplenr<=(others=>'0');
 	        else  
 	          fifo2_samplenr<=fifo2_samplenr;
 	        end if;
 	      end if;
			
 	      --fifo3						
 	      if (wrreq_cnt=4 and current_fifo_st=check3) then 
 	        fifo3_samplenr(15 downto 0) <= fifo_data;
 	      elsif (wrreq_cnt=5 and current_fifo_st=check3) then
 	        fifo3_samplenr(31 downto 16) <= fifo_data;
 	      elsif (wrreq_cnt=6 and current_fifo_st=check3) then
 	        fifo3_samplenr(47 downto 32) <= fifo_data; 
 	      elsif (wrreq_cnt=7 and current_fifo_st=check3) then
 	        fifo3_samplenr(63 downto 48) <= fifo_data; 
 	      else
 	       	if aclr3='1' then 
 	          fifo3_samplenr<=(others=>'0');
 	        else  
 	          fifo3_samplenr<=fifo3_samplenr;
 	        end if;
 	      end if;			

 	    end if;
    end process;
	 
	 
-------------------------------------------------------------------------------    
--to store sample pct reserved bits
-------------------------------------------------------------------------------
  process(reset_n, fifo_wclk)
    begin
      if reset_n='0' then
        fifo0_pctrsvd<=(others=>'0');
        fifo1_pctrsvd<=(others=>'0');
        fifo2_pctrsvd<=(others=>'0');
		  fifo3_pctrsvd<=(others=>'0');
 	    elsif (fifo_wclk'event and fifo_wclk = '1') then
		 
 	      --fifo0
 	      if (wrreq_cnt=0 and current_fifo_st=check0) then 
 	        fifo0_pctrsvd(15 downto 0) <= fifo_data;
 	      elsif (wrreq_cnt=1 and current_fifo_st=check0) then
 	        fifo0_pctrsvd(31 downto 16) <= fifo_data;
 	      elsif (wrreq_cnt=2 and current_fifo_st=check0) then
 	        fifo0_pctrsvd(47 downto 32) <= fifo_data; 
 	      elsif (wrreq_cnt=3 and current_fifo_st=check0) then
 	        fifo0_pctrsvd(63 downto 48) <= fifo_data;    
 	      else
 	        if aclr0='1' then 
 	          fifo0_pctrsvd<=(others=>'0');
 	        else  
 	          fifo0_pctrsvd<=fifo0_pctrsvd;
 	        end if;
 	      end if;
			
 	      --fifo1 	      	      
 	      if (wrreq_cnt=0 and current_fifo_st=check1) then 
 	        fifo1_pctrsvd(15 downto 0) <= fifo_data;
 	      elsif (wrreq_cnt=1 and current_fifo_st=check1) then
 	        fifo1_pctrsvd(31 downto 16) <= fifo_data;
 	      elsif (wrreq_cnt=2 and current_fifo_st=check1) then
 	        fifo1_pctrsvd(47 downto 32) <= fifo_data; 
 	      elsif (wrreq_cnt=3 and current_fifo_st=check1) then
 	        fifo1_pctrsvd(63 downto 48) <= fifo_data; 
 	      else 
 	        if aclr1='1' then 
 	          fifo1_pctrsvd<=(others=>'0');
 	        else 
 	          fifo1_pctrsvd<=fifo1_pctrsvd;
 	        end if;
 	      end if;
 	      
 	      --fifo2			
 	      if (wrreq_cnt=0 and current_fifo_st=check2) then 
 	        fifo2_pctrsvd(15 downto 0) <= fifo_data;
 	      elsif (wrreq_cnt=1 and current_fifo_st=check2) then
 	        fifo2_pctrsvd(31 downto 16) <= fifo_data;
 	      elsif (wrreq_cnt=2 and current_fifo_st=check2) then
 	        fifo2_pctrsvd(47 downto 32) <= fifo_data; 
 	      elsif (wrreq_cnt=3 and current_fifo_st=check2) then
 	        fifo2_pctrsvd(63 downto 48) <= fifo_data; 
 	      else
 	       	if aclr2='1' then 
 	          fifo2_pctrsvd<=(others=>'0');
 	        else  
 	          fifo2_pctrsvd<=fifo2_pctrsvd;
 	        end if;
 	      end if;
			
 	      --fifo3						
 	      if (wrreq_cnt=0 and current_fifo_st=check3) then 
 	        fifo3_pctrsvd(15 downto 0) <= fifo_data;
 	      elsif (wrreq_cnt=1 and current_fifo_st=check3) then
 	        fifo3_pctrsvd(31 downto 16) <= fifo_data;
 	      elsif (wrreq_cnt=2 and current_fifo_st=check3) then
 	        fifo3_pctrsvd(47 downto 32) <= fifo_data; 
 	      elsif (wrreq_cnt=3 and current_fifo_st=check3) then
 	        fifo3_pctrsvd(63 downto 48) <= fifo_data; 
 	      else
 	       	if aclr3='1' then 
 	          fifo3_pctrsvd<=(others=>'0');
 	        else  
 	          fifo3_pctrsvd<=fifo3_pctrsvd;
 	        end if;
 	      end if;			

 	    end if;
    end process;	 
     
 -------------------------------------------------------------------------------
--FIFO inst
-------------------------------------------------------------------------------        
  fifo0 : tx_outfifo_16_to_32 
  port map(
  		aclr		   => aclr0,
		data		   => fifo_data, 
		rdclk		   => fifo_rclk,
		rdreq		   => rdreq0,
		wrclk		   => fifo_wclk, 
		wrreq		   => wrreq0, 
		q		      => q0, 
		rdempty		=> open,
		rdfull		=> open,
		rdusedw     => rdusedw0,
		wrempty		=> wrempty0,
		wrfull		=> open, 
		wrusedw		=> open
  );
  
    fifo1 : tx_outfifo_16_to_32 
  port map(
  		aclr			=> aclr1,
		data			=> fifo_data, 
		rdclk		   => fifo_rclk,
		rdreq		   => rdreq1,
		wrclk		   => fifo_wclk, 
		wrreq		   => wrreq1, 
		q		      => q1, 
		rdempty		=> open,
		rdfull		=> open,
		rdusedw		=> rdusedw1,
		wrempty		=> wrempty1,
		wrfull		=> open, 
		wrusedw		=> open
  );
  
    fifo2 : tx_outfifo_16_to_32 
  port map(
  		aclr			=> aclr2,
		data			=> fifo_data, 
		rdclk		   => fifo_rclk,
		rdreq		   => rdreq2,
		wrclk		   => fifo_wclk, 
		wrreq		   => wrreq2, 
		q		      => q2, 
		rdempty		=> open,
		rdfull		=> open,
		rdusedw		=> rdusedw2,
		wrempty		=> wrempty2,
		wrfull		=> open, 
		wrusedw		=> open
  );
  
   
      fifo3 : tx_outfifo_16_to_32 
  port map(
  		aclr			=> aclr3,
		data			=> fifo_data, 
		rdclk		   => fifo_rclk,
		rdreq		   => rdreq3,
		wrclk		   => fifo_wclk, 
		wrreq		   => wrreq3, 
		q		      => q3, 
		rdempty		=> open,
		rdfull		=> open,
		rdusedw		=> rdusedw3,
		wrempty		=> wrempty3,
		wrfull		=> open, 
		wrusedw		=> open
  );
  
--   rdusedw_mux<=rdusedw0 when current_read_state=read0 else 
--                rdusedw1 when current_read_state=read1 else 
--                rdusedw2 when current_read_state=read2 else 
--                rdusedw3;

-------------------------------------------------------------------------------
--misc combinational signals
------------------------------------------------------------------------------   
tx_outfifo_rdy	<=  wrempty0 or wrempty1 or wrempty2 or wrempty3 or wr_status;
wr_status		<= '1' when unsigned(wrreq_cnt)>0 else '0';
wreq_en			<= '1' when  (wrreq_cnt>=8) else '0'; 
    
-------------------------------------------------------------------------------
--FIFO wrreq demux
-------------------------------------------------------------------------------
wrreq0<=(fifo_wrreq and wreq_en) when current_fifo_st=check0 else '0';
wrreq1<=(fifo_wrreq and wreq_en) when current_fifo_st=check1 else '0';
wrreq2<=(fifo_wrreq and wreq_en) when current_fifo_st=check2 else '0';
wrreq3<=(fifo_wrreq and wreq_en) when current_fifo_st=check3 else '0';


  process(reset_n, fifo_rclk)
    begin
      if reset_n='0' then
        decompr_wr<='0';
      elsif (fifo_rclk'event and fifo_rclk = '1') then
        if fifo_rd_cnt<valid_en_limit then         
          decompr_wr<=fifo_rdreq;
        else 
          decompr_wr<='0';
        end if;
      end if; 
   end process;
-------------------------------------------------------------------------------
--FIFO aclr
-------------------------------------------------------------------------------
  process(reset_n, fifo_rclk)
    begin
      if reset_n='0' then
        aclr0<='1';
        aclr1<='1';
        aclr2<='1';
		  aclr3<='1';
        rdusedw0_reg<=(others=>'0');
        rdusedw1_reg<=(others=>'0'); 
        rdusedw2_reg<=(others=>'0'); 
		  rdusedw3_reg<=(others=>'0');
 	    elsif (fifo_rclk'event and fifo_rclk = '1') then

 	     rdusedw0_reg<=rdusedw0;
        rdusedw1_reg<=rdusedw1;
        rdusedw2_reg<=rdusedw2;
		  rdusedw3_reg<=rdusedw3;
         
			--fifo0
 	      --if unsigned(rdusedw0)=pct_size-8 and unsigned(fifo0_samplenr_d1)<unsigned(pct_samplenr) and rdreq0='0' and lte_synch_dis='0' then 
 	       if unsigned(rdusedw0)=(pct_size-8)/2 and unsigned(fifo0_samplenr_d1)<unsigned(pct_samplenr) and rdreq0='0' and lte_synch_dis='0' and fifo0_pctrsvd_d1(4)='0' then   
 	          aclr0<='1';
 	      else 
 	          aclr0<='0';
 	      end if;
 	      
			--fifo1
 	      --if unsigned(rdusedw1)=pct_size-8 and unsigned(fifo1_samplenr_d1)<unsigned(pct_samplenr) and rdreq1='0' and lte_synch_dis='0' then 
 	        if unsigned(rdusedw1)=(pct_size-8)/2 and unsigned(fifo1_samplenr_d1)<unsigned(pct_samplenr) and rdreq1='0' and lte_synch_dis='0' and fifo1_pctrsvd_d1(4)='0'then   
 	          aclr1<='1';
 	      else 
 	          aclr1<='0';
 	      end if;
 	      
			--fifo2
 	      --if unsigned(rdusedw2)=pct_size-8 and unsigned(fifo2_samplenr_d1)<unsigned(pct_samplenr) and rdreq2='0' and lte_synch_dis='0' then 
 	        if unsigned(rdusedw2)=(pct_size-8)/2 and unsigned(fifo2_samplenr_d1)<unsigned(pct_samplenr) and rdreq2='0' and lte_synch_dis='0' and fifo2_pctrsvd_d1(4)='0' then   
 	          aclr2<='1';
 	      else 
 	          aclr2<='0';
 	      end if;
			
			--fifo3
			--if unsigned(rdusedw3)=pct_size-8 and unsigned(fifo3_samplenr_d1)<unsigned(pct_samplenr) and rdreq3='0' and lte_synch_dis='0' then 
 	      if unsigned(rdusedw3)=(pct_size-8)/2 and unsigned(fifo3_samplenr_d1)<unsigned(pct_samplenr) and rdreq3='0' and lte_synch_dis='0' and fifo3_pctrsvd_d1(4)='0'then     
 	          aclr3<='1';
 	      else 
 	          aclr3<='0';
 	      end if;
 	      
 	    end if;
    end process;
    
-------------------------------------------------------------------------------
--FIFO read ready
-------------------------------------------------------------------------------    
    
  process(reset_n, fifo_rclk)
    begin
      if reset_n='0' then

        fifo0_data_rdy<='0';
        fifo1_data_rdy<='0';
        fifo2_data_rdy<='0';
		  fifo3_data_rdy<='0';
        tx_mux_sel_d<=(others=>'0');
 	    elsif (fifo_rclk'event and fifo_rclk = '1') then
        tx_mux_sel_d<=tx_mux_sel;
		  
		  --fifo0
        --if unsigned(rdusedw0_reg)=pct_size-8 and aclr0='0' then 
        if unsigned(rdusedw0_reg)=(pct_size-8)/2 and aclr0='0' then 
            fifo0_data_rdy<='1';
        else 
            fifo0_data_rdy<='0';
        end if;
        
		  --fifo1
        --if unsigned(rdusedw1_reg)=pct_size-8 and aclr1='0' then
        if unsigned(rdusedw1_reg)=(pct_size-8)/2 and aclr1='0' then 
            fifo1_data_rdy<='1';
        else 
            fifo1_data_rdy<='0';
        end if;
		  
        --fifo2
        --if unsigned(rdusedw2_reg)=pct_size-8 and aclr2='0' then
        if unsigned(rdusedw2_reg)=(pct_size-8)/2 and aclr2='0' then 
            fifo2_data_rdy<='1';
        else 
            fifo2_data_rdy<='0';
        end if;
		  
		  --fifo3
		  --if unsigned(rdusedw3_reg)=pct_size-8 and aclr3='0' then
		  if unsigned(rdusedw3_reg)=(pct_size-8)/2 and aclr3='0' then 
            fifo3_data_rdy<='1';
        else 
            fifo3_data_rdy<='0';
        end if;
 	      
 	    end if;
    end process;
	 
-------------------------------------------------------------------------------
--TX mux and mux sel signal
-------------------------------------------------------------------------------  
   tx_mux_sel<="11" when   rdreq3='1' else
					"10" when   rdreq2='1' else                         
               "01" when  	rdreq1='1' else
               "00";
              
	compressed_data<= q0 when tx_mux_sel_d="00" else
				q1 when tx_mux_sel_d="01" else
				q2 when tx_mux_sel_d="10" else
				q3;
		  			  
				  
aclr<= aclr0 or aclr1 or aclr2 or aclr3;
tst_aclr_ext<= aclr;


dcmpr :  decompress 
  generic map  (data_width => 32,
                fifo_rsize => 10 )
  port map(
        --input ports 
        wclk          => fifo_rclk,  
        rclk          => fifo_rclk, 
        reset_n       => reset_n, 
        data_in       => compressed_data, 
        data_in_valid => decompr_wr, 
        sample_width  => sample_width,
        rdreq         => decompr_fifo_rd,
        rdempty       => decompr_fifo_empty,
        rdusedw       => open, 
        wfull         => open, 
        wusedw        => decompr_wusedw,
        dataout_valid => open, --decompr_dataout_valid,  
        decmpr_data   => decompr_data
        --output ports       
        );
 
 
-------------------------------------------------------------------------------
--iq sel formation
-------------------------------------------------------------------------------        
process(current_smpl_state, decompr_fifo_empty)begin
	if (current_smpl_state=tx_i and decompr_fifo_empty='0') then
			iq_sel_sig<='1'; 
	else
		  iq_sel_sig<='0';
	end if;	
end process;

-------------------------------------------------------------------------------
--read iq data
-------------------------------------------------------------------------------        
process(current_smpl_state, mimo_en, decompr_fifo_empty) begin
	if ((current_smpl_state=tx_q or (current_smpl_state=tx_i and mimo_en='1')) and decompr_fifo_empty='0' ) then
			decompr_fifo_rd<='1'; 
	else
		  decompr_fifo_rd<='0';
	end if;	
end process;

iq_sel<=iq_sel_sig when fr_start='1' else 
        not iq_sel_sig; 

-------------------------------------------------------------------------------
--iq data mux outputs for DDIO
-------------------------------------------------------------------------------
dd_data_h_s <=iq_sel & decompr_data(11 downto 0) when current_smpl_state=tx_i and mimo_en='0' else 
            iq_sel & decompr_data(27 downto 16) when current_smpl_state=tx_q and mimo_en='0' else
            iq_sel & decompr_data(11 downto 0);

dd_data_l_s <=iq_sel & decompr_data(11 downto 0) when current_smpl_state=tx_i and mimo_en='0' else 
            iq_sel & decompr_data(27 downto 16) when current_smpl_state=tx_q and mimo_en='0' else
            iq_sel & decompr_data(27 downto 16);         
        
dd_data_h<=dd_data_h_s;
dd_data_l<=dd_data_l_s;        
        
-------------------------------------------------------------------------------
--sample formation state machine
-------------------------------------------------------------------------------
smpl_fsm_f : process(fifo_rclk, reset_n) begin
	if(reset_n = '0')then
		current_smpl_state <= idle;
		rd_cnt<=(others=>'0');
	elsif(fifo_rclk'event and fifo_rclk = '1')then
		dd_data_h_r<=dd_data_h_s;
		dd_data_l_r<=dd_data_h_s;
		current_smpl_state <= next_smpl_state;
		if decompr_fifo_rd='1' then 
			rd_cnt<=rd_cnt+1;
			else 
			rd_cnt<=rd_cnt;
		end if;
	end if;	
end process;

smpl_fsm : process(current_smpl_state, decompr_fifo_empty)
begin
  
    next_smpl_state <= current_smpl_state;
    
    case current_smpl_state is

      when idle=>
       if decompr_fifo_empty='0' then
          next_smpl_state<=tx_i;
      else
          next_smpl_state<=idle;
      end if; 
   
      when tx_i=> 
          if decompr_fifo_empty='1' then
              next_smpl_state<=tx_i;           
          else
              next_smpl_state<=tx_q;
          end if;
          
      when tx_q=> 
          if decompr_fifo_empty='1' then
              next_smpl_state<=tx_q;
          else
              next_smpl_state<=tx_i;
          end if;  
      when others => 
        
      end case;
end process;  



-------------------------------------------------------------------------------
--sample test
-------------------------------------------------------------------------------
process(fifo_rclk, reset_n) begin
	if(reset_n = '0')then
		--test_cnt0<=to_unsigned(8, 12);
		--test_cnt1<=to_unsigned(9, 12);
		error_out<='0';
	elsif(fifo_rclk'event and fifo_rclk = '1')then
	 if test_data_out_s=decompr_data then 
	   error_out<='0';
	 else 
	  error_out<='1';
	 end if; 
		if decompr_fifo_rd='1' then 
			--test_cnt0<=test_cnt0+2;
			--test_cnt1<=test_cnt1+2;
			else
			--test_cnt0<=test_cnt0;
			--test_cnt1<=test_cnt1;	
		end if;
	end if;	
end process; 

test_data_out_s<=(others=>'0');--"0000" & std_LOGIC_VECTOR(test_cnt1) & "0000" & std_LOGIC_VECTOR(test_cnt0);
test_data_out<=test_data_out_s;



process(fifo_wclk, reset_n) begin
	if(reset_n = '0')then
		fx3_testcnt<=(others=>'0');
	elsif(fifo_wclk'event and fifo_wclk = '1')then
		if fifo_wrreq='1' then 
			fx3_testcnt<=fx3_testcnt+1;
			else
			fx3_testcnt<=fx3_testcnt;
		end if;
	end if;	
end process; 


test_fx3_cnt<=std_LOGIC_VECTOR(fx3_testcnt); 
error_out_fx3<='0' when  std_LOGIC_VECTOR(fx3_testcnt)=fifo_data else '1'; 

fifo_q<=(others=>'0'); 
        
end arch;   




