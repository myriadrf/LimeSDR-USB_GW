-- ----------------------------------------------------------------------------	
-- FILE: 	slaveFIFO5b.vhd
-- DESCRIPTION:	Slave FIFO interface in 5bit addres mode for USB3.0 device (CYUSB301X)
-- DATE:	Oct 07, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity slaveFIFO5b is
	generic (num_of_sockets 		: integer := 1;
				data_width				: integer := 32;								--when data_width is changed to 16b, socketx_wrusedw_size and 
																								--socketx_rdusedw_size has to be doubled to maintain same size
				data_dma_size			: integer := 1024;							--data endpoint dma size in bytes
				control_dma_size		: integer := 1024;							--control endpoint dma size in bytes
				data_pct_size			: integer := 1024;							--packet size in bytes
				control_pct_size		: integer := 64;								--packet size in bytes, should be less then max dma size
				socket0_wrusedw_size : integer := 11;
				socket0_rdusedw_size	: integer := 10;
				socket1_wrusedw_size : integer := 11;
				socket1_rdusedw_size	: integer := 10;
				socket2_wrusedw_size : integer := 11;
				socket2_rdusedw_size	: integer := 10;
				socket3_wrusedw_size : integer := 11;
				socket3_rdusedw_size	: integer := 10
				);
	port(
		reset_n 					: in std_logic;									--input reset active low
		clk	   				: in std_logic;									--input clk 100 Mhz  
		clk_out	   			: out std_logic;									--output clk 100 Mhz 
		usb_speed 				: in std_logic;									--USB3.0 - 1, USB2.0 - 0
		slcs 	   				: out std_logic;									--output chip select
		fdata      				: inout std_logic_vector(data_width-1 downto 0);         
		faddr      				: out std_logic_vector(4 downto 0);			--output fifo address
		slrd	   				: out std_logic;									--output read select
		sloe	   				: out std_logic;									--output output enable select
		slwr	   				: out std_logic;									--output write select
                    
      flaga	   				: in std_logic;                                
		flagb	   				: in std_logic;
      flagc	   				: in std_logic;									--Not used in 5bit addres mode
      flagd	   				: in std_logic;									--Not used in 5bit addres mode

		pktend	   			: out std_logic;									--output pkt end 
		EPSWITCH					: out std_logic;
		
		--socket 0 (configured to read data from it PC->FPGA)
      socket0_fifo_reset_n    : in std_logic;
		socket0_fifo_data			: out std_logic_vector(data_width-1 downto 0);
		socket0_fifo_q				: in std_logic_vector(data_width-1 downto 0);
		socket0_fifo_wrusedw		: in std_logic_vector(socket0_wrusedw_size-1 downto 0);
		socket0_fifo_rdusedw		: in std_logic_vector(socket0_rdusedw_size-1 downto 0);
		socket0_fifo_wr			: out std_logic;
		socket0_fifo_rd			: out std_logic;

		--socket 1 (configured to read control data from it PC->FPGA)
      socket1_fifo_reset_n    : in std_logic;
		socket1_fifo_data			: out std_logic_vector(data_width-1 downto 0);
		socket1_fifo_q				: in std_logic_vector(data_width-1 downto 0);
		socket1_fifo_wrusedw		: in std_logic_vector(socket1_wrusedw_size-1 downto 0);
		socket1_fifo_rdusedw		: in std_logic_vector(socket1_rdusedw_size-1 downto 0);
		socket1_fifo_wr			: out std_logic;
		socket1_fifo_rd			: out std_logic;

		--socket 2 (configured to write data to it FPGA->PC)
		socket2_fifo_data			: out std_logic_vector(data_width-1 downto 0);
		socket2_fifo_q				: in std_logic_vector(data_width-1 downto 0);
		socket2_fifo_wrusedw		: in std_logic_vector(socket2_wrusedw_size-1 downto 0);
		socket2_fifo_rdusedw		: in std_logic_vector(socket2_rdusedw_size-1 downto 0);
		socket2_fifo_wr			: out std_logic;
		socket2_fifo_rd			: out std_logic;

		--socket 3 (configured to write control data to it FPGA->PC)
		socket3_fifo_data			: out std_logic_vector(data_width-1 downto 0);
		socket3_fifo_q				: in std_logic_vector(data_width-1 downto 0);
		socket3_fifo_wrusedw		: in std_logic_vector(socket3_wrusedw_size-1 downto 0);
		socket3_fifo_rdusedw		: in std_logic_vector(socket3_rdusedw_size-1 downto 0);
		socket3_fifo_wr			: out std_logic;
		socket3_fifo_rd			: out std_logic;
		GPIF_busy					: out std_logic

	    );

end entity slaveFIFO5b;

architecture arch of slaveFIFO5b is

--stream IN fsm
type states is (idle, prep_thread_addr, wait_DMA_rdy, wait_flg_latency, 
					 prep_socket_addr, wait_socket_delay, prep_wr_addr, assert_epswitch, 
					 wait_valid_flag, wait_flagA, wait_flagB, stream_out_read, stream_in_idle, 
					 stream_in_wait_flagb, stream_in_write, stream_in_pktend, stream_in_write_wr_delay, stream_out_read_rd_and_oe_delay,
					 stream_out_read_oe_delay);
					 
signal current_state, next_state : states;

signal stream_in_cnt			 : unsigned(31 downto 0);

signal slwr_streamIN_n     : std_logic;
signal slwr_streamIN_n_d   : std_logic;
signal slrd_streamOUT_n		: std_logic;
signal slrd_streamOUT_n_d	: std_logic;
signal slrd_streamOUT_n_d1	: std_logic;
signal pktend_streamIN_n	: std_logic;
signal flaga_d             : std_logic;
signal flagb_d             : std_logic;
signal flagc_d             : std_logic;
signal flagd_d             : std_logic;
signal sloe_stream_n			: std_logic;



type socket_array is array (0 to 7) of std_logic_vector(2 downto 0);
type thread_array is array (0 to 3) of std_logic_vector(1 downto 0);

signal socket_array_thread0	: socket_array;
signal socket_array_thread1	: socket_array;
signal socket_array_thread2	: socket_array;
signal socket_array_thread3	: socket_array;

signal array_of_threads			: thread_array;

signal thread_addr_cnt	: unsigned(1 downto 0);
signal thread_addr_reg	: std_logic_vector(1 downto 0);
signal socket_addr_cnt	: unsigned (2 downto 0);
signal socket_addr_reg	: std_logic_vector(2 downto 0);
signal wait_flagA_cnt	: unsigned (7 downto 0);
signal assert_cnt			: unsigned (7 downto 0);

signal ddr_clk_out		: std_logic_vector(0 downto 0);

signal flg_latency_cnt	: unsigned(4 downto 0);

signal faddr_reg  : std_logic_vector(4 downto 0);

signal thread0_socket_reg	: std_logic_vector(2 downto 0);
signal thread1_socket_reg	: std_logic_vector(2 downto 0);
signal thread2_socket_reg	: std_logic_vector(2 downto 0);
signal thread3_socket_reg	: std_logic_vector(2 downto 0);
signal rd_wr					: std_logic_vector(31 downto 0);
signal socket_type			: std_logic_vector(31 downto 0);
signal socket_fifo_wr		: std_logic;
signal socket_fifo_rd		: std_logic;
signal socket_fifo_rdy		: std_logic_vector(31 downto 0);
signal socket_fifo_q			: std_logic_vector(data_width-1 downto 0);

signal socket0_fifo_rdy				: std_logic;
signal socket0_max_wrwords			: unsigned(socket0_wrusedw_size-1 downto 0);
signal socket0_fifo_reserve		: unsigned(socket0_wrusedw_size-1 downto 0);
signal socket0_fifo_wr_watermark	: unsigned(socket0_wrusedw_size-1 downto 0);
signal socket0_fifo_rd_watermark	: unsigned(socket0_rdusedw_size-1 downto 0);

signal socket1_fifo_rdy				: std_logic;
signal socket1_max_wrwords			: unsigned(socket1_wrusedw_size-1 downto 0);
signal socket1_fifo_reserve		: unsigned(socket1_wrusedw_size-1 downto 0);
signal socket1_fifo_wr_watermark	: unsigned(socket1_wrusedw_size-1 downto 0);
signal socket1_fifo_rd_watermark	: unsigned(socket1_rdusedw_size-1 downto 0);

signal socket2_fifo_rdy				: std_logic;
signal socket2_max_wrwords			: unsigned(socket2_wrusedw_size-1 downto 0);
signal socket2_fifo_reserve		: unsigned(socket2_wrusedw_size-1 downto 0);
signal socket2_fifo_wr_watermark	: unsigned(socket2_wrusedw_size-1 downto 0);
signal socket2_fifo_rd_watermark	: unsigned(socket2_rdusedw_size-1 downto 0);

signal socket3_fifo_rdy				: std_logic;
signal socket3_max_wrwords			: unsigned(socket3_wrusedw_size-1 downto 0);
signal socket3_fifo_reserve		: unsigned(socket3_wrusedw_size-1 downto 0);
signal socket3_fifo_wr_watermark	: unsigned(socket3_wrusedw_size-1 downto 0);
signal socket3_fifo_rd_watermark	: unsigned(socket3_rdusedw_size-1 downto 0);

signal rd_oe_delay_cnt     : unsigned(1 downto 0);
signal oe_delay_cnt        : unsigned(1 downto 0);

signal slrd_cnt				: unsigned(15 downto 0);
signal slwr_cnt				: unsigned(15 downto 0);

attribute noprune: boolean;
attribute noprune of slrd_cnt: signal is true;
attribute noprune of slwr_cnt: signal is true;

signal max_control_pct_cnt		: unsigned(15 downto 0);
signal max_data_pct_cnt			: unsigned(15 downto 0);

attribute noprune of max_data_pct_cnt: signal is true;

constant USB2DIV				: integer := 1024/512;

begin --architecture begining

--Physical sockets accesing order
socket_array_thread0	<= ("000", "100", "001", "101", "010", "110","011", "111");
socket_array_thread1	<= ("000", "100", "001", "101", "010", "110","011", "111");
socket_array_thread2	<= ("000", "100", "001", "101", "010", "110","011", "111");
socket_array_thread3	<= ("000", "100", "001", "101", "010", "110","011", "111");
--Threads accesing order
array_of_threads		<= ("00", "01", "10", "11");
--Define to which of logical sockets write operation (PC->FPGA)can be issued. (with logical '1')
rd_wr<="00000000000000000000000000001100";
--Define which of logical sockets are for control. (with logical '1')
socket_type<="00000000000000000000000000001010";


--to determine socket0 watermarks and when socket is ready
socket0_max_wrwords			<=((socket0_wrusedw_size-1)=>'1', others=>'0');

socket0_fifo_reserve 		<= to_unsigned((data_pct_size*8)/data_width,socket0_fifo_reserve'length) when (socket_type(0)='0' and usb_speed='1') else
										to_unsigned((data_pct_size*8)/data_width/USB2DIV,socket0_fifo_reserve'length) when (socket_type(0)='0' and usb_speed='0') else
										to_unsigned((control_pct_size*8)/data_width,socket0_fifo_reserve'length);
										
socket0_fifo_rd_watermark 	<= to_unsigned((data_pct_size*8)/data_width,socket0_fifo_rd_watermark'length) when (socket_type(0)='0' and usb_speed='1') else
										to_unsigned((data_pct_size*8)/data_width/USB2DIV,socket0_fifo_rd_watermark'length) when (socket_type(0)='0' and usb_speed='0') else
										to_unsigned((control_pct_size*8)/data_width,socket0_fifo_rd_watermark'length);
										
socket0_fifo_wr_watermark 	<=	socket0_max_wrwords - socket0_fifo_reserve;							
								
socket0_fifo_rdy				<= '1' when (rd_wr(0)='0' and 
                                          socket0_fifo_reset_n = '1' AND 
                                          unsigned(socket0_fifo_wrusedw) <=socket0_fifo_wr_watermark) else
						 				'1' when (rd_wr(0)='1' and
                                          socket0_fifo_reset_n = '1' AND 
                                          unsigned(socket0_fifo_rdusedw) >= socket0_fifo_rd_watermark) else 
						 				'0';

--to determine socket1 watermarks and when socket is ready
socket1_max_wrwords			<= ((socket1_wrusedw_size-1)=>'1', others=>'0');

socket1_fifo_reserve 		<= to_unsigned((data_pct_size*8)/data_width,socket1_fifo_reserve'length) when (socket_type(1)='0' and usb_speed='1') else
										to_unsigned((data_pct_size*8)/data_width/USB2DIV,socket1_fifo_reserve'length) when (socket_type(1)='0' and usb_speed='0') else
										to_unsigned((control_pct_size*8)/data_width,socket1_fifo_reserve'length);
										
socket1_fifo_rd_watermark 	<= to_unsigned((data_pct_size*8)/data_width,socket1_fifo_rd_watermark'length) when (socket_type(1)='0' and usb_speed='1') else
										to_unsigned((data_pct_size*8)/data_width/USB2DIV,socket1_fifo_rd_watermark'length) when (socket_type(1)='0' and usb_speed='0') else						
										to_unsigned((control_pct_size*8)/data_width,socket1_fifo_rd_watermark'length); 								
								
socket1_fifo_wr_watermark 	<=	socket1_max_wrwords - socket1_fifo_reserve;							
								
socket1_fifo_rdy				<= '1' when (rd_wr(1)='0' and 
                                          socket1_fifo_reset_n = '1' AND 
                                          unsigned(socket1_fifo_wrusedw) <= socket1_fifo_wr_watermark) else
						 				'1' when (rd_wr(1)='1' and 
                                          socket1_fifo_reset_n = '1' AND 
                                          unsigned(socket1_fifo_rdusedw) >= socket1_fifo_rd_watermark) else 
										'0';

--to determine socket2 watermarks and when socket is ready
socket2_max_wrwords			<= ((socket2_wrusedw_size-1)=>'1', others=>'0');

socket2_fifo_reserve 		<= to_unsigned((data_pct_size*8)/data_width,socket2_fifo_reserve'length) when (socket_type(2)='0' and usb_speed='1') else
										to_unsigned((data_pct_size*8)/data_width/USB2DIV,socket2_fifo_reserve'length) when (socket_type(2)='0' and usb_speed='0') else
										to_unsigned((control_pct_size*8)/data_width,socket2_fifo_reserve'length);
										
socket2_fifo_rd_watermark 	<= to_unsigned((data_pct_size*8)/data_width,socket2_fifo_rd_watermark'length) when (socket_type(2)='0' and usb_speed='1') else
										to_unsigned((data_pct_size*8)/data_width/USB2DIV,socket2_fifo_rd_watermark'length) when (socket_type(2)='0' and usb_speed='0') else						
										to_unsigned((control_pct_size*8)/data_width,socket2_fifo_rd_watermark'length); 								
								
socket2_fifo_wr_watermark 	<=	socket2_max_wrwords - socket2_fifo_reserve;							
								
socket2_fifo_rdy				<= '1' when (rd_wr(2)='0' and unsigned(socket2_fifo_wrusedw) <= socket2_fifo_wr_watermark) else
						 				'1' when (rd_wr(2)='1' and unsigned(socket2_fifo_rdusedw) >= socket2_fifo_rd_watermark) else 
						 				'0';

--to determine socket3 watermarks and when socket is ready
socket3_max_wrwords			<= ((socket3_wrusedw_size-1)=>'1', others=>'0');

socket3_fifo_reserve 		<= to_unsigned((data_pct_size*8)/data_width,socket3_fifo_reserve'length) when (socket_type(3)='0' and usb_speed='1') else
										to_unsigned((data_pct_size*8)/data_width/USB2DIV,socket3_fifo_reserve'length) when (socket_type(3)='0' and usb_speed='0') else
										to_unsigned((control_pct_size*8)/data_width,socket3_fifo_reserve'length);
										
socket3_fifo_rd_watermark 	<= to_unsigned((data_pct_size*8)/data_width,socket3_fifo_rd_watermark'length) when (socket_type(3)='0' and usb_speed='1') else
										to_unsigned((data_pct_size*8)/data_width/USB2DIV,socket3_fifo_rd_watermark'length) when (socket_type(3)='0' and usb_speed='0') else							
										to_unsigned((control_pct_size*8)/data_width,socket3_fifo_rd_watermark'length);								
								
socket3_fifo_wr_watermark 	<=	socket3_max_wrwords - socket3_fifo_reserve;							
								
socket3_fifo_rdy				<= '1' when (rd_wr(3)='0' and unsigned(socket3_fifo_wrusedw) <= socket3_fifo_wr_watermark) else
						 				'1' when (rd_wr(3)='1' and unsigned(socket3_fifo_rdusedw) >= socket3_fifo_rd_watermark) else 
						 				'0';

socket_fifo_rdy<=x"0000000" & socket3_fifo_rdy & socket2_fifo_rdy & socket1_fifo_rdy & socket0_fifo_rdy; 

clk_out<=clk;
  
--output signal asignments
--slrd   <= slrd_streamOUT_n;
slwr   <= slwr_streamIN_n_d;   

sloe   <= sloe_stream_n;
pktend <= pktend_streamIN_n;
slcs   <= '0';

process(clk, reset_n)begin
	if(reset_n = '0')then 
      slrd <= '1';
	elsif(clk'event and clk = '1')then
      slrd   <= slrd_streamOUT_n;
	end if;	
end process;

GPIF_busy<=(not slrd_streamOUT_n) OR (not slwr_streamIN_n_d);

--To determine size for DMA transfers depending on USB speed (USB3.0 or USB2.0)
process(clk, reset_n)begin
	if(reset_n = '0')then 
		max_control_pct_cnt <= to_unsigned(control_pct_size * 8 / data_width, max_control_pct_cnt'length);
		max_data_pct_cnt <= to_unsigned(data_pct_size * 8 / data_width, max_data_pct_cnt'length) - 2 ;
	elsif(clk'event and clk = '1')then
		if usb_speed = '1' then 
			max_control_pct_cnt <= to_unsigned(control_pct_size * 8 / data_width, max_control_pct_cnt'length);
			max_data_pct_cnt <= to_unsigned(data_pct_size * 8 / data_width, max_data_pct_cnt'length) - 2 ;
		else 
			if control_pct_size < control_dma_size then 
				max_control_pct_cnt <= to_unsigned(control_pct_size * 8 / data_width, max_control_pct_cnt'length);
			else 
				max_control_pct_cnt <= to_unsigned(control_pct_size * 8 / data_width / USB2DIV, max_control_pct_cnt'length);
			end if;
			max_data_pct_cnt <= to_unsigned(data_pct_size*8/data_width / USB2DIV, max_data_pct_cnt'length) - 2;
		end if;
	end if;	
end process;



process(current_state)begin
	if((current_state = stream_out_read) or 
		(current_state = stream_out_read_rd_and_oe_delay) or 
		(current_state = stream_out_read_oe_delay)) then		
		sloe_stream_n <= '0';
	else
	 	sloe_stream_n <= '1';
	end if;
end process;

process(clk, reset_n)begin
	if(reset_n = '0')then
		slwr_streamIN_n_d <= '1';
	elsif(clk'event and clk = '1')then
		slwr_streamIN_n_d <= slwr_streamIN_n;
	end if;	 
end process;

process(current_state)begin
	if (current_state = stream_in_write) then
		slwr_streamIN_n <= '0';
	else
		slwr_streamIN_n <= '1';
	end if;
end process;

process(current_state) begin
	if((current_state = stream_out_read) OR (current_state = stream_out_read_rd_and_oe_delay))then
		slrd_streamOUT_n <= '0';
	else
		slrd_streamOUT_n <= '1';
	end if;	
end process;

process(current_state)begin
	if((current_state = stream_in_pktend))then
		pktend_streamIN_n <= '0';
	else
		pktend_streamIN_n <= '1';
	end if;
end process;


process(current_state)begin
	if((current_state = assert_epswitch OR current_state = wait_DMA_rdy ))then
		EPSWITCH <= '0';
	else
		EPSWITCH <= '1';
	end if;
end process;	

process(clk, reset_n)begin
	if(reset_n = '0')then 
		slrd_streamOUT_n_d<='1';
      slrd_streamOUT_n_d1<='1'; 
		socket_fifo_wr<='0';
	elsif(clk'event and clk = '1')then
		slrd_streamOUT_n_d <=slrd_streamOUT_n;
      slrd_streamOUT_n_d1<= slrd_streamOUT_n_d;
      socket_fifo_wr<= not slrd_streamOUT_n_d1;


	end if;	
end process;

process(current_state) begin
	if((current_state = stream_in_write))then
		socket_fifo_rd <= '1';
	else
		socket_fifo_rd <= '0';
	end if;	
end process;

process(clk, reset_n)begin
	if(reset_n = '0') then 
      socket_fifo_q <= (others=>'0');
	elsif(clk'event and clk = '1')then
      case faddr_reg is 
         when "00000" => 
            socket_fifo_q <= socket0_fifo_q;
         when "00001" => 
            socket_fifo_q <= socket1_fifo_q;
         when "00010" => 
            socket_fifo_q <= socket2_fifo_q;
         when "00011" => 
            socket_fifo_q <= socket3_fifo_q;
         when others => 
            socket_fifo_q <= (others=>'0');
      end case;
	end if;	
end process;


--socket_fifo_q <= socket0_fifo_q when faddr_reg="00000" else 
--					  socket1_fifo_q when faddr_reg="00001" else
--					  socket2_fifo_q when faddr_reg="00010" else
--					  socket3_fifo_q when faddr_reg="00011" else
--					  (others=>'0');

process(slwr_streamIN_n_d, socket_fifo_q)begin
	if(slwr_streamIN_n_d = '0')then
		fdata <= socket_fifo_q;
	else
		fdata <= (others => 'Z');	
	end if;
end process;



process(clk, reset_n)begin
	if(reset_n = '0') then 
      socket0_fifo_wr	<= '0';
      socket1_fifo_wr	<= '0';
      socket2_fifo_wr	<= '0';
      socket3_fifo_wr	<= '0';
	elsif(clk'event and clk = '1')then
   
      if faddr_reg = "00000" then 
         socket0_fifo_wr	<= socket_fifo_wr;
      else 
         socket0_fifo_wr	<= '0';
      end if;
      
      if faddr_reg = "00001" then 
         socket1_fifo_wr	<= socket_fifo_wr;
      else 
         socket1_fifo_wr	<= '0';
      end if;

      if faddr_reg = "00010" then 
         socket2_fifo_wr	<= socket_fifo_wr;
      else 
         socket2_fifo_wr	<= '0';
      end if;

      if faddr_reg = "00011" then 
         socket3_fifo_wr	<= socket_fifo_wr;
      else 
         socket3_fifo_wr	<= '0';
      end if;

	end if;	
end process;

--socket0_fifo_wr	<= socket_fifo_wr when faddr_reg = "00000" else '0';
--socket1_fifo_wr	<= socket_fifo_wr when faddr_reg = "00001" else '0';
--socket2_fifo_wr	<= socket_fifo_wr when faddr_reg = "00010" else '0';
--socket3_fifo_wr	<= socket_fifo_wr when faddr_reg = "00011" else '0';

socket0_fifo_rd	<= socket_fifo_rd when faddr_reg = "00000" else '0';
socket1_fifo_rd	<= socket_fifo_rd when faddr_reg = "00001" else '0';
socket2_fifo_rd	<= socket_fifo_rd when faddr_reg = "00010" else '0';
socket3_fifo_rd	<= socket_fifo_rd when faddr_reg = "00011" else '0';


socket0_fifo_data	<= fdata(data_width-1 downto 0);
socket1_fifo_data	<= fdata(data_width-1 downto 0);
socket2_fifo_data	<= fdata(data_width-1 downto 0);
socket3_fifo_data	<= fdata(data_width-1 downto 0);



--flopping the INPUTs flags
process(clk, reset_n)begin
	if(reset_n = '0')then 
		flaga_d <= '0';
		flagb_d <= '0';
		flagc_d <= '0';
		flagd_d <= '0';
	elsif(clk'event and clk = '1')then
		flaga_d <= flaga;
		flagb_d <= flagb;
		flagc_d <= flagc;
		flagd_d <= flagd;
	end if;	
end process;



--counter to delay the read and output enable signal
process(clk, reset_n)begin
	if(reset_n = '0')then 
		rd_oe_delay_cnt <= "00";
	elsif(clk'event and clk = '1')then	
	 	if(current_state = stream_out_read) then
			rd_oe_delay_cnt <= "00";
      elsif((current_state = stream_out_read_rd_and_oe_delay) and (rd_oe_delay_cnt > 0))then
			rd_oe_delay_cnt <= rd_oe_delay_cnt - 1;
		else
			rd_oe_delay_cnt <= rd_oe_delay_cnt;
		end if;
	end if;
end process;

--Counter to delay the OUTPUT Enable(oe) signal
process(clk, reset_n)begin
	if(reset_n = '0')then 
		oe_delay_cnt <= "00";
	elsif(clk'event and clk = '1')then	
	 	if(current_state = stream_out_read_rd_and_oe_delay OR current_state = idle) then
			oe_delay_cnt <= "11";
			--oe_delay_cnt <= "01";
      elsif((current_state = stream_out_read_oe_delay) and (oe_delay_cnt > 0))then
			oe_delay_cnt <= oe_delay_cnt - 1;
		else
			oe_delay_cnt <= oe_delay_cnt;
		end if;
	end if;
end process;

--Counter to count read operations from FX3
process (clk, reset_n) begin 
	if (reset_n = '0') then 
		slrd_cnt <= (others=>'0');
	elsif (clk'event and clk = '1') then 
		if (slrd_streamOUT_n = '0') then 
			slrd_cnt <= slrd_cnt+1;
		else 
			slrd_cnt <= (others=>'0');
		end if;
	end if;
end process;

--counter to count write operations to FX3
process (clk, reset_n) begin 
	if (reset_n = '0') then 
		slwr_cnt <= (others=>'0');
	elsif (clk'event and clk = '1') then 
		if (slwr_streamIN_n_d = '0') then 
			slwr_cnt <= slwr_cnt+1;
		else 
			slwr_cnt <= (others=>'0');
		end if;
	end if;
end process;


--there are 4 threads to switch 
process (clk, reset_n) begin 
	if (reset_n = '0') then 
		thread_addr_cnt <= "00";
	elsif (clk'event and clk = '1') then 
		if (current_state = prep_thread_addr) then 
			if thread_addr_cnt < 3 then 
				thread_addr_cnt <= thread_addr_cnt+1;
			else 
				thread_addr_cnt <= "00";
			end if;
		else 
			thread_addr_cnt <= thread_addr_cnt;
		end if;
	end if;
end process;

--there are 8 sockets to switch (currently only first is used, switching to others not tested!)
process (clk, reset_n) begin 
	if (reset_n = '0') then 
		socket_addr_cnt <= (others=>'0');
	elsif (clk'event and clk = '1') then 
		if (current_state = prep_socket_addr and faddr_reg(1 downto 0)="11") then 
			if socket_addr_cnt < 7 then 
				socket_addr_cnt <= socket_addr_cnt+1;
			else 
				socket_addr_cnt <= (others=>'0');
			end if;
		else 
			socket_addr_cnt <= socket_addr_cnt;
		end if;
	end if;
end process;


--to prepare logical socket addres
process(clk, reset_n)begin
	if(reset_n = '0')then 
		faddr_reg<="00000";
	elsif(clk'event and clk = '1') then 
		if current_state = prep_thread_addr then

			if  array_of_threads(to_integer(thread_addr_cnt)) = "00" then
				faddr_reg(4 downto 2)<=thread0_socket_reg;			 
			elsif array_of_threads(to_integer(thread_addr_cnt)) = "01" then
				faddr_reg(4 downto 2)<=thread1_socket_reg;	
			elsif array_of_threads(to_integer(thread_addr_cnt)) = "10" then
				faddr_reg(4 downto 2)<=thread2_socket_reg;	
			else 
				faddr_reg(4 downto 2)<=thread3_socket_reg;	
			end if;
			faddr_reg(1 downto 0)<=array_of_threads(to_integer(thread_addr_cnt));

		elsif current_state = prep_socket_addr then 
			faddr_reg(4 downto 2)<= socket_array_thread0(to_integer(socket_addr_cnt));		
			faddr_reg(1 downto 0)<= faddr_reg(1 downto 0);
		else 
			faddr_reg(4 downto 0)<= faddr_reg(4 downto 0);
		end if;
	end if;	
end process;

faddr<=faddr_reg;

--when thread is swiched there is 3 cycle latency to valid flag, this counter is used to wait for it
process(clk, reset_n)begin
	if(reset_n = '0')then 
		flg_latency_cnt<=(others=>'0');
	elsif(clk'event and clk = '1') then 
		if current_state = wait_flg_latency then 
			flg_latency_cnt<=flg_latency_cnt+1;
		else 
			flg_latency_cnt<=(others=>'0');
		end if;
	end if;	
end process;

--when EPSWITCH# signal is used there is 68 cycle latency to valid flag, this counter is used to wait for it
process(clk, reset_n)begin
	if(reset_n = '0')then 
		assert_cnt<=(others=>'0');
	elsif(clk'event and clk = '1') then 
		if current_state = assert_epswitch then 
			assert_cnt<=assert_cnt+1;
		else 
			assert_cnt<=(others=>'0');
		end if;
	end if;	
end process;

--to remember last soscket address
process(clk, reset_n)begin
	if(reset_n = '0')then 
		thread0_socket_reg<=(others=>'0');
	elsif(clk'event and clk = '1') then
		if current_state = prep_thread_addr and array_of_threads(to_integer(thread_addr_cnt)) = "00" then 
			thread0_socket_reg<= socket_array_thread0(to_integer(socket_addr_cnt));
		else 
			thread0_socket_reg<=thread0_socket_reg;
		end if;
	end if;	
end process;

process(clk, reset_n)begin
	if(reset_n = '0')then 
		thread1_socket_reg<=(others=>'0');
	elsif(clk'event and clk = '1') then
		if current_state = prep_thread_addr and array_of_threads(to_integer(thread_addr_cnt)) = "01" then 
			thread1_socket_reg<= socket_array_thread1(to_integer(socket_addr_cnt));
		else 
			thread1_socket_reg<=thread1_socket_reg;
		end if;
	end if;	
end process;


process(clk, reset_n)begin
	if(reset_n = '0')then 
		thread2_socket_reg<=(others=>'0');
	elsif(clk'event and clk = '1') then
		if current_state = prep_thread_addr and array_of_threads(to_integer(thread_addr_cnt)) = "10" then 
			thread2_socket_reg<= socket_array_thread2(to_integer(socket_addr_cnt));
		else 
			thread2_socket_reg<=thread2_socket_reg;
		end if;
	end if;	
end process;

process(clk, reset_n)begin
	if(reset_n = '0')then 
		thread3_socket_reg<=(others=>'0');
	elsif(clk'event and clk = '1') then
		if current_state = prep_thread_addr and array_of_threads(to_integer(thread_addr_cnt)) = "11" then 
			thread3_socket_reg<= socket_array_thread3(to_integer(socket_addr_cnt));
		else 
			thread3_socket_reg<=thread3_socket_reg;
		end if;
	end if;	
end process;


--stream state machine
stream_in_fsm_f : process(clk, reset_n)begin
	if(reset_n = '0')then 
		current_state <= idle;
	elsif(clk'event and clk = '1') then 
		current_state <= next_state;
	end if;	
end process;

--Stream state machine combo
stream_fsm : process(current_state, flaga_d, flagb_d, flagb, flg_latency_cnt, rd_wr, faddr_reg,
							rd_oe_delay_cnt, oe_delay_cnt, slwr_cnt, socket_type, 
							max_control_pct_cnt,socket_fifo_rdy)begin
							
	next_state <= current_state;
	
	case current_state is
	when idle =>							
		next_state <= prep_thread_addr;
		
	when prep_thread_addr => 
		next_state <= wait_flg_latency;
		
	when wait_flg_latency => 		--wait for valid flag
		if flg_latency_cnt >= 4 then 
         next_state <= wait_flagA;
		else	
			next_state <= wait_flg_latency;
		end if;
			
		
	when wait_flagA => 				--wait when DMA buffer is ready
		if flaga_d = '1' then
			next_state<=wait_flagB;
		else 
			next_state <= idle;
		end if;
				
	when wait_flagB =>				--wait when DMA buffer is ready and internal FPGA socket buffers are ready	
		if flagb_d = '1' then 
			if rd_wr(to_integer(unsigned(faddr_reg)))='1' then
				if socket_fifo_rdy(to_integer(unsigned(faddr_reg)))='1' then 
					next_state <= stream_in_write;
				else 
					next_state<= idle;
				end if;
			else 
				if socket_fifo_rdy(to_integer(unsigned(faddr_reg)))='1' then 
					next_state <= stream_out_read;
				else 
					next_state<= idle;
				end if;
			end if;
		else
			next_state <= wait_flagB;
		end if;
		
	when stream_in_write => 		--execute write to FX3 (FPGA ->PC) operation, and terminate depending on socket type
		if (flagb = '0') then 			
         next_state <= idle;
		elsif (slwr_cnt = max_control_pct_cnt-2 and socket_type(to_integer(unsigned(faddr_reg)))='1') then
			next_state <= stream_in_pktend;
		else
		 	next_state <= stream_in_write;
		end if;
		
	when stream_in_pktend => 		--short packet write is used when socket is configured as control socket
		next_state <= idle;	
	
	when stream_in_write_wr_delay =>	-- write watermark words=2
		next_state <= idle;	
	
	when stream_out_read =>			--execute read operation from FX3 (PC->FPGA)
		if(flagb_d = '0')then
			--next_state <= stream_out_read_rd_and_oe_delay;
         next_state <= stream_out_read_oe_delay;
		else
			next_state <= stream_out_read;
		end if;
	
	when stream_out_read_rd_and_oe_delay => --read watermark words=3
		if(rd_oe_delay_cnt = "00")then
			next_state <= stream_out_read_oe_delay;
		else
			next_state <= stream_out_read_rd_and_oe_delay;
		end if;
	
	when stream_out_read_oe_delay =>
		if(oe_delay_cnt = "00")then
			next_state <= idle;
		else
			next_state <= stream_out_read_oe_delay;
		end if;
	
	when others =>
		next_state <= idle;
		
	end case;
end process;

end architecture;

