library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tap_ctrl is
  generic (
    IR_LENGHT : integer := 2;
    IDCODE    : std_logic_vector(IR_LENGHT-1 downto 0);
    ID_LENGTH : integer := 32;
    CORE_ID   : std_logic_vector(ID_LENGTH-1 downto 0)); -- := std_logic_vector(to_unsigned(42, ID'length)));
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

    sck    : out std_logic;
    sdo    : out std_logic;
    sdi    : in  std_logic;
    shift  : out std_logic;
    update : out std_logic);
end entity tap_ctrl;

architecture rtl of tap_ctrl is
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

  -- signal bypass    : std_logic; -- bypass register
  -- signal id_reg    : std_logic_vector(ID_LENGTH-1 downto 0);

  -- signal ir_sreg   : std_logic_vector(IR_LENGHT-1 downto 0);
  signal ir_latch  : std_logic_vector(IR_LENGHT-1 downto 0);
begin

  -- Propogate input signals to external data register(s)
  sck <= tck;
  sdo <= tdi;

  tdo <= sdi; -- TODO
  shift  <= dr_shift;
  update <= dr_update;

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

    tdo_en <= '0';

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
        tdo_en <= '1';
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
        tdo_en <= '1';
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

end architecture rtl;
