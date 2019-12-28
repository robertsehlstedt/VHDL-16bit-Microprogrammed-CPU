-- alu.vhd
-- This file contains the implementation of an alu.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
  port(
    clk :       in std_logic;                                   -- Clock pulse
    rst :       in std_logic;                                   -- Reset
    A, B :      in unsigned(15 downto 0);                       -- Inputs A and B
    op :        in std_logic_vector(3 downto 0);                -- Operation
    status :    out std_logic_vector(3 downto 0) := "0000";     -- Status flags
    output :    out unsigned(15 downto 0)                       -- Output
       );
end ALU;

-- The ALU code is divided into 3 parts
-- 1. Calculation of the result
-- 2. Calculation of flags
-- 3. Assignment of flags

architecture behaviour of ALU is
  signal R  :   unsigned(31 downto 0)                   := (others => '0'); -- Contains result
  alias res :   unsigned(15 downto 0) is R(15 downto 0);
  
  signal Zc, Nc, Cc, Vc : std_logic := '0';     -- Candidates for flags
  alias Z : std_logic is status(3);             -- Z flag
  alias N : std_logic is status(2);             -- N flag
  alias C : std_logic is status(1);             -- C flag
  alias V : std_logic is status(0);             -- V flag

  constant NOP  : std_logic_vector(3 downto 0) := "0000";
  constant ADD  : std_logic_vector(3 downto 0) := "0001";
  constant SUB  : std_logic_vector(3 downto 0) := "0010";
  constant MUL  : std_logic_vector(3 downto 0) := "0011";
  constant MULS : std_logic_vector(3 downto 0) := "0100";
  constant XXX  : std_logic_vector(3 downto 0) := "0101";
  constant YYY  : std_logic_vector(3 downto 0) := "0110";
  constant ANB  : std_logic_vector(3 downto 0) := "0111";
  constant AOB  : std_logic_vector(3 downto 0) := "1000";
  constant LSL  : std_logic_vector(3 downto 0) := "1001";
  constant LSR  : std_logic_vector(3 downto 0) := "1010";
  constant NUL  : std_logic_vector(3 downto 0) := "1011";
  constant COM  : std_logic_vector(3 downto 0) := "1100";
  constant LET  : std_logic_vector(3 downto 0) := "1101";
  
begin

  -- Calculates the result of an operation
  
  process(A, B, op)
  begin
    case op is
      when NOP  => NULL;                                              -- No op
      when ADD  => R <= (14 downto 0 => '0') & (('0'&A) + ('0'&B));   -- A+B
      when SUB  => R <= (14 downto 0 => '0') & ('0'&A) - ('0'&B);     -- A-B
      when MUL  => R <= A * B;                                        -- unsigned mul
      when MULS => R <= unsigned(signed(A) * signed(B));              -- signed muls
      when ANB  => R <= (15 downto 0 => '0') & (A and B);             -- A and B (logical)
      when AOB  => R <= (15 downto 0 => '0') & (A or B);              -- A or B (logical)
      when LSL  => R <= R(30 downto 0) & '0';                           -- lsl
      when LSR  => R <= '0' & R(31 downto 1);                           -- lsr
      when NUL  => R <= (others => '0');                              -- R = 0
      when COM  => R <= not R;                                        -- R = R'
      when LET  => R <= (15 downto 0 => '0') & A;                     -- R = A
      when others => null;
    end case;
  end process;

  output <= res;

  -- Calculate flags

  -- Candidates
  Zc <= '1' when R(31 downto 0) = 0 and ((op = MUL) or (op = MULS)) else
        '1' when R(15 downto 0) = 0 and (op /= MUL) and (op /= MULS) else
        '0';
  Nc <= R(31) when ((op = MUL) or (op = MULS)) else
        R(15);
  Cc <= R(31) when ((op = MUL) or (op = MULS)) else
        R(16);
  Vc <= (not A(15) and not B(15) and R(15)) or
        (A(15) and B(15) and not R(15)) when (op = ADD) else
        (not A(15) and B(15) and R(15)) or
        (A(15) and not B(15) and R(15)) when (op = SUB) else
        '0';

  -- Assign flags

  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        Z <= '0'; N <= '0'; C <= '0'; V <= '0';
      else
          case op is
            when NOP      => null;
            when ADD      => Z <= Zc; N <= Nc; C <= Cc; V <= Vc;
            when SUB      => Z <= Zc; N <= Nc; C <= Cc; V <= Vc;
            when MUL      => Z <= Zc; N <= Nc; C <= Cc;
            when MULS     => Z <= Zc; N <= Nc; C <= Cc;
            when ANB      => Z <= Zc; N <= Nc;
            when AOB      => Z <= Zc; N <= Nc;
            when LSL      => Z <= Zc; N <= Nc; C <= Cc;
            when LSR      => Z <= Zc; N <= Nc; C <= Cc;
            when NUL      => Z <= Zc;
            when COM      => Z <= Zc; N <= Nc;
            when LET      => Z <= Zc;
            when others   => null;
          end case;
      end if;
    end if;
  end process;
        
end architecture behaviour;
