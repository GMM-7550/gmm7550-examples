library ieee;
use ieee.std_logic_1164.all;

library cc;
use cc.gatemate.all;

entity tap is
  port (
    reset : in  std_logic;
    tck_i : in  std_logic;
    tms_i : in  std_logic;
    tdi_i : in  std_logic;
    tdo_o : out std_logic;

    do    : out std_logic_vector(3 downto 0));
end entity tap;

architecture rtl of tap is
  signal tck_b : std_logic;
  signal tck, tms, tdi, tdo, tdo_en : std_logic;
  signal tlr, rti : std_logic;
  signal sdi, capture, shift, update : std_logic;
  signal d_shift : std_logic_vector(3 downto 0);
  signal d_latch : std_logic_vector(3 downto 0);
begin

  i_tck: component CC_IBUF
    generic map (
      PIN_NAME => "IO_WA_A5",
      V_IO => "2.5V",
      SCHMITT_TRIGGER => 1)
    port map (
      I => tck_i,
      Y => tck_b);

  i_tckg: component CC_BUFG
    port map (
      I => tck_b,
      O => tck);

  i_tms: component CC_IBUF
    generic map (
      PIN_NAME => "IO_WA_B4",
      SCHMITT_TRIGGER => 1)
    port map (
      I => tms_i,
      Y => tms);

  i_tdi: component CC_IBUF
    generic map (
      PIN_NAME => "IO_WA_A4")
    port map (
      I => tdi_i,
      Y => tdi);

  i_tdo: component CC_TOBUF
    generic map (
      PIN_NAME => "IO_WA_B3")
    port map (
      A => tdo,
      T => not tdo_en,
      O => tdo_o);

  i_tap_ctrl: entity work.tap_ctrl
    generic map (
      IDCODE  => "01",
      MANUFACTURER_ID => "11101110000",
      PART_NUMBER => x"c0ff",
      VERSION => x"1"
      )
    port map (
      reset  => reset,
      tck    => tck,
      tms    => tms,
      tdi    => tdi,
      tdo    => tdo,
      tdo_en => tdo_en,

      tlr    => tlr,
      rti    => rti,

      instr  => open,
      i_upd  => open,

      sdi    => sdi,
      capture=> capture,
      shift  => shift,
      update => update);

  do <= d_latch;
  sdi <= d_shift(0);

  shift_reg_p: process (tlr, tck)
  begin
    if tlr = '1' then
      d_shift <= (others => '0');
    elsif rising_edge(tck) then
      if shift = '1' then
        d_shift <= tdi & d_shift(d_shift'left downto 1);
      end if;
    end if;
  end process shift_reg_p;

  latch_reg_p: process (tlr, tck)
  begin
    if tlr = '1' then
      d_latch <= (others => '0');
    elsif falling_edge(tck) then
      if update = '1' then
        d_latch <= d_shift;
      end if;
    end if;
  end process latch_reg_p;

end architecture rtl;
