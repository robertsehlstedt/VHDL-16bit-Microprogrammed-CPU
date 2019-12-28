-- k1_tb.vhd
-- Testbench for Combinatorial net K1.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity k1_tb is
end k1_tb;

architecture behaviour of k1_tb is

  component K1
    port(
      op :      in std_logic_vector(5 downto 0);
      adr :     out std_logic_vector(7 downto 0)
      );
    end component;

  signal op_tb :        std_logic_vector(5 downto 0)    := (others => '0');
  signal adr_tb :       std_logic_vector(7 downto 0)    := (others => '0');

  begin

    uut: K1 port map(
      op => op_tb,
      adr => adr_tb
      );

    stim_proc: process
    begin

      wait for 100 ns;

      op_tb <= "000000";                -- 0

      wait for 100 ns;

      op_tb <= "000001";                -- 1

      wait for 100 ns;

      op_tb <= "010100";                -- 20

      wait for 100 ns;

      op_tb <= "111111";
      
    end process;

end architecture behaviour;
