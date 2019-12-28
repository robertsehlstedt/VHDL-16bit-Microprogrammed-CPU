-- k1.vhd
-- This file implements the combinatorial net K1.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity K1 is
  port(
    op :        in std_logic_vector(5 downto 0)         := (others => '0');
    adr:        out std_logic_vector(7 downto 0)        := (others => '0')
    );
end K1;

architecture behaviour of K1 is
  type K1_mem_t is array (0 to 63) of std_logic_vector(7 downto 0);

  -- K1 Lookup Table
  -- x"ADR"                             -- OP
  constant K1_mem_c : K1_mem_t :=
    (x"00",                             -- 00 CONTINUE TO NEXT
     x"0D",                             -- 01 JMP
     x"19",                             -- 02 CALL
     x"1C",                             -- 03 RET
     
     x"13",                             -- 04 CMP
     x"1F",                             -- 05 BEQ
     x"21",                             -- 06 BNE
     
     x"00",                             -- 07
     
     x"0E",                             -- 08 LDI
     x"0E",                             -- 09 LD
     x"0F",                             -- 0A CPY
     x"11",                             -- 0B STI
     x"12",                             -- 0C ST
     x"15",                             -- 0D SWP
     
     x"2F",                             -- 0E ADD
     x"32",                             -- 0F SUB
     x"35",                             -- 10 AND
     x"38",                             -- 11 OR
     x"3B",                             -- 12 LSL
     x"3D",                             -- 13 LSR
     x"3F",                             -- 14 MUL
     x"42",                             -- 15 MULS
     x"45",                             -- 16 DIV
     x"48",                             -- 17 DIVS
     x"4B",                             -- 18 COM
     
     x"00",                             -- 19 BVC
     x"00",                             -- 1A BVS
     x"00",                             -- 1B
     x"00",                             -- 1C
     x"00",                             -- 1D
     x"00",                             -- 1E
     x"00",                             -- 1F
     x"00",                             -- 20
     x"00",                             -- 21
     x"00",                             -- 22
     x"00",                             -- 23
     x"00",                             -- 24
     x"00",                             -- 25
     x"00",                             -- 26
     x"00",                             -- 27
     x"00",                             -- 28
     x"00",                             -- 29
     x"00",                             -- 2A
     x"00",                             -- 2B
     x"00",                             -- 2C
     x"00",                             -- 2D
     x"00",                             -- 2E
     x"00",                             -- 2F
     
     x"4D",                             -- 30 DRW
     x"50",                             -- 31 FWDB
     x"00",                             -- 32
     x"51",                             -- 33 KBD
     
     x"00",                             -- 34
     x"00",                             -- 35
     x"00",                             -- 36
     x"00",                             -- 37
     x"00",                             -- 38
     x"00",                             -- 39
     x"00",                             -- 3A
     x"00",                             -- 3B
     x"00",                             -- 3C
     x"00",                             -- 3D
     x"00",                             -- 3E
     x"00"                              -- 3F
     );

  signal K1_mem : K1_mem_t := K1_mem_c;

  begin
    adr <= K1_mem(to_integer(unsigned(op)));
end architecture behaviour;
