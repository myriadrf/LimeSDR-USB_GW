-- ----------------------------------------------------------------------------	
-- FILE: 	sync_fifo_rw.vhd
-- DESCRIPTION:	fifo for data sync
-- DATE:	June 30, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity sync_fifo_rw is
  generic( dev_family	: string  := "Cyclone IV E";
			  data_w 		: integer :=64
  );
  port (
        --input ports 
        wclk      : in std_logic;
        rclk      : in std_logic;
        reset_n   : in std_logic;
        sync_en   : in std_logic;
        sync_data : in std_logic_vector(data_w-1 downto 0);
        sync_q    : out std_logic_vector(data_w-1 downto 0)
        

        --output ports 
        
        );
end sync_fifo_rw;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of sync_fifo_rw is
--declare signals,  components here
signal rdreq    : std_logic;
signal wrreq    : std_logic;
signal rdempty  : std_logic;
signal wrfull   : std_logic;



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
		
        );
end component;

  
begin

wrreq<=sync_en; 


  


-- ----------------------------------------------------------------------------
-- rclk clock domain
-- ----------------------------------------------------------------------------
  process(reset_n, rclk)
    begin
      if reset_n='0' then
        rdreq<='0';  
 	    elsif (rclk'event and rclk = '1') then
 	      if rdempty='0' then 
 	          rdreq<='1';
 	      else 
 	          rdreq<='0';
 	      end if;
 	    end if;
    end process;


fifo :  fifo_inst 
  generic map (
			dev_family	    => dev_family, 
			wrwidth         => data_w, 
			wrusedw_witdth  => 9, 
			rdwidth         => data_w, 
			rdusedw_width   => 9,
			show_ahead      => "OFF"
  )  
  port map (
      --input ports 
      reset_n       => reset_n, 
      wrclk         => wclk,
      wrreq         => wrreq,
      data          => sync_data, 
      wrfull        => open,
		wrempty		  => open, 
      wrusedw       => open,
      rdclk 	     => rclk,
      rdreq         => rdreq,
      q             => sync_q,
      rdempty       => rdempty,
      rdusedw       => open     		
        );


	
    
  
end arch;   




