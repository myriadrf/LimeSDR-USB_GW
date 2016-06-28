
-- ----------------------------------------------------------------------------	
-- FILE: 	FX3_slaveFIFO2a_16bus.vhd
-- DESCRIPTION:  FX3 control module, can send and receive data. Infifo  - FX3 to FPGA
--																					 Outfifo - FPGA to FX3 
-- DATE:	May 17, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

entity FX3_slaveFIFO2a_16bus is
  generic(	dev_family				: string := "Cyclone IV E";
            fpga_infifo_size   	: integer:=16; 		--wusedw bits
				fpga_infifo_wwords 	: integer:=16384;	--write size words capacity of fifo
            fpga_outfifo_size  	: integer:=16; 		--rusedw bits
				fx3_bus_width		 	: integer:=16; 
				
            outfifo_uplimit   	: integer:=2048;  -- outfifo_uplimit in outfifo rdusedw words, has to be 4096 bytes. 
																--(Eg. outfifo rdside is 32b then outfifo_uplimit=1024) 
            infifo_lowlimit   	: integer:=2048	-- ensure that infifo free space will be wusedw-infifo_lowlimit>2048
            );
	port(
		clk_100				: in std_logic;
		reset_n 				: in std_logic;                          --input reset active low
		--fx3 controll signals
		pclk  				: out std_logic_vector(0 downto 0);  		--DDR output cel with 180phase shift
		slcs 					: out std_logic;                               --output chip select
		fdata 				: inout std_logic_vector(fx3_bus_width-1 downto 0);         
		faddr 				: out std_logic_vector(1 downto 0);            --output fifo address
		slrd					: out std_logic;                               --output read select
		sloe					: out std_logic;                               --output output enable select
		slwr					: out std_logic;                               --output write select
      --fx3 flags              
		flaga					: in std_logic;                                
		flagb					: in std_logic;
		flagc					: in std_logic;
		flagd					: in std_logic;
		-- fx3 other
		pktend	     		: out std_logic;                       --output pkt end 
		PMODE	   	  		: out std_logic_vector(1 downto 0);
		RESET	   	  		: out std_logic;		
		--outfifo signals (FPGA->FX3)
		outfifo_data   	: in std_logic_vector(fx3_bus_width-1 downto 0);
		outfifo_rdreq		: out std_logic;
		outfifo_rdusedw	: in std_logic_vector(fpga_outfifo_size-1 downto 0);
		--incomming data signals (FX3->FPGA)
		in_dest_sel			: in std_logic; -- 1 - FX3 writes to infifo, 0 - FX3 writes to external buffer
		in_data				: out std_logic_vector(fx3_bus_width-1 downto 0); --data from FX3 to FPGA		
		--infifo signals (FX3->FPGA)
		infifo_wrreq		: out std_logic;
		infifo_wrusedw		: in std_logic_vector(fpga_infifo_size-1 downto 0);
		infifo_rdy			: in std_logic;
		--in buffer signals (FX3->FPGA)
		in_buffer_rdy		: in std_logic; -- ensure that in_buffer_rdy is asserted only when buffer can accept more than infifo_lowlimit words.
		in_buffer_wrreq	: out std_logic;
		stream_in_write_cnt_out	: out std_logic_vector(15 downto 0)
	    );
end entity FX3_slaveFIFO2a_16bus;

architecture FX3_slaveFIFO2a_16bus_arch of FX3_slaveFIFO2a_16bus is
 

--stream fsm
type stream_states is (idle, stream_in_idle, stream_out_idle, stream_in_wait_flagb, stream_in_write, 
								stream_in_pktend, stream_in_write_wr_delay, stream_out_flagc_rcvd, stream_out_wait_flagd, 
								stream_out_read, stream_out_read_rd_and_oe_delay, stream_out_read_oe_delay);
								
signal current_stream_state, next_stream_state : stream_states;

type detect_states is (idle, detecting, done);
signal current_detect_state, next_detect_state : detect_states;
signal rd_oe_delay_cnt     : unsigned(1 downto 0);
signal oe_delay_cnt        : unsigned(1 downto 0);
signal slrd_streamOUT_n    : std_logic;
signal sloe_streamOUT_n    : std_logic;
signal flaga_d             : std_logic;
signal flagb_d             : std_logic;
signal flagc_d             : std_logic;
signal flagd_d             : std_logic;
signal delay1_slrd			: std_logic;
signal delay2_slrd			: std_logic;
signal delay3_slrd			: std_logic;
signal fifordreq           : std_logic;
signal outfifo_ready       : std_logic;
signal infifo_ready			: std_logic;
signal slwr_streamIN_n     : std_logic; 
signal slwr_streamIN_n_d   : std_logic;
signal infifo_write 	      : std_logic;					--delayed  slwr (2 cyclces)
signal infifo_starving     : std_logic;
signal pktend_d				: std_logic;
signal pktend_n				: std_logic;

--
signal stream_in_write_cnt	: unsigned(15 downto 0);
signal stream_in_wr_cnt_all : unsigned(fpga_outfifo_size-1 downto 0);
signal buffer_size			: unsigned(fpga_outfifo_size-1 downto 0);




 
begin  -- architecture begin



	ALTDDIO_OUT_component : ALTDDIO_OUT
	GENERIC MAP (
		extend_oe_disable 		=> "OFF",
		intended_device_family 	=> dev_family,
		invert_output 				=> "OFF",
		lpm_hint 					=> "UNUSED",
		lpm_type 					=> "altddio_out",
		oe_reg 						=> "UNREGISTERED",
		power_up_high 				=> "OFF",
		width 						=> 1
	)
	PORT MAP (
		datain_h => "0",
		datain_l => "1",
		outclock => clk_100,
		dataout 	=> pclk
	);


stream_in_write_cnt_out<=std_logic_vector(stream_in_write_cnt);
  
--OUTPUT read control signals generation
process(current_stream_state)begin
	if((current_stream_state = stream_out_read) or (current_stream_state = stream_out_read_rd_and_oe_delay))then
			slrd_streamOUT_n <= '0'; 
	else
		  slrd_streamOUT_n <= '1';
	end if;	
end process;	

--OUTPUT read oe control signals generation
process(current_stream_state)begin
	if((current_stream_state = stream_out_read) or (current_stream_state = stream_out_read_rd_and_oe_delay) or (current_stream_state = stream_out_read_oe_delay)) then
		sloe_streamOUT_n <= '0';
	else
	 	sloe_streamOUT_n <= '1';
	end if;
end process;

--FPGAOUT fifo read control
process(current_stream_state)begin
	if(current_stream_state = stream_in_write or current_stream_state = stream_in_pktend) then
		fifordreq <= '1';
		slwr_streamIN_n <= '0';
	else
	 	fifordreq <= '0';
	 	slwr_streamIN_n <= '1';
	end if;
end process;

--FX3 pktend control
process(current_stream_state)begin
	if(current_stream_state = stream_in_pktend) then
		pktend_n <= '0';
	else
		pktend_n <= '1';
	end if;
end process;

--to delay slwr_streamIN_n and pktend_d signal 
	process(clk_100, reset_n)
	begin
		if(reset_n = '0') then
			slwr_streamIN_n_d <= '1';
			pktend_d<='1';
		elsif(clk_100'event and clk_100 = '1') then
			slwr_streamIN_n_d <= slwr_streamIN_n;
			pktend_d<=pktend_n;
		end if;	 
	end process;

--flopping the INPUTs flags
process(clk_100, reset_n)begin
	if(reset_n = '0')then 
		flaga_d <= '0';
		flagb_d <= '0';
		flagc_d <= '0';
		flagd_d <= '0';
	elsif(clk_100'event and clk_100 = '1')then
		flaga_d <= flaga;
		flagb_d <= flagb;
		flagc_d <= flagc;
		flagd_d <= flagd;
	end if;	
end process;

--counter to delay the read and output enable signal
process(clk_100, reset_n)begin
	if(reset_n = '0')then 
		rd_oe_delay_cnt <= "00";
	elsif(clk_100'event and clk_100 = '1')then	
	 	if(current_stream_state = stream_out_read) then
			rd_oe_delay_cnt <= "01";
        	elsif((current_stream_state = stream_out_read_rd_and_oe_delay) and (rd_oe_delay_cnt > 0))then
			rd_oe_delay_cnt <= rd_oe_delay_cnt - 1;
		else
			rd_oe_delay_cnt <= rd_oe_delay_cnt;
		end if;
	end if;
end process;

--Counter to delay the OUTPUT Enable(oe) signal
process(clk_100, reset_n)begin
	if(reset_n = '0')then 
		oe_delay_cnt <= "00";
	elsif(clk_100'event and clk_100 = '1')then	
	 	if(current_stream_state = stream_out_read_rd_and_oe_delay) then
			oe_delay_cnt <= "10";
        	elsif((current_stream_state = stream_out_read_oe_delay) and (oe_delay_cnt > 0))then
			oe_delay_cnt <= oe_delay_cnt - 1;
		else
			oe_delay_cnt <= oe_delay_cnt;
		end if;
	end if;
end process;

--Count write operations
	process(clk_100, reset_n)
	begin
		if(reset_n = '0') then
			stream_in_write_cnt <= (others=>'0');
			stream_in_wr_cnt_all<=(others=>'0');
		elsif(clk_100'event and clk_100 = '1') then
				if current_stream_state=stream_in_write then 
					stream_in_write_cnt<=stream_in_write_cnt+1;
				else
					stream_in_write_cnt <= (others=>'0');
				end if;	
					if fifordreq='1' then 
						stream_in_wr_cnt_all<=stream_in_wr_cnt_all+1;
					else
						stream_in_wr_cnt_all<=stream_in_wr_cnt_all;
					end if;
		end if;	 
	end process;
		
	
-- state machine for determing FX3 buffer size, which depends on which port is used (USB2 or USB3)
fx3_fsm_f : process(clk_100, reset_n)begin
	if(reset_n = '0')then
		current_detect_state<= idle;
		buffer_size<=to_unsigned(outfifo_uplimit, buffer_size'length);
	elsif(clk_100'event and clk_100 = '1')then 
		 case current_detect_state is
			when idle =>
				buffer_size<=to_unsigned(outfifo_uplimit, buffer_size'length);
				if flaga_d = '1' then 
					current_detect_state<=detecting;
				else
					current_detect_state<=idle;
				end if;
			when detecting=> 
				
				if current_stream_state=stream_in_write_wr_delay then 
					current_detect_state<=done;
					buffer_size<=stream_in_wr_cnt_all;
				else
					buffer_size<=to_unsigned(outfifo_uplimit, buffer_size'length);
					current_detect_state<=detecting;
				end if;
			when done => 
				buffer_size<=buffer_size;
				current_detect_state<=done;
			when others => 
		end case;
			
	end if;	
end process;
	

--stream state machine
stream_out_fsm_f : process(clk_100, reset_n)begin
	if(reset_n = '0')then
		current_stream_state <= idle;
	elsif(clk_100'event and clk_100 = '1')then 
		current_stream_state <= next_stream_state;
	end if;	
end process;

--steam state machine combo
stream_out_fsm : process (	current_stream_state, flaga_d, flagb_d, flagc_d, flagd_d, rd_oe_delay_cnt, 
									oe_delay_cnt, infifo_starving, outfifo_ready, stream_in_write_cnt) begin
	next_stream_state <= current_stream_state;
	case current_stream_state is
	  
		when idle => --idle state (modified)
			if infifo_starving='1' and flagc_d = '1' then 
				next_stream_state<=stream_out_flagc_rcvd;
			elsif outfifo_ready='1' and flaga_d = '1' then 
				next_stream_state<=stream_in_wait_flagb; 
			else
				next_stream_state<=idle;
			end if;
			
		when stream_out_flagc_rcvd =>
				next_stream_state <= stream_out_wait_flagd;

		when stream_out_wait_flagd => 										-- wait for flagd (modified)
			if(flagd_d = '1') then
				next_stream_state <= stream_out_read;
			elsif outfifo_ready='1' and flaga_d='1' then 
				next_stream_state <= stream_in_wait_flagb;
			else 
				next_stream_state <= stream_out_wait_flagd;
			end if;
		
		when stream_out_read => 												--begin reading from fx3
			if (flagd_d = '0')then
				next_stream_state <= stream_out_read_rd_and_oe_delay;
		  else
				next_stream_state <= stream_out_read;
		  end if;
			
		when stream_out_read_rd_and_oe_delay =>							--finish reading with delay
			if(rd_oe_delay_cnt = "00")then
				next_stream_state <= stream_out_read_oe_delay;
			else
				next_stream_state <= stream_out_read_rd_and_oe_delay;
			end if;
		
		when stream_out_read_oe_delay => 									--finish reading with delay
			if(oe_delay_cnt = "00")then
				next_stream_state <= idle;
			else
				next_stream_state <= stream_out_read_oe_delay;
			end if;
		
		when  stream_in_wait_flagb => 										--wait for flag b (modified)
			if (flagb_d = '1') then
				next_stream_state <=  stream_in_write;
			elsif infifo_starving='1' and flagc_d='1' then 
				next_stream_state <= stream_out_wait_flagd;
			else 
				next_stream_state<=stream_in_wait_flagb;
			end if;
		          
		when stream_in_write =>  												--begin writing to fx3
			--if stream_in_write_cnt>=(outfifo_uplimit-2) or outfifo_aclr='1' then
--			if stream_in_write_cnt>=(buffer_size-2) or outfifo_aclr='1' then 			
--				next_stream_state <= stream_in_pktend;
--			elsif(flagb_d = '0')then
--				next_stream_state <= stream_in_write_wr_delay;
--			else 
--				next_stream_state <= stream_in_write;
--			end if;	

			if(flagb_d = '0')then														 --original line
			--if(flagb_d = '0' or stream_in_write_cnt=outfifo_uplimit-1 )then --temporaty fix
				next_stream_state <= stream_in_write_wr_delay;
			else 
				next_stream_state <= stream_in_write;
			end if;

		when stream_in_pktend => 												--finish writing with pktend	
			next_stream_state <=idle;
		    
		when stream_in_write_wr_delay => 									--finish writing to fx3 with delay 
			next_stream_state <=idle;
  
		when others =>
			next_stream_state <= idle;
		
  end case;
end process;


--delay slrd signal because we want to meet timing FPGAINFIFO (FX3->FPGA). 
	process(clk_100, reset_n) begin
	 if reset_n='0' then			
			delay1_slrd<='0';
			delay2_slrd<='0';
			delay3_slrd<='0';
	 elsif rising_edge(clk_100) then 
			delay1_slrd<=slrd_streamOUT_n;
			delay2_slrd<=delay1_slrd;
			delay3_slrd<=delay2_slrd;
	 end if;
  end process;
  
  


  --comb internal signals
	outfifo_ready			<= '1' when unsigned(outfifo_rdusedw) >= outfifo_uplimit else '0';
	infifo_ready			<= '1' when unsigned(infifo_wrusedw) < (fpga_infifo_wwords - infifo_lowlimit) and infifo_rdy='1' else '0';
	infifo_starving		<= infifo_ready when in_dest_sel='1' else 
								in_buffer_rdy;
	infifo_write <= not slrd_streamOUT_n when slrd_streamOUT_n='1' else 
						 not delay3_slrd;

	infifo_wrreq	 	<= infifo_write when  in_dest_sel='1' else '0';
	in_buffer_wrreq 	<= infifo_write when  in_dest_sel='0' else '0';
	in_data				<= fdata;
  
	outfifo_rdreq<=fifordreq;
  
  --in fifo (FX3->FPGA) write signal 

				
--fx3 output signal asignments
	slrd   <= slrd_streamOUT_n;
	slwr   <= slwr_streamIN_n_d;   
	sloe   <= sloe_streamOUT_n;
	PMODE  <= "11";		
	RESET  <= '1';	
	slcs   <= '0';
	pktend <= pktend_d;
	fdata	<= (others=>'Z')	when sloe_streamOUT_n='0' else outfifo_data;
	faddr  <= "11" when sloe_streamOUT_n='0' else "00";

end architecture;

