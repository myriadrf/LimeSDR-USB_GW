library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package utils is
  function log2(
    N : integer)
    return integer;

  function log2_f(
    N : integer)
    return integer;
  function conditional (
    constant a        :    boolean;
    constant if_true  : in integer;
    constant if_false : in integer)
    return integer;


  function branch_pack_signal (
    pc     : std_logic_vector;
    target : std_logic_vector;
    taken  : std_logic;
    flush  : std_logic;
    enable : std_logic)
    return std_logic_vector;
  function branch_get_pc (
    sig : std_logic_vector)
    return std_logic_vector;
  function branch_get_tgt (
    sig : std_logic_vector)
    return std_logic_vector;
  function branch_get_taken (
    sig : std_logic_vector)
    return std_logic;
  function branch_get_flush (
    sig : std_logic_vector)
    return std_logic;
  function branch_get_enable (
    sig : std_logic_vector)
    return std_logic;
  function bool_to_int (
    signal a : std_logic)
    return integer ;

end utils;
package body utils is
  function bool_to_int (
    signal a : std_logic)
    return integer is
  begin  -- function bool_to_int
    if a = '1' then
      return 1;
    end if;
    return 0;
  end function bool_to_int;


  function log2_f(
    N : integer)
    return integer is
    variable i : integer := 0;
  begin
    while (2**i <= n) loop
      i := i + 1;
    end loop;
    return i-1;
  end log2_f;

  function log2(
    N : integer)
    return integer is
    variable i : integer := 0;
  begin
    while (2**i < n) loop
      i := i + 1;
    end loop;
    return i;
  end log2;

  function conditional (
    constant a        :    boolean;
    constant if_true  : in integer;
    constant if_false : in integer)
    return integer is
  begin
    if a then
      return if_true;
    else
      return if_false;
    end if;
  end conditional;

  function ceil_log2(i : natural) return integer is
    variable temp    : integer := i;
    variable ret_val : integer := 0;
  begin
    while temp > 1 loop
      ret_val := ret_val + 1;
      temp    := temp / 2;
    end loop;
    return ret_val;
  end function;

  function branch_pack_signal (
    pc     : std_logic_vector;
    target : std_logic_vector;
    taken  : std_logic;
    flush  : std_logic;
    enable : std_logic)
    return std_logic_vector is
  begin
    return pc & target & taken & flush & enable;
  end function;

  function branch_get_pc (
    sig : std_logic_vector)
    return std_logic_vector is
  begin
    return sig(sig'left downto sig'left-((sig'length-3)/2)+1);
  end function;
  function branch_get_tgt (
    sig : std_logic_vector)
    return std_logic_vector is
  begin
    return sig(sig'left-(sig'length-3)/2 downto 3);
  end function;
  function branch_get_taken (
    sig : std_logic_vector) return std_logic is
  begin
    return sig(2);
  end function;
  function branch_get_flush (
    sig : std_logic_vector) return std_logic is
  begin
    return sig(1);
  end function;

  function branch_get_enable (
    sig : std_logic_vector)
    return std_logic is
  begin
    return sig(0);
  end function;


end utils;
