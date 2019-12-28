-- cpu.vhd
-- This file contains the implementation of the whole CPU.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cpu is
  port(
    clk         : in std_logic                          := '0';
    rst         : in std_logic                          := '0';

    vm_x_out    : inout std_logic_vector(15 downto 0)   := (others => 'Z');
    vm_y_out    : out std_logic_vector(7 downto 0)      := (others => '0');
    vm_bus_out  : out std_logic_vector(9 downto 0)      := (others => '0');

    kbd_in      : in std_logic                          := '0';
    kbd_out     : out std_logic_vector(4 downto 0)      := (others => '0');
    kbd_r       : out std_logic                         := '0'
    );
end cpu;

architecture behaviour of cpu is

  -----------------------------------------------------------------------------
  --------------------------------- COMPONENTS --------------------------------
  -----------------------------------------------------------------------------

  component alu
    port(
      clk       : in std_logic;
      rst       : in std_logic;
      A         : in unsigned(15 downto 0);
      B         : in unsigned(15 downto 0);
      op        : in std_logic_vector(3 downto 0);
      status    : out std_logic_vector(3 downto 0);
      output    : out unsigned(15 downto 0)
      );
    end component alu;

  component K1
    port(
      op        : in std_logic_vector(5 downto 0);
      adr       : out std_logic_vector(7 downto 0)
      );
    end component K1;

  component K2
    port(
      mode      : in std_logic_vector(1 downto 0);
      adr       : out std_logic_vector(7 downto 0)
      );
    end component K2;

  component umem
    port(
      adr       : in std_logic_vector(7 downto 0);
      data      : out std_logic_vector(29 downto 0)
      );
    end component umem;

  component program_mem
    port(
      clk       : in std_logic;
      adr       : in std_logic_vector(9 downto 0);
      instr     : out std_logic_vector(19 downto 0)
      );
    end component program_mem;

  -----------------------------------------------------------------------------
  ------------------------------- MEMORY --------------------------------------
  -----------------------------------------------------------------------------

  -- REGISTER FILE
  type reg_arr is array (0 to 15) of std_logic_vector(15 downto 0);
  signal REG_FILE : reg_arr := (others => (others => '0'));

  -- DATA MEMORY
  type data_arr is array (0 to 31) of std_logic_vector(15 downto 0);
  signal DATA_MEM : data_arr := (others => (others => '0'));
  
  -----------------------------------------------------------------------------
  ------------------------------ CONSTANTS ------------------------------------
  -----------------------------------------------------------------------------
  
  -- Bus ports
  constant NOP_PORT             : std_logic_vector(3 downto 0)  := b"0000";
  constant ALU_PORT             : std_logic_vector(3 downto 0)  := b"0001";
  constant ADR_PORT             : std_logic_vector(3 downto 0)  := b"0010";
  constant AR_PORT              : std_logic_vector(3 downto 0)  := b"0011";
  
  constant SP_PORT              : std_logic_vector(3 downto 0)  := b"0100";
  constant PC_PORT              : std_logic_vector(3 downto 0)  := b"0101";
  constant IR_PORT              : std_logic_vector(3 downto 0)  := b"0110";
  constant REG_PORT             : std_logic_vector(3 downto 0)  := b"0111";
  
  constant HR_PORT              : std_logic_vector(3 downto 0)  := b"1000";
  constant DATA_PORT            : std_logic_vector(3 downto 0)  := b"1001";
  
  constant VM_X_PORT            : std_logic_vector(3 downto 0)  := b"1010";
  constant VM_Y_PORT            : std_logic_vector(3 downto 0)  := b"1011";
  constant VM_BUS_PORT          : std_logic_vector(3 downto 0)  := b"1100";

  constant KBD_OUT_PORT         : std_logic_vector(3 downto 0)  := b"1101";
  constant KBD_IN_PORT          : std_logic_vector(3 downto 0)  := b"1110";

  -- REGS
  constant REG_LEFT             : std_logic_vector(1 downto 0)  := b"00";
  constant REG_RIGHT            : std_logic_vector(1 downto 0)  := b"01";
  constant REG_DM               : std_logic_vector(1 downto 0)  := b"10";
  constant REG_FULL             : std_logic_vector(1 downto 0)  := b"11";

  -- SEQ
  constant SEQ_INC              : std_logic_vector(3 downto 0) := b"0000";  --Increment
  constant SEQ_K1               : std_logic_vector(3 downto 0) := b"0001";  --uPC=K1
  constant SEQ_K2               : std_logic_vector(3 downto 0) := b"0010";  --uPC=K2
  constant SEQ_NUL              : std_logic_vector(3 downto 0) := b"0011";  --uPC=0

  constant SEQ_UADR             : std_logic_vector(3 downto 0) := b"0100";  --uPC=uAdr
  constant SEQ_JSR              : std_logic_vector(3 downto 0) := b"0101";  --JumpToSubroutine
  constant SEQ_RSR              : std_logic_vector(3 downto 0) := b"0110";  --ReturnFromSubroutine
  --constant SEQ_NOP              : std_logic_vector(3 downto 0) := b"0111";

  constant SEQ_JIZ              : std_logic_vector(3 downto 0) := b"1000";  --JumpIfZ
  constant SEQ_JIN              : std_logic_vector(3 downto 0) := b"1001";  --JumpIfN
  constant SEQ_JIC              : std_logic_vector(3 downto 0) := b"1010";  --JumpIfC
  constant SEQ_JIO              : std_logic_vector(3 downto 0) := b"1011";  --JumpIfO

  --constant SEQ_NOP              : std_logic_vector(3 downto 0) := b"1100";
  --constant SEQ_NOP              : std_logic_vector(3 downto 0) := b"1101";
  --constant SEQ_NOP              : std_logic_vector(3 downto 0) := b"1110";
  constant SEQ_HALT             : std_logic_vector(3 downto 0) := b"1111";  --HALT

  -- SP
  constant SP_NOP               : std_logic_vector(1 downto 0) := b"00";
  constant SP_INC               : std_logic_vector(1 downto 0) := b"01";
  constant SP_DEC               : std_logic_vector(1 downto 0) := b"10";
  constant SP_NUL               : std_logic_vector(1 downto 0) := b"11";

  -- OPERATIONS
  constant OP_DRW               : std_logic_vector(5 downto 0) := b"110000";
  constant OP_FWDB              : std_logic_vector(5 downto 0) := b"110001";

  -----------------------------------------------------------------------------
  -------------------------------SIGNALS & ALIASES-----------------------------
  -----------------------------------------------------------------------------

  signal RUNNING        : std_logic                             := '1';

  -- MICRO MEMORY
  signal uPC            : unsigned(7 downto 0)                  := (others => '0');
  signal IR             : std_logic_vector(19 downto 0)         := (others => '0');
  signal uInstr         : std_logic_vector(29 downto 0)         := (others => '0');
  signal uSP            : unsigned(7 downto 0)                  := (others => '0');
  
  alias ALU_INSTR       : std_logic_vector(3 downto 0)          is uInstr(29 downto 26);
  alias TB_INSTR        : std_logic_vector(3 downto 0)          is uInstr(25 downto 22);
  alias FB_INSTR        : std_logic_vector(3 downto 0)          is uInstr(21 downto 18);
  alias REG_INSTR       : std_logic_vector(1 downto 0)          is uInstr(17 downto 16);
  alias SP_INSTR        : std_logic_vector(1 downto 0)          is uInstr(15 downto 14);
  alias PC_INSTR        : std_logic                             is uInstr(13);
  alias IR_INSTR        : std_logic                             is uInstr(12);
  alias SEQ_INSTR       : std_logic_vector(3 downto 0)          is uInstr(11 downto 8);
  alias UADDR_INSTR     : std_logic_vector(7 downto 0)          is uInstr(7 downto 0);

  alias IR_OP           : std_logic_vector(5 downto 0)          is IR(19 downto 14);
  alias IR_MODE         : std_logic_vector(1 downto 0)          is IR(13 downto 12);
  alias IR_R1           : std_logic_vector(3 downto 0)          is IR(11 downto 8);
  alias IR_R2           : std_logic_vector(3 downto 0)          is IR(3 downto 0);
  alias IR_DM           : std_logic_vector(7 downto 0)          is IR(7 downto 0);

  -- PROGRAM
  signal PC             : unsigned(9 downto 0)                  := (others => '0');
  signal DATA_BUS       : std_logic_vector(15 downto 0)         := (others => '0');
  signal ADR            : std_logic_vector(7 downto 0)          := (others => '0');
  signal SR             : std_logic_vector(3 downto 0)          := (others => '0');
  signal SP             : std_logic_vector(7 downto 0)          := x"1F";
  signal AR             : unsigned(15 downto 0)                 := (others => '0');
  signal HR             : std_logic_vector(15 downto 0)         := (others => '0');

  alias Z_FLAG          : std_logic                             is SR(3);
  alias N_FLAG          : std_logic                             is SR(2);
  alias C_FLAG          : std_logic                             is SR(1);
  alias O_FLAG          : std_logic                             is SR(0);

  -- VMEM
  signal VM_X           : std_logic_vector(15 downto 0)         := (others => '0');
  signal VM_Y           : std_logic_vector(7 downto 0)          := (others => '0');
  signal VM_BUS         : std_logic_vector(9 downto 0)          := (others => '0');

  -- KEYBOARD
  signal KBD_DATA       : std_logic_vector(4 downto 0)          := (others => '0');

  -- COMPONENT HELP SIGNALS
  
  -- ALU
  signal ALU_A          : unsigned(15 downto 0)         := (others => '0');
  signal ALU_B          : unsigned(15 downto 0)         := (others => '0');
  signal ALU_OUT        : unsigned(15 downto 0)         := (others => '0');
  signal ALU_OP         : std_logic_vector(3 downto 0)  := (others => '0');

  -- K1
  signal K1_ADR         : std_logic_vector(7 downto 0)  := (others => '0');

  -- K2
  signal K2_ADR         : std_logic_vector(7 downto 0)  := (others => '0');

  -- PROGRAM MEM
  signal PM_ADR         : std_logic_vector(9 downto 0)  := (others => '0');
  signal PM_INSTR       : std_logic_vector(19 downto 0) := (others => '0');
  
  begin

    ---------------------------------------------------------------------------
    -----------------------PORT DECLARATIONS-----------------------------------
    ---------------------------------------------------------------------------
    
    alu_c: alu port map(
      clk               => clk,
      rst               => rst,
      A                 => ALU_A,
      B                 => ALU_B,
      op                => ALU_OP,
      status            => SR,
      output            => ALU_OUT
      );

    k1_c: K1 port map(
      op                => IR_OP,
      adr               => K1_ADR
      );

    k2_c: K2 port map(
      mode              => IR_MODE,
      adr               => K2_ADR
      );

    umem_c: umem port map(
      adr               => std_logic_vector(uPC),
      data              => uInstr
      );

    pm_c: program_mem port map(
      clk               => clk,
      adr               => PM_ADR,
      instr             => PM_INSTR
      );

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------

    -- uPC
    process(clk)
    begin
      if rising_edge(clk) then
      if (RUNNING = '1') then
      if (rst = '1') then
        uPC <= (others => '0');
      else

        case SEQ_INSTR is
          when SEQ_INC  => uPC <= uPC + 1;
          when SEQ_K1   => uPC <= unsigned(K1_ADR);
          when SEQ_K2   => uPC <= unsigned(K2_ADR);
          when SEQ_NUL  => uPC <= (others => '0');
                           
          when SEQ_UADR => uPC <= unsigned(UADDR_INSTR);
          when SEQ_JSR  => uSP <= uPC + 1;
                           uPC <= unsigned(UADDR_INSTR);
          when SEQ_RSR  => uPC <= uSP;
                           
          when SEQ_JIZ => if (Z_FLAG = '1' ) then
                            uPC <= unsigned(UADDR_INSTR);
                          else
                            uPC <= uPC + 1;
                          end if;
          when SEQ_JIN => if (N_FLAG = '1' ) then
                            uPC <= unsigned(UADDR_INSTR);
                          else
                            uPC <= uPC + 1;
                          end if;
          when SEQ_JIC => if (C_FLAG = '1' ) then
                            uPC <= unsigned(UADDR_INSTR);
                          else
                            uPC <= uPC + 1;
                          end if;
          when SEQ_JIO => if (O_FLAG = '1' ) then
                            uPC <= unsigned(UADDR_INSTR);
                          else
                            uPC <= uPC + 1;
                          end if;
                          
          when SEQ_HALT => uPC <= (others => '0');
                           RUNNING <= '0';
          when others => null;
        end case;
        
      end if;
      end if;
      end if;
    end process;

    -- PC
    process(clk)
    begin
      if rising_edge(clk) then
      if (rst = '1') then
        PC <= (others => '0');
      elsif (FB_INSTR = PC_PORT) then
        PC <= unsigned(DATA_BUS(9 downto 0));
      elsif (PC_INSTR = '1') then
        PC <= PC + 1;
      else
        PC <= PC;
      end if;
      end if;
    end process;

    -- Address Register (ADR)
    process(clk)
    begin
      if rising_edge(clk) then
      if (rst = '1') then
        ADR <= (others => '0');
      elsif (FB_INSTR = ADR_PORT) then
        ADR <= DATA_BUS(7 downto 0);
      else
        ADR <= ADR;
      end if;
      end if;
    end process;

    -- Stack Pointer (SP)
    process(clk)
    begin
      if rising_edge(clk) then
      if (rst = '1') then
        SP <= (others => '0');
      elsif (FB_INSTR = SP_PORT) then
        SP <= DATA_BUS(7 downto 0);
      else
        case SP_INSTR is
          when SP_NOP   => null;
          when SP_INC   => if (unsigned(SP) > 0) then
                             SP <= std_logic_vector(unsigned(SP) - 1);
                           else
                             SP <= SP;
                           end if;
          when SP_DEC   => if (unsigned(SP) < 1023) then
                             SP <= std_logic_vector(unsigned(SP) + 1);
                           else
                             SP <= SP;
                           end if;
          when SP_NUL   => SP <= (others => '0');
          when others   => null;
         end case;
      end if;
      end if;
    end process;

    -- REGISTERS
    process(clk)
    begin
      if rising_edge(clk) then
      if (rst = '1') then
        REG_FILE(0 to 15) <= (others => (others => '0'));
      elsif (FB_INSTR = REG_PORT and REG_INSTR = REG_LEFT) then
        REG_FILE(to_integer(unsigned(IR_R1))) <= DATA_BUS;
      elsif (FB_INSTR = REG_PORT and REG_INSTR = REG_RIGHT) then
        REG_FILE(to_integer(unsigned(IR_R2))) <= DATA_BUS;
      else
        REG_FILE <= REG_FILE;
      end if;
      end if;
    end process;

    -- ALU
    process(clk)
    begin
      if rising_edge(clk) then
      if (rst = '1') then
        ALU_A           <= (others => '0');
        ALU_B           <= (others => '0');
      elsif (FB_INSTR = ALU_PORT) then
        ALU_A   <= unsigned(DATA_BUS);
        ALU_B   <= AR;
        ALU_OP  <= ALU_INSTR;
      else
        ALU_A <= ALU_A;
        ALU_B <= ALU_B;
      end if;
      end if;
    end process;
    AR <= (others => '0') when (rst = '1') else ALU_OUT;

    -- Help Register (HR)
    process(clk)
    begin
      if rising_edge(clk) then
      if (rst = '1') then
        HR <= (others => '0');
      elsif (FB_INSTR = HR_PORT) then
        HR <= DATA_BUS;
      else
        HR <= HR;
      end if;
      end if;
    end process;

    -- Data memory
    process(clk)
    begin
      if rising_edge(clk) then
      if (rst = '1') then
        DATA_MEM <= (others => (others => '0'));
      elsif (FB_INSTR = DATA_PORT) then
        DATA_MEM(to_integer(unsigned(ADR))) <= DATA_BUS;
      else
        DATA_MEM <= DATA_MEM;
      end if;
      end if;
    end process;

    -- Program memory & IR
    process(clk)
    begin
      if rising_edge(clk) then
      if (rst = '1') then
        IR <= (others => '0');
      elsif (IR_INSTR = '1') then
        IR <= PM_INSTR;
      else
        IR <= IR;
      end if;
      end if;
    end process;
    PM_ADR <= std_logic_vector(PC);

    -- Video Memory
    process(clk)
    begin
      if rising_edge(clk) then
      if (rst = '1') then
        VM_X          <= (others => '0');
        VM_Y          <= (others => '0');
        VM_BUS        <= (others => '0');
      elsif (FB_INSTR = VM_X_PORT) then
        VM_X          <= DATA_BUS;
      elsif (FB_INSTR = VM_Y_PORT) then
        VM_Y          <= DATA_BUS(7 downto 0);
      elsif (FB_INSTR = VM_BUS_PORT) then 
        VM_BUS        <= DATA_BUS(9 downto 0);
      else
        VM_X          <= VM_X;
        VM_Y          <= VM_Y;
        VM_BUS        <= VM_BUS;
      end if;
      end if;
    end process;

    -- Keyboard
    process(clk)
    begin
      if rising_edge(clk) then
      if (rst = '1') then
        KBD_DATA <= (others => '0');
      elsif (FB_INSTR = KBD_OUT_PORT) then
        KBD_DATA <= DATA_BUS(4 downto 0);
      else
        KBD_DATA <= KBD_DATA;
      end if;
      end if;
    end process;
        
    -- Set DATA_BUS
    DATA_BUS <= (others => '0')                                 when (TB_INSTR = NOP_PORT) else
                (7 downto 0 => '0') & ADR                       when (TB_INSTR = ADR_PORT) else
                std_logic_vector(AR)                            when (TB_INSTR = AR_PORT) else
                (7 downto 0 => '0') & SP                        when (TB_INSTR = SP_PORT) else
                (5 downto 0 => '0') & std_logic_vector(PC)      when (TB_INSTR = PC_PORT) else
                HR                                              when (TB_INSTR = HR_PORT) else
                (11 downto 0 => '0') & IR_R1                    when (TB_INSTR = IR_PORT and REG_INSTR = REG_LEFT) else
                (11 downto 0 => '0') & IR_R2                    when (TB_INSTR = IR_PORT and REG_INSTR = REG_RIGHT) else
                (7 downto 0 => '0') & IR_DM                     when (TB_INSTR = IR_PORT and REG_INSTR = REG_DM) else
                PM_INSTR(15 downto 0)                           when (TB_INSTR = IR_PORT and REG_INSTR = REG_FULL) else
                REG_FILE(to_integer(unsigned(IR_R1)))           when (TB_INSTR = REG_PORT and REG_INSTR = REG_LEFT) else
                REG_FILE(to_integer(unsigned(IR_R2)))           when (TB_INSTR = REG_PORT and REG_INSTR = REG_RIGHT) else
                DATA_MEM(to_integer(unsigned(ADR)))             when (TB_INSTR = DATA_PORT) else
                VM_X                                            when (TB_INSTR = VM_X_PORT) else
                (7 downto 0 => '0') & VM_Y                      when (TB_INSTR = VM_Y_PORT) else
                (14 downto 0 => '0') & KBD_IN                   when (TB_INSTR = KBD_IN_PORT) else
                (others => '0');

    -- OUTPUT
    vm_x_out            <= VM_X when (IR_OP = OP_DRW) else (others => 'Z');
    vm_y_out            <= VM_Y;
    vm_bus_out          <= VM_BUS;

    kbd_out             <= KBD_DATA;
    kbd_r               <= '1' when (TB_INSTR = KBD_IN_PORT) else '0';

end architecture behaviour;
