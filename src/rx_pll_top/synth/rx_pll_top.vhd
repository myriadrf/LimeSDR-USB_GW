----------------------------------------------------------------------------
-- FILE: rx_pll_top.vhd
-- DESCRIPTION:top file for rx_pll modules
-- DATE:Jan 27, 2016
-- AUTHOR(s):Lime Microsystems
-- REVISIONS:
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.all;
USE altera_mf.altera_mf_components.all;

----------------------------------------------------------------------------
-- Entity declaration
----------------------------------------------------------------------------
entity rx_pll_top is
   generic(
      bandwidth_type          : STRING    := "AUTO";
      clk0_divide_by          : NATURAL   := 1;
      clk0_duty_cycle         : NATURAL   := 50;
      clk0_multiply_by        : NATURAL   := 1;
      clk0_phase_shift        : STRING    := "0";
      clk1_divide_by          : NATURAL   := 1;
      clk1_duty_cycle         : NATURAL   := 50;
      clk1_multiply_by        : NATURAL   := 1;
      clk1_phase_shift        : STRING    := "0";
      compensate_clock        : STRING    := "CLK1";
      inclk0_input_frequency  : NATURAL   := 6250;
      intended_device_family  : STRING    := "Cyclone IV E";
      operation_mode          : STRING    := "SOURCE_SYNCHRONOUS";
      scan_chain_mif_file     : STRING    := "ip/pll/pll.mif";
      drct_c0_ndly            : integer   := 1;
      drct_c1_ndly            : integer   := 2
   );
   port (
   --PLL input 
   pll_inclk         : in std_logic;
   pll_areset        : in std_logic;
   inv_c0            : in std_logic;
   c0                : out std_logic; --muxed clock output
   c1                : out std_logic; --muxed clock output
   pll_locked        : out std_logic;
   --Bypass control
   clk_ena           : in std_logic_vector(1 downto 0); --clock output enable
   drct_clk_en       : in std_logic_vector(1 downto 0); --1- Direct clk, 0 - PLL clocks 
   --Reconfiguration ports
   rcnfg_clk         : in std_logic;
   rcnfig_areset     : in std_logic;
   rcnfig_en         : in std_logic;
   rcnfig_data       : in std_logic_vector(143 downto 0);
   rcnfig_status     : out std_logic;
   --Dynamic phase shift ports
   dynps_en          : in std_logic;
   dynps_dir         : in std_logic;
   dynps_cnt_sel     : in std_logic_vector(2 downto 0);
   dynps_phase       : in std_logic_vector(9 downto 0);
   --Overall configuration PLL status
   busy              : out std_logic
   
   );
end rx_pll_top;

----------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------
architecture arch of rx_pll_top is
--declare signals,  components here
signal pll_areset_n              : std_logic;
signal pll_inclk_global          : std_logic;

signal c0_global                 : std_logic;
signal c1_global                 : std_logic;
      
signal rcnfig_en_sync            : std_logic;
signal rcnfig_data_sync          : std_logic_vector(143 downto 0);

signal dynps_en_sync             : std_logic;
signal dynps_dir_sync            : std_logic;
signal dynps_cnt_sel_sync        : std_logic_vector(2 downto 0);
signal dynps_phase_sync          : std_logic_vector(9 downto 0);
signal rcnfig_en_sync_scanclk    : std_logic;

      
--inst0     
signal inst0_wr_rom              : std_logic;
signal inst0_reconfig            : std_logic;
signal inst0_config_data         : std_logic;
--inst1
signal inst1_busy                : std_logic;
signal inst1_pll_areset          : std_logic;
signal inst1_pll_configupdate    : std_logic;
signal inst1_pll_scanclk         : std_logic;
signal inst1_pll_scanclkena      : std_logic;
signal inst1_pll_scandata        : std_logic;
signal inst1_rom_address_out     : std_logic_vector(7 downto 0);
signal inst1_write_rom_ena       : std_logic;
-- inst2
signal inst2_ph_step             : std_logic;
signal inst2_ps_status           : std_logic;

--inst3
signal inst3_inclk               : std_logic_vector(1 downto 0);
signal inst3_clk                 : std_logic_vector(4 downto 0);
signal inst3_locked              : std_logic;
signal inst3_phasedone           : std_logic;
signal inst3_scandataout         : std_logic;
signal inst3_scandone            : std_logic;

--isnt4
signal inst4_rcfig_complete      : std_logic;

--inst5
signal inst5_c0_pol_h            : std_logic_vector(0 downto 0);
signal inst5_c0_pol_l            : std_logic_vector(0 downto 0);
signal inst5_dataout             : std_logic_vector(0 downto 0);

signal drct_c0_dly_chain         : std_logic_vector(drct_c0_ndly-1 downto 0);
signal drct_c1_dly_chain         : std_logic_vector(drct_c1_ndly-1 downto 0);

signal c0_mux, c1_mux            : std_logic;
signal locked_mux                : std_logic;

component clkctrl is
   port (
      inclk  : in  std_logic := '0'; --  altclkctrl_input.inclk
      ena    : in  std_logic := '0'; --                  .ena
      outclk : out std_logic         -- altclkctrl_output.outclk
);
end component;

COMPONENT altpll
   GENERIC (
      bandwidth_type          : STRING;
      clk0_divide_by          : NATURAL;
      clk0_duty_cycle         : NATURAL;
      clk0_multiply_by        : NATURAL;
      clk0_phase_shift        : STRING;
      clk1_divide_by          : NATURAL;
      clk1_duty_cycle         : NATURAL;
      clk1_multiply_by        : NATURAL;
      clk1_phase_shift        : STRING;
      compensate_clock        : STRING;
      inclk0_input_frequency  : NATURAL;
      intended_device_family  : STRING;
      lpm_hint                : STRING;
      lpm_type                : STRING;
      operation_mode          : STRING;
      pll_type                : STRING;
      port_activeclock        : STRING;
      port_areset             : STRING;
      port_clkbad0            : STRING;
      port_clkbad1            : STRING;
      port_clkloss            : STRING;
      port_clkswitch          : STRING;
      port_configupdate       : STRING;
      port_fbin               : STRING;
      port_inclk0             : STRING;
      port_inclk1             : STRING;
      port_locked             : STRING;
      port_pfdena             : STRING;
      port_phasecounterselect : STRING;
      port_phasedone          : STRING;
      port_phasestep          : STRING;
      port_phaseupdown        : STRING;
      port_pllena             : STRING;
      port_scanaclr           : STRING;
      port_scanclk            : STRING;
      port_scanclkena         : STRING;
      port_scandata           : STRING;
      port_scandataout        : STRING;
      port_scandone           : STRING;
      port_scanread           : STRING;
      port_scanwrite          : STRING;
      port_clk0               : STRING;
      port_clk1               : STRING;
      port_clk2               : STRING;
      port_clk3               : STRING;
      port_clk4               : STRING;
      port_clk5               : STRING;
      port_clkena0            : STRING;
      port_clkena1            : STRING;
      port_clkena2            : STRING;
      port_clkena3            : STRING;
      port_clkena4            : STRING;
      port_clkena5            : STRING;
      port_extclk0            : STRING;
      port_extclk1            : STRING;
      port_extclk2            : STRING;
      port_extclk3            : STRING;
      self_reset_on_loss_lock : STRING;
      width_clock             : NATURAL;
      width_phasecounterselect: NATURAL;
      scan_chain_mif_file     : STRING
   );
PORT (
      areset               : IN STD_LOGIC ;
      configupdate         : IN STD_LOGIC ;
      inclk                : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
      pfdena               : IN STD_LOGIC ;
      phasecounterselect   : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      phasestep            : IN STD_LOGIC ;
      phaseupdown          : IN STD_LOGIC ;
      scanclk              : IN STD_LOGIC ;
      scanclkena           : IN STD_LOGIC ;
      scandata             : IN STD_LOGIC ;
      clk                  : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
      locked               : OUT STD_LOGIC ;
      phasedone            : OUT STD_LOGIC ;
      scandataout          : OUT STD_LOGIC ;
      scandone             : OUT STD_LOGIC 
);
END COMPONENT;


begin
   
pll_areset_n   <= not pll_areset;
   
----------------------------------------------------------------------------
-- Synchronization registers
----------------------------------------------------------------------------  
 sync_reg0 : entity work.sync_reg 
 port map(rcnfg_clk, '1', rcnfig_en, rcnfig_en_sync); 
 
 sync_reg1 : entity work.sync_reg 
 port map(inst1_pll_scanclk, '1', dynps_en, dynps_en_sync); 
 
 sync_reg2 : entity work.sync_reg 
 port map(inst1_pll_scanclk, '1', dynps_dir, dynps_dir_sync); 
 
 sync_reg3 : entity work.sync_reg 
 port map(inst1_pll_scanclk, '1', rcnfig_en, rcnfig_en_sync_scanclk);
   
 bus_sync_reg0 : entity work.bus_sync_reg
 generic map (144) 
 port map(rcnfg_clk, '1', rcnfig_data, rcnfig_data_sync);
 
 bus_sync_reg1 : entity work.bus_sync_reg
 generic map (3) 
 port map(inst1_pll_scanclk, '1', dynps_cnt_sel, dynps_cnt_sel_sync);
 
 bus_sync_reg2 : entity work.bus_sync_reg
 generic map (10) 
 port map(inst1_pll_scanclk, '1', dynps_phase, dynps_phase_sync);
 
----------------------------------------------------------------------------
-- pll_reconfig_module controller instance
----------------------------------------------------------------------------
config_ctrl_inst0 : entity work.config_ctrl
port map(
      clk         => rcnfg_clk,
      rst         => rcnfig_areset,
      busy        => inst1_busy,
      addr        => inst1_rom_address_out,
      rd_data     => inst1_write_rom_ena,
      spi_data    => rcnfig_data_sync,
      en_config   => rcnfig_en_sync,
      en_clk      => open,
      wr_rom      => inst0_wr_rom,
      reconfig    => inst0_reconfig,
      config_data => inst0_config_data
);
 
----------------------------------------------------------------------------
-- pll_reconfig_module instance
---------------------------------------------------------------------------- 
pll_reconfig_module_inst1 : ENTITY work.pll_reconfig_module
   PORT MAP
(
      clock                => rcnfg_clk,
      counter_param        => (others=>'0'),
      counter_type         => (others=>'0'),
      data_in              => (others=>'0'),
      pll_areset_in        => pll_areset,
      pll_scandataout      => inst3_scandataout,
      pll_scandone         => inst3_scandone,
      read_param           => '0',
      reconfig             => inst0_reconfig,
      reset                => rcnfig_areset,
      reset_rom_address    => '0',
      rom_data_in          => inst0_config_data,
      write_from_rom       => inst0_wr_rom,
      write_param          => '0',
      busy                 => inst1_busy,
      data_out             => open,
      pll_areset           => inst1_pll_areset,
      pll_configupdate     => inst1_pll_configupdate,
      pll_scanclk          => inst1_pll_scanclk,
      pll_scanclkena       => inst1_pll_scanclkena,
      pll_scandata         => inst1_pll_scandata,
      rom_address_out      => inst1_rom_address_out,
      write_rom_ena        => inst1_write_rom_ena
);
      
----------------------------------------------------------------------------
-- Dynamic phase shift controller instance
----------------------------------------------------------------------------
pll_ps_cntrl_inst2 : entity work.pll_ps_cntrl
   port map(
      clk               => inst1_pll_scanclk,
      reset_n           => pll_areset_n,
      phase             => dynps_phase_sync,
      ps_en             => dynps_en_sync,
      ph_done           => inst3_phasedone,
      pll_locked        => inst3_locked,
      pll_reconfig      => rcnfig_en_sync_scanclk,
      ph_step           => inst2_ph_step,
      ps_status         => inst2_ps_status,
      psen_cnt_out      => open
      );   

       
   inst3_inclk <= '0' & pll_inclk;
----------------------------------------------------------------------------
-- PLL instance
----------------------------------------------------------------------------      
altpll_inst3 : altpll
GENERIC MAP (
      bandwidth_type             => bandwidth_type,
      clk0_divide_by             => clk0_divide_by,
      clk0_duty_cycle            => clk0_duty_cycle,
      clk0_multiply_by           => clk0_multiply_by,
      clk0_phase_shift           => clk0_phase_shift,   
      clk1_divide_by             => clk1_divide_by,
      clk1_duty_cycle            => clk1_duty_cycle,
      clk1_multiply_by           => clk1_multiply_by,
      clk1_phase_shift           => clk1_phase_shift,
      compensate_clock           => compensate_clock,
      inclk0_input_frequency     => inclk0_input_frequency,
      intended_device_family     => intended_device_family,
      lpm_hint                   => "CBX_MODULE_PREFIX=pll",
      lpm_type                   => "altpll",
      operation_mode             => operation_mode,
      pll_type                   => "AUTO",
      port_activeclock           => "PORT_UNUSED",
      port_areset                => "PORT_USED",
      port_clkbad0               => "PORT_UNUSED",
      port_clkbad1               => "PORT_UNUSED",
      port_clkloss               => "PORT_UNUSED",
      port_clkswitch             => "PORT_UNUSED",
      port_configupdate          => "PORT_USED",
      port_fbin                  => "PORT_UNUSED",
      port_inclk0                => "PORT_USED",
      port_inclk1                => "PORT_UNUSED",
      port_locked                => "PORT_USED",
      port_pfdena                => "PORT_USED",
      port_phasecounterselect    => "PORT_USED",
      port_phasedone             => "PORT_USED",
      port_phasestep             => "PORT_USED",
      port_phaseupdown           => "PORT_USED",
      port_pllena                => "PORT_UNUSED",
      port_scanaclr              => "PORT_UNUSED",
      port_scanclk               => "PORT_USED",
      port_scanclkena            => "PORT_USED",
      port_scandata              => "PORT_USED",
      port_scandataout           => "PORT_USED",
      port_scandone              => "PORT_USED",
      port_scanread              => "PORT_UNUSED",
      port_scanwrite             => "PORT_UNUSED",
      port_clk0                  => "PORT_USED",
      port_clk1                  => "PORT_USED",
      port_clk2                  => "PORT_UNUSED",
      port_clk3                  => "PORT_UNUSED",
      port_clk4                  => "PORT_UNUSED",
      port_clk5                  => "PORT_UNUSED",
      port_clkena0               => "PORT_UNUSED",
      port_clkena1               => "PORT_UNUSED",
      port_clkena2               => "PORT_UNUSED",
      port_clkena3               => "PORT_UNUSED",
      port_clkena4               => "PORT_UNUSED",
      port_clkena5               => "PORT_UNUSED",
      port_extclk0               => "PORT_UNUSED",
      port_extclk1               => "PORT_UNUSED",
      port_extclk2               => "PORT_UNUSED",
      port_extclk3               => "PORT_UNUSED",
      self_reset_on_loss_lock    => "OFF",
      width_clock                => 5,
      width_phasecounterselect   => 3,
      scan_chain_mif_file        => scan_chain_mif_file
)
PORT MAP (
      areset               => inst1_pll_areset,
      configupdate         => inst1_pll_configupdate,
      inclk                => inst3_inclk,
      pfdena               => '1',
      phasecounterselect   => dynps_cnt_sel_sync,
      phasestep            => inst2_ph_step,
      phaseupdown          => dynps_dir_sync,
      scanclk              => inst1_pll_scanclk,
      scanclkena           => inst1_pll_scanclkena,
      scandata             => inst1_pll_scandata,
      clk                  => inst3_clk,
      locked               => inst3_locked,
      phasedone            => inst3_phasedone,
      scandataout          => inst3_scandataout,
      scandone             => inst3_scandone
);
   
   
pll_reconfig_status_inst4 : entity work.pll_reconfig_status
   port map(
      clk               => inst1_pll_scanclk,
      reset_n           => pll_areset_n,
      reconfig_en       => rcnfig_en_sync_scanclk,
      scandone          => inst3_scandone,
      exclude_ps_status => '0',
      ps_en             => dynps_en_sync,
      ps_status         => inst2_ps_status,
      rcfig_complete    => inst4_rcfig_complete
      
      );   

-- ----------------------------------------------------------------------------
-- c0 direct output lcell delay chain 
-- ----------------------------------------------------------------------------   
c0_dly_instx_gen : 
for i in 0 to drct_c0_ndly-1 generate
   --first lcell instance
   first : if i = 0 generate 
   lcell0 : lcell 
      port map (
         a_in  => pll_inclk_global,
         a_out => drct_c0_dly_chain(i)
         );
   end generate first;
   --rest of the lcell instance
   rest : if i > 0 generate
   lcellx : lcell 
      port map (
         a_in  => drct_c0_dly_chain(i-1),
         a_out => drct_c0_dly_chain(i)
         );
   end generate rest;
end generate c0_dly_instx_gen;


-- ----------------------------------------------------------------------------
-- c1 direct output lcell delay chain 
-- ----------------------------------------------------------------------------   
c1_dly_instx_gen : 
for i in 0 to drct_c1_ndly-1 generate
   --first lcell instance
   first : if i = 0 generate 
   lcell0 : lcell 
      port map (
         a_in  => pll_inclk_global,
         a_out => drct_c1_dly_chain(i)
         );
   end generate first;
   --rest of the lcell instance
   rest : if i > 0 generate
   lcellx : lcell 
      port map (
         a_in  => drct_c1_dly_chain(i-1),
         a_out => drct_c1_dly_chain(i)
         );
   end generate rest;
end generate c1_dly_instx_gen;

-- ----------------------------------------------------------------------------
-- c0 clk MUX
-- ----------------------------------------------------------------------------
c0_mux <=   inst3_clk(0) when drct_clk_en(0)='0' else 
            drct_c0_dly_chain(drct_c0_ndly-1);

-- ----------------------------------------------------------------------------
-- c1 clk MUX
-- ----------------------------------------------------------------------------
c1_mux <=   inst3_clk(1) when drct_clk_en(1)='0' else 
            drct_c1_dly_chain(drct_c1_ndly-1);


locked_mux <=  pll_areset_n when (drct_clk_en(0)='1' OR drct_clk_en(1)='1') else
               inst3_locked;




inst5_c0_pol_h(0) <= not inv_c0;
inst5_c0_pol_l(0) <= inv_c0;

-- ----------------------------------------------------------------------------
-- DDR output buffer 
-- ----------------------------------------------------------------------------
ALTDDIO_OUT_component_int5 : ALTDDIO_OUT
GENERIC MAP (
   extend_oe_disable       => "OFF",
   intended_device_family  => intended_device_family,
   invert_output           => "OFF",
   lpm_hint                => "UNUSED",
   lpm_type                => "altddio_out",
   oe_reg                  => "UNREGISTERED",
   power_up_high           => "OFF",
   width                   => 1
)
PORT MAP (
   aclr           => '0',
   datain_h       => inst5_c0_pol_h,
   datain_l       => inst5_c0_pol_l,
   outclock       => c0_global,
   dataout        => inst5_dataout
);

-- ----------------------------------------------------------------------------
-- Clock control buffers 
-- ----------------------------------------------------------------------------
clkctrl_inst6 : clkctrl 
port map(
   inclk    => pll_inclk,
   ena      => '1',
   outclk   => pll_inclk_global
);

clkctrl_inst7 : clkctrl 
port map(
   inclk    => c0_mux,
   ena      => clk_ena(0),
   outclk   => c0_global
);

clkctrl_inst8 : clkctrl 
port map(
   inclk    => c1_mux,
   ena      => clk_ena(1),
   outclk   => c1_global
);

-- ----------------------------------------------------------------------------
-- To output ports
-- ----------------------------------------------------------------------------
c0             <= inst5_dataout(0);
c1             <= c1_global;
pll_locked     <= locked_mux;
rcnfig_status  <= inst4_rcfig_complete;
busy           <= inst1_busy OR inst2_ps_status;
  
end arch;   





