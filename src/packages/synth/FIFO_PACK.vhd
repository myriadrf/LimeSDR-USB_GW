-- ----------------------------------------------------------------------------	
-- FILE: 	FIFO_PACK.vhd
-- DESCRIPTION:	Package for functions related to altera FIFO
-- DATE:	June 8, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- ----------------------------------------------------------------------------
-- Package declaration
-- ----------------------------------------------------------------------------
package FIFO_PACK is

   function FIFORD_SIZE (wr_width : integer; rd_width : integer; wr_size : integer)
      return integer;
      
   function FIFOWR_SIZE (wr_width : integer; rd_width : integer; rd_size : integer)
      return integer;
      
   function FIFO_WORDS_TO_Nbits (n_words : integer; add_msb : boolean)
      return integer;
      
end  FIFO_PACK;

-- ----------------------------------------------------------------------------
-- Package body
-- ----------------------------------------------------------------------------
package body FIFO_PACK is

-- ----------------------------------------------------------------------------
-- Return FIFO rdusedw size, up to 4 times difference in port width
-- ----------------------------------------------------------------------------
   function FIFORD_SIZE (wr_width : integer; rd_width : integer; wr_size : integer)  
      return integer is     
   begin  
      if wr_width > rd_width then 
         return wr_size+(wr_width/rd_width)/2;
      elsif wr_width < rd_width then 
         return wr_size-(rd_width/wr_width)/2;
      else 
         return wr_size;
      end if;     
   end FIFORD_SIZE;
   
-- ----------------------------------------------------------------------------
-- Return FIFO wrusedw size, up to 4 times difference in port width
-- ----------------------------------------------------------------------------
   function FIFOWR_SIZE (wr_width : integer; rd_width : integer; rd_size : integer)  
      return integer is     
   begin  
      if rd_width > wr_width then 
         return rd_size+(rd_width/wr_width)/2;
      elsif rd_width < wr_width then 
         return rd_size-(wr_width/rd_width)/2;
      else 
         return rd_size;
      end if;     
   end FIFOWR_SIZE;
   
-- ----------------------------------------------------------------------------
-- Return FIFO required bits to represent number of words
-- ---------------------------------------------------------------------------- 
   function FIFO_WORDS_TO_Nbits (n_words : integer; add_msb : boolean)  
      return integer is     
   begin 
      if add_msb then 
         return integer(ceil(log2(real(n_words))))+1;
      else 
         return integer(ceil(log2(real(n_words))));
      end if;
   end FIFO_WORDS_TO_Nbits;
end FIFO_PACK;
      
      