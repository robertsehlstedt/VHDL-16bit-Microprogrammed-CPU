-- program_mem.vhd
-- This file implements the program memory.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity program_mem is
  port(
    clk:        in std_logic := '0';
    adr :       in std_logic_vector(9 downto 0)         := (others => '0');
    instr:      out std_logic_vector(19 downto 0)       := (others => '0')
    );
end program_mem;

architecture behaviour of program_mem is
  type program_mem_t is array (0 to 1023) of std_logic_vector(19 downto 0);

  -- Program Lookup Table
  -- x"INSTR"                           -- ADR
  constant program_mem_c : program_mem_t :=
    (
     x"21000",                          --0000
     x"00001",
     x"21100",
     x"00002",

     x"21300",                          --0004
     x"00003",
     x"38001",
     x"3c300",


     others => (others => '0'));

  signal program_mem : program_mem_t := program_mem_c;

  begin
    process(clk)
    begin
      if rising_edge(clk) then
        instr <= program_mem(to_integer(unsigned(adr)));
      end if;
    end process;
end architecture behaviour;
