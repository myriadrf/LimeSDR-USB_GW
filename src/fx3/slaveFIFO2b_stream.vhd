-- ----------------------------------------------------------------------------	
-- FILE: 	slaveFIFO2b_stream.vhd
-- DESCRIPTION:  FX3 control module, can send and receive data. Infifo  - FX3 to FPGA
--																					 Outfifo - FPGA to FX3 
-- DATE:	May 17, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity slaveFIFO2b_stream is
  generic(
            fpga_infifo_size  : integer:=16; --rusedw bits
            fpga_outfifo_size : integer:=16; --rusedw bits
				
            outfifo_uplimit   : integer:=2048;  -- outfifo_uplimit=2^n, where n - 2...11. 
            infifo_lowlimit   : integer:=2048	-- ensure that infifo free space will be wusedw-infifo_lowlimit>2048
            );
	port(
		reset_n 		: in std_logic;                          --input reset active low
		clk_100		: in std_logic;
		
		pclk  : out std_logic;  --on top level has to be implemented DDR output cel with 180phase shift
		slcs 	: out std_logic;                               --output chip select
		fdata : inout std_logic_vector(15 downto 0);         
		faddr : out std_logic_vector(1 downto 0);            --output fifo address
		slrd	: out std_logic;                               --output read select
		sloe	: out std_logic;                               --output output enable select
		slwr	: out std_logic;                               --output write select
                    
		flaga	: in std_logic;                                
		flagb	: in std_logic;
		flagc	: in std_logic;
		flagd	: in std_logic;

		pktend	     : out std_logic;                       --output pkt end 
		PMODE	   	  : out std_logic_vector(1 downto 0);
		RESET	   	  : out std_logic;
		state_ind	  : out std_logic_vector(3 downto 0);
		--outfifo signals (FPGA->FX3)
		outfifo_aclr    : in std_logic;
		outfifo_wclk    : in std_logic;
		outfifo_write	 : in std_logic;
		outfifo_wfull	 : out std_logic;
		outfifo_data    : in std_logic_vector(15 downto 0);
		outfifo_wrusedw : out std_logic_vector(fpga_outfifo_size-1 downto 0);
		--infifo signals (FX3->FPGA)
		infifo_rclk     : in std_logic;
		infifo_read     : in std_logic;
		infifo_q        : out std_logic_vector(31 downto 0);
		infifo_rdempty  : out std_logic;
		buffer_rdy		 : in std_logic;
		fifwr_cnt_out	 : out std_logic_vector(15 downto 0);
		outfifo_rempty	 : out std_logic;
		wr_cnt_all		 : out std_logic_vector(fpga_outfifo_size-1 downto 0);
		stream_load		 : in std_logic;
		stream_load_o	 : out std_logic;
		infifo_rdusedw	 : out std_logic_vector(fpga_infifo_size-2 downto 0);
		tx_outfifo_rdy	 : in std_logic;
		tx_outfifo_wrreq : out std_logic;
		tx_outfifo_data	: out std_logic_vector(15 downto 0)
	    );
end entity slaveFIFO2b_stream;

architecture slaveFIFO2b_stream_arch of slaveFIFO2b_stream is
 

--stream fsm
type stream_states is (idle, stream_in_idle, stream_out_idle, stream_in_wait_flagb, stream_in_write, stream_in_pktend, stream_in_write_wr_delay, stream_out_flagc_rcvd, stream_out_wait_flagd, stream_out_read, stream_out_read_rd_and_oe_delay, stream_out_read_oe_delay);
signal current_stream_state, next_stream_state : stream_states;

type detect_states is (idle, detecting, done);
signal current_detect_state, next_detect_state : detect_states;
signal rd_oe_delay_cnt     : unsigned(1 downto 0);
signal oe_delay_cnt        : unsigned(1 downto 0);
signal data_in_stream_out  : std_logic_vector(15 downto 0);
signal slrd_streamOUT_n    : std_logic;
signal sloe_streamOUT_n    : std_logic;
signal flaga_d             : std_logic;
signal flagb_d             : std_logic;
signal flagc_d             : std_logic;
signal flagd_d             : std_logic;
signal lock                : std_logic;
signal delay1_slrd			: std_logic;
signal delay2_slrd			: std_logic;
signal wr_cnt              : unsigned(14 downto 0);
signal reset_p             : std_logic;
signal fifordreq           : std_logic;
signal fifowrreq           : std_logic;
signal FIFOq               : std_logic_vector(15 downto 0);
signal fifordempty         : std_logic;
signal fifordusedw         : std_logic_vector(fpga_outfifo_size-1 downto 0);
signal fifordusedw_u       : unsigned(fpga_outfifo_size-1 downto 0);
signal outfifo_ready       : std_logic;
signal slwr_streamIN_n     : std_logic; 
signal slwr_streamIN_n_d   : std_logic;
signal infifo_write 	      : std_logic;					--delayed  slwr (2 cyclces)
signal infifo_wusedw       : std_logic_vector(fpga_infifo_size-1 downto 0);
signal infifo_rempty       : std_logic;
signal infifo_starving     : std_logic;
signal streamOUT_fdata 		: std_logic_vector(15 downto 0);
signal outfifo_wrusedw_int	: std_logic_vector(fpga_outfifo_size-1 downto 0);
signal outfifo_wfull_sig	: std_logic;
signal outfifo_wrusedw_u   : unsigned(fpga_outfifo_size-1 downto 0);
signal stream_in_write_cnt	: unsigned(15 downto 0);
signal fifwr_cnt				: unsigned(15 downto 0);
signal pktend_d				: std_logic;
signal pktend_n				: std_logic;
signal stream_in_wr_cnt_all : unsigned(fpga_outfifo_size-1 downto 0);
signal sl_data					: std_logic_vector(15 downto 0);
signal sl_write				: std_logic;
signal delay3_slrd			: std_logic;
signal buffer_rdy_d0			: std_logic;
signal buffer_rdy_d1			: std_logic;
signal buffer_size			: unsigned(fpga_outfifo_size-1 downto 0);


-- ----------------------------------------------------------------------------
-- FIFO
-- ----------------------------------------------------------------------------	
component fpga_infifo IS --(FX3->FPGA)	
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
		rdusedw	: OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
		wrfull	: OUT STD_LOGIC ;
		wrusedw	: OUT STD_LOGIC_VECTOR (13 DOWNTO 0)
	);
END component;


component fpga_outfifo IS --(FPGA->FX3)
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdempty	: OUT STD_LOGIC ;
		rdusedw	: OUT STD_LOGIC_VECTOR (14 DOWNTO 0);
		wrfull	: OUT STD_LOGIC ;
		wrusedw	: OUT STD_LOGIC_VECTOR (14 DOWNTO 0)
	);
END component;


component sl_ctrl is
port(
	clk 	: in std_logic;
	rstn	: in std_logic;
	wrreq	: in std_logic;
	stream_load	: in std_logic;
	data		: in std_logic_vector(15 downto 0);
	wrusedw		: in std_logic_vector(13 downto 0);
	
	str_load_o  : out std_logic;
	wrreq_o		: out std_logic;
	data_o		: out std_logic_vector(15 downto 0)
);
end component;

 
begin  -- architecture begin

pktend<=pktend_d;
wr_cnt_all<=std_logic_vector(stream_in_wr_cnt_all);


fifwr_cnt_out<=std_logic_vector(fifwr_cnt);
outfifo_wrusedw<=outfifo_wrusedw_int;


reset_p<=not reset_n;
pclk<=clk_100;

tx_outfifo_wrreq<=infifo_write;
 
--FPGAOUT fifo (FX3->FPGA) write signal 
infifo_write<=not slrd_streamOUT_n when slrd_streamOUT_n='1' else 
				not delay3_slrd;

				--delay2_slrd
				
tx_outfifo_data<=fdata;				
--for testing 
state_ind<=x"0" when current_stream_state=idle else 
			x"1"			when current_stream_state=stream_in_idle else 
			x"2"			when current_stream_state=stream_out_idle else 
			x"3"			when current_stream_state=stream_in_wait_flagb else 
			x"4"			when current_stream_state=stream_in_write else 
			x"5"			when current_stream_state=stream_in_write_wr_delay else
			x"6"			when current_stream_state=stream_out_flagc_rcvd else
			x"7"			when current_stream_state=stream_out_wait_flagd else
			x"8"			when current_stream_state=stream_out_read else
			x"9"			when current_stream_state=stream_out_read_rd_and_oe_delay else
			x"A"			when current_stream_state=stream_out_read_oe_delay else
			x"F";  

--output signal asignments
slrd   <= slrd_streamOUT_n;
slwr   <= slwr_streamIN_n_d;   
sloe   <= sloe_streamOUT_n;
PMODE  <= "11";		
RESET  <= '1';	
slcs   <= '0';

   
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


--to delay slwr_streamIN_n signal 
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
	
--Count write operations to outfifo
	process(outfifo_wclk, reset_n)
	begin
		if(reset_n = '0') then
			fifwr_cnt <= (others=>'0');
		elsif(outfifo_wclk'event and outfifo_wclk = '1') then
			buffer_rdy_d0<=buffer_rdy;
			buffer_rdy_d1<=buffer_rdy_d0;
				if buffer_rdy_d1='0' then 
					if outfifo_write='1' then 
						fifwr_cnt<=fifwr_cnt+1;
					end if;
				else
					fifwr_cnt <= (others=>'0');
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
stream_out_fsm : process(current_stream_state, flaga_d, flagb_d, flagc_d, flagd_d, rd_oe_delay_cnt, oe_delay_cnt, infifo_starving, outfifo_ready, stream_in_write_cnt) begin
	next_stream_state <= current_stream_state;
	case current_stream_state is
	  

		when idle => --idle state (modified)
			if infifo_starving='1' and flagc_d = '1' then 
				next_stream_state<=stream_out_flagc_rcvd;
				--next_stream_state<=stream_out_wait_flagd;
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

			if(flagb_d = '0')then
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


	-- FPGA OUTFIFO instantiation, (FPGA->FX3)	
	outfifo_inst : fpga_outfifo port map (
		aclr		=> outfifo_aclr,
		data		=> outfifo_data,
		rdclk		=> clk_100,
		rdreq		=> fifordreq,
		wrclk		=> outfifo_wclk, --fifowrclk,
		wrreq		=> outfifo_write,
		q			=> FIFOq,
		rdempty	=> fifordempty,
		rdusedw	=> fifordusedw,
		wrfull	=> outfifo_wfull_sig,
		wrusedw	=> outfifo_wrusedw_int
	);
	
	-- FPGA INFIFO instantiation, (FX3->FPGA)	
	infifo_inst : fpga_infifo port map (
		aclr		=> reset_p,
		data		=> sl_data,
		rdclk		=> infifo_rclk,
		rdreq		=> infifo_read,
		wrclk		=> clk_100,
		wrreq		=> sl_write,
		q			=> infifo_q,
		rdempty	=> infifo_rdempty,
		rdusedw	=> infifo_rdusedw,
		wrfull	=> open,
		wrusedw	=> infifo_wusedw
	);
	
     

sl_inst : sl_ctrl 
port map (
	clk 				=> clk_100,
	rstn				=> reset_n,
	wrreq				=> infifo_write,
	stream_load		=> stream_load,
	data				=> streamOUT_fdata, 
	wrusedw			=> infifo_wusedw, 
	
	str_load_o  => stream_load_o,
	wrreq_o		=> sl_write,
	data_o		=> sl_data
);
 

--delay slrd signal because we want to meet timing FPGAINFIFO (FX3->FPGA). 
	process(clk_100, reset_n) begin
	 if reset_n='0' then			
			delay1_slrd<='0';
			delay2_slrd<='0';
	 elsif rising_edge(clk_100) then 
			delay1_slrd<=slrd_streamOUT_n;
			delay2_slrd<=delay1_slrd;
			delay3_slrd<=delay2_slrd;
	 end if;
  end process;
  
  outfifo_rempty<=fifordempty;
  
  fifordusedw_u<=unsigned(fifordusedw);
  fdata	<= (others=>'Z')	when sloe_streamOUT_n='0' else FIFOq;
  faddr  <= "11" when sloe_streamOUT_n='0' else "00";
  
  outfifo_ready		<='1' when fifordusedw_u >= outfifo_uplimit else '0';
  --infifo_starving		<='1' when infifo_wusedw < infifo_lowlimit_std else '0';
  infifo_starving		<=tx_outfifo_rdy;
  outfifo_wrusedw_u	<=unsigned(outfifo_wrusedw_int);
  outfifo_wfull		<='1' when (outfifo_wrusedw_u>=x"7FFD" or outfifo_wfull_sig='1') else '0';
  streamOUT_fdata		<=fdata;


end architecture;

