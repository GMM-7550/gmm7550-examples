library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tap_ctrl is
  generic (
    IR_LENGHT : integer := 2;
    IDCODE    : std_logic_vector(IR_LENGHT-1 downto 0);
    BPCODE    : std_logic_vector(IR_LENGHT-1 downto 0) := (others => '1');

    MANUFACTURER_ID : std_logic_vector(10 downto 0) := (others => '0');
    PART_NUMBER     : std_logic_vector(15 downto 0) := (others => '0');
    VERSION         : std_logic_vector( 3 downto 0) := (others => '0'));
  port (
    reset  : in  std_logic;
    tck    : in  std_logic;
    tms    : in  std_logic;
    tdi    : in  std_logic;
    tdo    : out std_logic;
    tdo_en : out std_logic;

    instr  : out std_logic_vector(IR_LENGHT-1 downto 0);
    i_upd  : out std_logic;

    tlr    : out std_logic;
    rti    : out std_logic;

    sdi    : in  std_logic;
    capture: out std_logic;
    shift  : out std_logic;
    update : out std_logic);
end entity tap_ctrl;

architecture rtl of tap_ctrl is
  constant ID_LENGTH : integer := 32;
  constant CORE_ID : std_logic_vector(ID_LENGTH-1 downto 0) := VERSION & PART_NUMBER & MANUFACTURER_ID & '1';

  type tap_fsm_t is (TLR_ST, -- Test Logic Reset
                     RTI_ST, -- Run Test / Idle
                     SDR_ST, -- Select DR Scan
                     SIR_ST, -- Select IR Scan
                     CDR_ST, -- Capture DR
                     CIR_ST, -- Capture IR
                     SHD_ST, -- Shift DR
                     SHI_ST, -- Shift IR
                     E1D_ST, -- Exit-1 DR
                     E1I_ST, -- Exit-1 IR
                     PDR_ST, -- Pause DR
                     PIR_ST, -- Pause IR
                     E2D_ST, -- Exit-2 DR
                     E2I_ST, -- Exit-2 IR
                     UDR_ST, -- Update DR
                     UIR_ST  -- UPDATE IR
                     );
  signal tap_state : tap_fsm_t;
  signal tap_next  : tap_fsm_t;

  -- signal tlr       : std_logic;
  -- signal rti       : std_logic;

  signal ir_capt   : std_logic;
  signal ir_shift  : std_logic;
  signal ir_update : std_logic;

  signal dr_capt   : std_logic;
  signal dr_shift  : std_logic;
  signal dr_update : std_logic;

  signal bp_reg    : std_logic; -- bypass register
  signal id_reg    : std_logic_vector(ID_LENGTH-1 downto 0);

  signal ir_sreg   : std_logic_vector(IR_LENGHT-1 downto 0);
  signal ir_latch  : std_logic_vector(IR_LENGHT-1 downto 0);
begin

  capture <= dr_capt;
  shift   <= dr_shift;
  update  <= dr_update;

  -- Current instruction
  instr <= ir_latch;
  i_upd <= ir_update;

  tap_fsm_reg: process (tck, reset) is
  begin
    if reset = '1' then
      tap_state <= TLR_ST;
    elsif rising_edge(tck) then
      tap_state <= tap_next;
    end if;
  end process tap_fsm_reg;

  tap_fsm_p: process (tap_state, tms) is
  begin

    tlr <= '0';
    rti <= '0';

    ir_capt   <= '0';
    ir_shift  <= '0';
    ir_update <= '0';

    dr_capt   <= '0';
    dr_shift  <= '0';
    dr_update <= '0';

    case tap_state is

      -- DR/IR Select
      when TLR_ST =>
        tlr <= '1';
        if tms = '0' then
          tap_next <= RTI_ST;
        else
          tap_next <= TLR_ST;
        end if;

      when RTI_ST =>
        rti <= '1';
        if tms = '0' then
          tap_next <= RTI_ST;
        else
          tap_next <= SDR_ST;
        end if;

      when SDR_ST =>
        if tms = '0' then
          tap_next <= CDR_ST;
        else
          tap_next <= SIR_ST;
        end if;

      when SIR_ST =>
        if tms = '0' then
          tap_next <= CIR_ST;
        else
          tap_next <= TLR_ST;
        end if;

      -- Data Register Path
      when CDR_ST =>
        dr_capt <= '1';
        if tms = '0' then
          tap_next <= SHD_ST;
        else
          tap_next <= E1D_ST;
        end if;

      when SHD_ST =>
        dr_shift <= '1';
        if tms = '0' then
          tap_next <= SHD_ST;
        else
          tap_next <= E1D_ST;
        end if;

      when E1D_ST =>
        if tms = '0' then
          tap_next <= PDR_ST;
        else
          tap_next <= UDR_ST;
        end if;

      when PDR_ST =>
        if tms = '0' then
          tap_next <= PDR_ST;
        else
          tap_next <= E2D_ST;
        end if;

      when E2D_ST =>
        if tms = '0' then
          tap_next <= SHD_ST;
        else
          tap_next <= UDR_ST;
        end if;

      when UDR_ST =>
        dr_update <= '1';
        if tms = '0' then
          tap_next <= RTI_ST;
        else
          tap_next <= SDR_ST;
        end if;

      -- Instruction Register Path
      when CIR_ST =>
        ir_capt <= '1';
        if tms = '0' then
          tap_next <= SHI_ST;
        else
          tap_next <= E1I_ST;
        end if;

      when SHI_ST =>
        ir_shift <= '1';
        if tms = '0' then
          tap_next <= SHI_ST;
        else
          tap_next <= E1I_ST;
        end if;

      when E1I_ST =>
        if tms = '0' then
          tap_next <= PIR_ST;
        else
          tap_next <= UIR_ST;
        end if;

      when PIR_ST =>
        if tms = '0' then
          tap_next <= PIR_ST;
        else
          tap_next <= E2I_ST;
        end if;

      when E2I_ST =>
        if tms = '0' then
          tap_next <= SHI_ST;
        else
          tap_next <= UIR_ST;
        end if;

      when UIR_ST =>
        ir_update <= '1';
        if tms = '0' then
          tap_next <= RTI_ST;
        else
          tap_next <= SDR_ST;
        end if;

    end case;
  end process tap_fsm_p;

  ir_shift_p: process (tck)
  begin
    if rising_edge(tck) then
      if ir_capt = '1' then
        ir_sreg <= std_logic_vector(to_unsigned(1, IR_LENGHT));
      elsif ir_shift = '1' then
        ir_sreg <= tdi & ir_sreg(ir_sreg'left downto 1);
      end if;
    end if;
  end process ir_shift_p;

  ir_latch_p: process (tck)
  begin
    if falling_edge(tck) then
      if tlr = '1' then
        ir_latch <= IDCODE; -- or BYPASS
      elsif ir_update = '1' then
        ir_latch <= ir_sreg;
      end if;
    end if;
  end process ir_latch_p;

  tdo_en_p: process (tck)
  begin
    if falling_edge(tck) then
      if ir_shift = '1' or dr_shift = '1' then
        tdo_en <= '1';
      else
        tdo_en <= '0';
      end if;
    end if;
  end process tdo_en_p;

  id_reg_p: process (tck)
  begin
    if rising_edge(tck) then
      if dr_capt = '1' then
        id_reg <= CORE_ID;
      elsif dr_shift = '1' then
        id_reg <= tdi & id_reg(id_reg'left downto 1);
      end if;
    end if;
  end process id_reg_p;

  bp_reg_p: process (tck)
  begin
    if rising_edge(tck) then
      if dr_capt = '1' then -- TODO: only if selected by the current instruction
        bp_reg <= '0';
      elsif dr_shift = '1' then
        bp_reg <= tdi;
      end if;
    end if;
  end process bp_reg_p;

  tdo_p: process (tck)
  begin
    if falling_edge(tck) then
      if ir_shift = '1' then
        tdo <= ir_sreg(0);
      elsif dr_shift = '1' then
        if ir_latch = IDCODE then
          tdo <= id_reg(0);
        elsif ir_latch = BPCODE or ir_latch = std_logic_vector(to_unsigned(0, IR_LENGHT)) then
          tdo <= bp_reg;
        else
          tdo <= sdi;
        end if;
      else
        tdo <= '1';
      end if;
    end if;
  end process tdo_p;

end architecture rtl;
