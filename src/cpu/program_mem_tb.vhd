-- program_mem_tb.vhd
-- Testbench for program memory.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity program_mem_tb is
end program_mem_tb;

architecture behaviour of program_mem_tb is

  component program_mem
    port(
      adr :      in std_logic_vector(9 downto 0);
      instr :    out std_logic_vector(19 downto 0)
      );
    end component;

  signal adr_tb :        std_logic_vector(9 downto 0)   := (others => '0');
  signal instr_tb :      std_logic_vector(19 downto 0)  := (others => '0');
  signal clk_tb :        std_logic                      := '0';

  signal tb_running : boolean := true;

  begin

    uut: program_mem port map(
      adr => adr_tb,
      instr => instr_tb
      );

    clk_gen : process
    begin
      while tb_running loop
        clk_tb <= '0';
        wait for 5 ns;
        clk_tb <= '1';
        wait for 5 ns;
      end loop;
      wait;
    end process;

    stim_proc: process
    begin

      wait until rising_edge(clk_tb);

      adr_tb <= b"0000000000";

      wait until rising_edge(clk_tb);

      adr_tb <= b"1111111111";

      wait;
      
    end process;

end architecture behaviour;
