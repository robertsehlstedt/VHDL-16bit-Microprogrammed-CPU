-- k2.vhd
-- This file implements the combinatorial net K2.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity K2 is
  port(
    mode :      in std_logic_vector(1 downto 0)         := (others => '0');
    adr:        out std_logic_vector(7 downto 0)        := (others => '0')
    );
end K2;

architecture behaviour of K2 is
  type K2_mem_t is array (0 to 3) of std_logic_vector(7 downto 0);

  -- K2 Lookup Table
  -- x"ADR"                             -- OP
  constant K2_mem_c : K2_mem_t :=
    (x"FF",                             -- 00 DO NOTHING
     x"04",                             -- 01 IMMEDIATE
     x"08",                             -- 02 DIRECT
     x"0A"                              -- 03 INDIRECT
     );

  signal K2_mem : K2_mem_t := K2_mem_c;

  begin
    adr <= K2_mem(to_integer(unsigned(mode)));
end architecture behaviour;
