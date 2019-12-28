LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY alu_tb IS
END alu_tb;

ARCHITECTURE behavior OF alu_tb IS 

  -- Component Declaration
  COMPONENT alu
    PORT(
      clk, rst: in std_logic;
      A, B: in unsigned(15 downto 0);
      op: in std_logic_vector(3 downto 0);
      status: out std_logic_vector(3 downto 0);
      output: out unsigned(15 downto 0)
      );
  END COMPONENT;

  signal clk_tb: std_logic := '0';
  signal rst_tb: std_logic := '0';
  signal in_1, in_2: unsigned(15 downto 0) := (15 downto 0 => '0');
  signal op_tb: std_logic_vector(3 downto 0) := "0000";
  signal status_tb: std_logic_vector(3 downto 0) := "0000";
  signal output_tb: unsigned(15 downto 0) := (15 downto 0 => '0');

  signal tb_running : boolean := true;

BEGIN

  -- Component Instantiation
  uut: alu PORT MAP(
    clk => clk_tb,
    rst => rst_tb,
    A => in_1,
    B => in_2,
    op => op_tb,
    status => status_tb,
    output => output_tb
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

  in_1 <= x"FFFF";
  in_2 <= x"0002";
  op_tb <= b"0001";       -- A+B
  
  wait until rising_edge(clk_tb);

  in_1 <= x"0004";
  in_2 <= x"0001";
  op_tb <= b"0010";       -- A-B

  wait until rising_edge(clk_tb);

  in_1 <= x"0004";
  in_2 <= x"0004";
  op_tb <= b"0011";       -- unsigned mul

  wait until rising_edge(clk_tb);

  in_1 <= x"FFFF";
  in_2 <= x"0001";
  op_tb <= b"0100";       -- signed mul

  wait until rising_edge(clk_tb);

  in_1 <= x"0004";
  in_2 <= x"0004";
  op_tb <= b"0101";       -- unsigned div

  wait until rising_edge(clk_tb);

  in_1 <= x"FFFF";
  in_2 <= x"0001";
  op_tb <= b"0110";       -- signed div

  wait until rising_edge(clk_tb);

  in_1 <= x"0101";
  in_2 <= x"1001";
  op_tb <= b"0111";       -- A and B

  wait until rising_edge(clk_tb);

  in_1 <= x"1001";
  in_2 <= x"0100";
  op_tb <= b"1000";       -- A or B

  wait until rising_edge(clk_tb);

  op_tb <= b"1001";       -- lsl

  wait until rising_edge(clk_tb);

  op_tb <= b"1010";       -- lsr

  wait until rising_edge(clk_tb);

  op_tb <= b"1100";       -- R = R'

  wait until rising_edge(clk_tb);

  op_tb <= b"1011";       -- R = 0

  wait until rising_edge(clk_tb);
  
  in_1 <= x"FFFF";
  in_2 <= x"0002";
  op_tb <= b"0001";     -- A + B

  

  end process;
      
end architecture behavior;
