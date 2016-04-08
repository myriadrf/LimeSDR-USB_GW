-- ----------------------------------------------------------------------------	
-- FILE:	mcfg32wm_fsm.vhd
-- DESCRIPTION:	Finite State Machine for serial interface
--							addresses 32 words, with MIMO enable.
-- DATE:	Mar 22, 2013
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity mcfg32wm_fsm is
	port(
		address: in std_logic_vector(9 downto 0);	-- Hardware address
		mimo_en: in std_logic;
		inst_reg: in std_logic_vector(15 downto 0);	-- Instruction register (read only here)
		sclk: in std_logic;				-- Serial clock
		sen: in std_logic;				-- Serial enable
		reset: in std_logic;				-- Reset
		inst_reg_en: out std_logic;			-- Instruction register enable
		din_reg_en: out std_logic;			-- Data in register enable
		dout_reg_sen: out std_logic;			-- Data out register shift enable
		dout_reg_len: out std_logic;			-- Data out register load enable
		mem_we: out std_logic;				-- Memory write enable
		oe: out std_logic;				-- Output enable
		stateo: out std_logic_vector(5 downto 0)
	);
end mcfg32wm_fsm;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture mcfg32wm_fsm_arch of mcfg32wm_fsm is
	-- State codes
	constant s0:  std_logic_vector(5 downto 0) := "000000"; -- Reset state
	constant s1:  std_logic_vector(5 downto 0) := "000001";
	constant s2:  std_logic_vector(5 downto 0) := "000010";
	constant s3:  std_logic_vector(5 downto 0) := "000011";
	constant s4:  std_logic_vector(5 downto 0) := "000100";
	constant s5:  std_logic_vector(5 downto 0) := "000101";
	constant s6:  std_logic_vector(5 downto 0) := "000110";
	constant s7:  std_logic_vector(5 downto 0) := "000111";
	constant s8:  std_logic_vector(5 downto 0) := "001000";
	constant s9:  std_logic_vector(5 downto 0) := "001001";
	constant s10: std_logic_vector(5 downto 0) := "001010";
	constant s11: std_logic_vector(5 downto 0) := "001011";
	constant s12: std_logic_vector(5 downto 0) := "001100";
	constant s13: std_logic_vector(5 downto 0) := "001101";
	constant s14: std_logic_vector(5 downto 0) := "001110";
	constant s15: std_logic_vector(5 downto 0) := "001111";
	constant s16: std_logic_vector(5 downto 0) := "010000";
	
	constant s17: std_logic_vector(5 downto 0) := "010001";
	constant s18: std_logic_vector(5 downto 0) := "010010";
	constant s19: std_logic_vector(5 downto 0) := "010011";
	constant s20: std_logic_vector(5 downto 0) := "010100";
	constant s21: std_logic_vector(5 downto 0) := "010101";
	constant s22: std_logic_vector(5 downto 0) := "010110";
	constant s23: std_logic_vector(5 downto 0) := "010111";
	constant s24: std_logic_vector(5 downto 0) := "011000";
	constant s25: std_logic_vector(5 downto 0) := "011001";
	constant s26: std_logic_vector(5 downto 0) := "011010";
	constant s27: std_logic_vector(5 downto 0) := "011011";
	constant s28: std_logic_vector(5 downto 0) := "011100";
	constant s29: std_logic_vector(5 downto 0) := "011101";
	constant s30: std_logic_vector(5 downto 0) := "011110";
	constant s31: std_logic_vector(5 downto 0) := "011111";
	constant s32: std_logic_vector(5 downto 0) := "100000";

	signal state, next_state: std_logic_vector(5 downto 0);
begin
	state_register: process(sclk, reset, sen)
	begin
		if reset = '0' then  -- Async reset
			state <= s0;
		-- Go back to initial state when sen goes high even if
		-- read/write cycle is not finished by user's mistake
		elsif sen = '1' then
			state <= s0;
		elsif sclk'event and sclk = '1' then
			state <= next_state;
		end if;
	end process state_register;
	stateo <= state;

	state_machine: process (state, sen, inst_reg, address, mimo_en)
	begin
		case state is	
			when s0 =>
				inst_reg_en <= not sen; 
				din_reg_en <= '0';
				dout_reg_sen <= '0';--0
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';--0
				next_state <= s1;
			when s1 =>		  
				-- 1 instruction bit is in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s2;
			when s2 =>
				-- 2 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s3;
			when s3 =>
				-- 3 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s4;
			when s4 =>
				-- 4 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s5;
			when s5 =>
				-- 5 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s6;
			when s6 =>
				-- 6 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s7;
			when s7 =>
				-- 7 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s8;
			when s8 =>
				-- 8 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s9;
			when s9 =>
				-- 9 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s10;
			when s10 =>
				-- 10 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s11;
			when s11 =>
				-- 11 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s12;
			when s12 =>
				-- 12 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s13;
			when s13 =>
				-- 13 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s14;
			when s14 =>
				-- 14 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s15;
			when s15 =>
				-- 15 instruction bits are in
				inst_reg_en <= '1';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s16;
			when s16 =>
				-- Instruction register loaded
				inst_reg_en <= '0';
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '1';
					mem_we <= '0';
					oe <= '1';
				else -- Ignore the next 8 cycles, this is not for us
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';					
					oe <= '0';
				end if;
				next_state <= s17;
			when s17 =>
				-- 1 data bit in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';					
					oe <= '0';
				end if;
				next_state <= s18;
			when s18 =>
				-- 2 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';					
					oe <= '0';
				end if;
				next_state <= s19;
			when s19 =>
				-- 3 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';					
					oe <= '0';
				end if;
				next_state <= s20;
			when s20 =>
				-- 4 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';					
					oe <= '0';
				end if;
				next_state <= s21;
			when s21 =>
				-- 5 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';					
					oe <= '0';
				end if;
				next_state <= s22;
			when s22 =>
				-- 6 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				end if;
				next_state <= s23;
			when s23 =>
				-- 7 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				end if;
				next_state <= s24;
			when s24 =>
				-- 8 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				end if;
				next_state <= s25;
			when s25 =>
				-- 9 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				end if;
				next_state <= s26;
			when s26 =>
				-- 10 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				end if;
				next_state <= s27;
			when s27 =>
				-- 11 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				end if;
				next_state <= s28;
			when s28 =>
				-- 12 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				end if;
				next_state <= s29;
			when s29 =>
				-- 13 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				end if;
				next_state <= s30;
			when s30 =>
				-- 14 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				end if;
				next_state <= s31;
			when s31 =>
				-- 15 data bits in/out
				inst_reg_en <= '0';	
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					din_reg_en <= '1';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '1';--//--buvo 0
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					din_reg_en <= '0';
					dout_reg_sen <= '1';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '1';
				else 
					din_reg_en <= '0';
					dout_reg_sen <= '0';
					dout_reg_len <= '0';
					mem_we <= '0';
					oe <= '0';
				end if;
				next_state <= s32;
				--next_state <= s0;
			when s32 =>
				-- 16 data bits in/out
				inst_reg_en <= not sen; --'1'; 
				din_reg_en <= '0';
				dout_reg_len <= '0';
				if    inst_reg(14 downto 5) = address and inst_reg(15) = '1' and mimo_en = '1' then -- Write cycle
					mem_we <= '0';--//--buvo 1
					dout_reg_sen <= '0';
					oe <= '0';
				elsif inst_reg(14 downto 5) = address and inst_reg(15) = '0' and mimo_en = '1' then -- Read cycle
					mem_we <= '0';
					dout_reg_sen <= '0'; --0
					oe <= '1';
				else 
					mem_we <= '0';
					dout_reg_sen <= '0';
					oe <= '0';
				end if;
				next_state <= s1;

	



	when others =>
				-- This will never happen, just to avoid inferred latches in synthesis
				inst_reg_en <= '0';
				din_reg_en <= '0';
				dout_reg_sen <= '0';
				dout_reg_len <= '0';
				mem_we <= '0';
				oe <= '0';
				next_state <= s0;
		end case;
	end process state_machine;	

end mcfg32wm_fsm_arch;
