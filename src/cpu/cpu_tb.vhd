-- reg_file_tb.vhd
-- Testbench for register files.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cpu_tb is
end cpu_tb;

architecture behaviour of cpu_tb is

  component cpu
    port(
      clk :     in std_logic;
      rst :     in std_logic;

      vm_x_out    : out std_logic_vector(15 downto 0)     := (others => '0');
      vm_y_out    : out std_logic_vector(7 downto 0)      := (others => '0');
      vm_bus_out  : out std_logic_vector(9 downto 0)      := (others => '0');

      kbd_in      : in std_logic                          := '0';
      kbd_out     : out std_logic_vector(4 downto 0)      := (others => '0');
      kbd_r       : out std_logic                         := '0'
      );
    end component;

  component kbd_enc
    port(
      clk                : in std_logic;
      rst                : in std_logic;
      PS2_keyboard_clk   : in std_logic;
      PS2_keyboard_data  : in std_logic;
      data               : out std_logic_vector(4 downto 0);
      w_bit              : out std_logic;
      we                 : out std_logic
      );
    end component;

  component m_kbd
    port(
      clk            : in std_logic;
      rst            : in std_logic;
      bus_addr_in    : in std_logic_vector(4 downto 0);
      addr_in        : in std_logic_vector(4 downto 0);
      w_bit          : in std_logic;
      rst_bit        : in std_logic;
      pressed        : out std_logic
      );
    end component;

  signal clk_tb :       std_logic := '0';
  signal rst_tb :       std_logic := '0';

  signal vm_x_out_tb    :  std_logic_vector(15 downto 0)   := (others => '0');
  signal vm_y_out_tb    :  std_logic_vector(7 downto 0)    := (others => '0');
  signal vm_bus_out_tb  :  std_logic_vector(9 downto 0)    := (others => '0');

  signal kbd_in_tb   : std_logic                         := '0';
  signal kbd_out_tb  : std_logic_vector(4 downto 0)      := (others => '0');
  signal kbd_r_tb    : std_logic                         := '0';

  signal PS2_keyboard_clk_tb    : std_logic := '0';
  signal PS2_keyboard_data_tb   : std_logic := '0';
  signal data_tb            : std_logic_vector(4 downto 0) := (others => '0');
  signal w_bit_tb           : std_logic := '0';

  signal addr_out_tb    : std_logic_vector(4 downto 0) := (others => '0');


  signal tb_running : boolean := true;

  begin

    uut : cpu port map(
      clk => clk_tb,
      rst => rst_tb,

      vm_x_out => vm_x_out_tb,
      vm_y_out => vm_y_out_tb,
      vm_bus_out => vm_bus_out_tb,

      kbd_in => kbd_in_tb,
      kbd_out => kbd_out_tb,
      kbd_r => kbd_r_tb
     );

    enc : kbd_enc port map(
      clk => clk_tb,
      rst => rst_tb,

      PS2_keyboard_clk => PS2_keyboard_clk_tb,
      PS2_keyboard_data => PS2_keyboard_data_tb,
      data => data_tb,
      w_bit => w_bit_tb
    );

    m : m_kbd port map(
      clk => clk_tb,
      rst => rst_tb,

      bus_addr_in => kbd_out_tb,
      addr_in => data_tb,
      w_bit => w_bit_tb,
      rst_bit => kbd_r_tb,
      pressed => kbd_in_tb
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

      wait for 100 ns;

    end process;
  end architecture behaviour;
