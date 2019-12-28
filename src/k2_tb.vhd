-- k2_tb.vhd
-- Testbench for Combinatorial net K2.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity k2_tb is
end k2_tb;

architecture behaviour of k2_tb is

  component K2
    port(
      mode :      in std_logic_vector(1 downto 0);
      adr :     out std_logic_vector(7 downto 0)
      );
    end component;

  signal mode_tb :      std_logic_vector(1 downto 0)    := (others => '0');
  signal adr_tb :       std_logic_vector(7 downto 0)    := (others => '0');

  begin

    uut: K2 port map(
      mode => mode_tb,
      adr => adr_tb
      );

    stim_proc: process
    begin

      wait for 100 ns;

      mode_tb <= "00";                  -- 0

      wait for 100 ns;

      mode_tb <= "11";                  -- 3

      wait for 100 ns;

      mode_tb <= "01";                  -- 1
      
    end process;

end architecture behaviour;
