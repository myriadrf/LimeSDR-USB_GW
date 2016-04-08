-- ----------------------------------------------------------------------------	
-- FILE:	mem_package.vhd
-- DESCRIPTION:	Define subtypes and types used in constructing memory arrays.
-- DATE:	Aug 20, 2001
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	

-- ----------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all ;

package mem_package is 
 	subtype mword1 is std_logic;      		       -- 1 bit memory word
 	subtype mword16 is std_logic_vector(15 downto 0);      -- 16 bit memory word
	subtype mword12 is std_logic_vector(11 downto 0);      -- 12 bit memory word
 	subtype mword25 is std_logic_vector(24 downto 0);      -- 25 bit memory word
 	type    marray32x16 is array (31 downto 0) of mword16; -- 32x16b memory array
 	type    marray48x1  is array (47 downto 0) of mword1;  -- 48x1b memory array
 	type    marray47x16 is array (46 downto 0) of mword16; -- 47x16b memory array
 	type    marray48x16 is array (47 downto 0) of mword16; -- 48x16b memory array
 	type    marray49x16 is array (48 downto 0) of mword16; -- 49x16b memory array
 	type    marray512x16 is array (511 downto 0) of mword16; -- 512x16b memory array
	type    marray128x16 is array (127 downto 0) of mword16; -- 128x16b memory array
	type    marray45x16 is array (44 downto 0) of mword16; -- 45x16b memory array
	type    marray37x16 is array (36 downto 0) of mword16; -- 37x16b memory array
 	type    marray8x16  is array ( 7 downto 0) of mword16; -- 8x16b memory array
	type    marray4x12  is array ( 3 downto 0) of mword12; -- 4x12b memory array
	type    marray16x16 is array (15 downto 0) of mword16; -- 16x16b memory array
 	type    marray8x25  is array ( 7 downto 0) of mword25; -- 8x25b memory array
end mem_package;

