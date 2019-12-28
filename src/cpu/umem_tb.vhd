-- umem_tb.vhd
-- Testbench for micro memory umem.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity umem_tb is
end umem_tb;

architecture behaviour of umem_tb is

  component umem
    port(
      adr :      in std_logic_vector(7 downto 0);
      data :     out std_logic_vector(22 downto 0)
      );
    end component;

  signal adr_tb :        std_logic_vector(7 downto 0)   := (others => '0');
  signal data_tb :       std_logic_vector(22 downto 0)  := (others => '0');

  begin

    uut: umem port map(
      adr => adr_tb,
      data => data_tb
      );

    stim_proc: process
    begin

      wait for 100 ns;

      adr_tb <= x"00";

      wait for 100 ns;

      adr_tb <= x"FF";

      wait;
      
    end process;

end architecture behaviour;
