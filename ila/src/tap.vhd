library ieee;
use ieee.std_logic_1164.all;

library cc;
use cc.gatemate.all;

entity tap is
  generic (
    DATA_WIDTH : integer := 8;
    ADDR_WIDTH : integer := 10;
    CSR_WIDTH  : integer := 8);
  port (
    reset  : in  std_logic;
    tck_i  : in  std_logic;
    tms_i  : in  std_logic;
    tdi_i  : in  std_logic;
    tdo_o  : out std_logic;

    -- System clock domain
    clk    : in  std_logic;
    cmd    : out std_logic_vector(CSR_WIDTH-1  downto 0);
    status : in  std_logic_vector(CSR_WIDTH-1  downto 0);
    t_mask : out std_logic_vector(DATA_WIDTH-1 downto 0);
    t_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    t_post : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    t_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0)
    );
end entity tap;

architecture rtl of tap is
  constant IR_LENGHT : integer := 4;
  constant SHIFT_LENGTH_MAX : integer := maximum(DATA_WIDTH+1, ADDR_WIDTH);

  constant I_STATUS : std_logic_vector(IR_LENGHT-1 downto 0) := "1000";
  constant I_CMD    : std_logic_vector(IR_LENGHT-1 downto 0) := "1000";
  constant I_DATA   : std_logic_vector(IR_LENGHT-1 downto 0) := "1001";
  constant I_T_MASK : std_logic_vector(IR_LENGHT-1 downto 0) := "1010";
  constant I_T_DATA : std_logic_vector(IR_LENGHT-1 downto 0) := "1011";
  constant I_ADDR   : std_logic_vector(IR_LENGHT-1 downto 0) := "1100";
  constant I_T_POST : std_logic_vector(IR_LENGHT-1 downto 0) := "1101";
  constant I_T_ADDR : std_logic_vector(IR_LENGHT-1 downto 0) := "1110";

  signal tck_b : std_logic;
  signal tck, tms, tdi, tdo, tdo_en : std_logic;
  signal tlr, rti : std_logic;
  signal sdi, capture, shift, update : std_logic;
  signal d_shift : std_logic_vector(SHIFT_LENGTH_MAX-1 downto 0);

  signal cmd_latch    : std_logic_vector(CSR_WIDTH-1  downto 0);
  signal t_mask_latch : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal t_data_latch : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal t_post_latch : std_logic_vector(ADDR_WIDTH-1 downto 0);

  signal instr : std_logic_vector(IR_LENGHT-1 downto 0);
  signal i_upd : std_logic;
  signal shift_length : integer range 1 to SHIFT_LENGTH_MAX;
begin

  cmd <= (others => '0');
  -- status
  t_mask <= (others => '0');
  t_data <= (others => '0');
  t_post <= (others => '0');

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
      IR_LENGHT => IR_LENGHT,
      IDCODE    => "0001",
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

      instr  => instr,
      i_upd  => i_upd,

      sdi    => sdi,
      capture=> capture,
      shift  => shift,
      update => update);

  process(tck) is
  begin
    if rising_edge(tck) then
      if tlr = '1' then
        shift_length <= 1;
      elsif i_upd = '1' then
        case instr is
          when I_STATUS => shift_length <= CSR_WIDTH;
          when I_DATA   => shift_length <= DATA_WIDTH+1;
          when I_T_MASK => shift_length <= DATA_WIDTH;
          when I_T_DATA => shift_length <= DATA_WIDTH;
          when I_ADDR   => shift_length <= ADDR_WIDTH;
          when I_T_POST => shift_length <= ADDR_WIDTH;
          when I_T_ADDR => shift_length <= ADDR_WIDTH;
          when others => shift_length <= 1;
        end case;
      end if;
    end if;
  end process;

  sdi <= d_shift(SHIFT_LENGTH_MAX - shift_length);

  shift_reg_p: process (tlr, tck)
  begin
    if tlr = '1' then
      d_shift <= (others =>'0');
    elsif rising_edge(tck) then
      if capture = '1' then
        case instr is

          when I_STATUS =>
            d_shift(d_shift'left downto d_shift'left - CSR_WIDTH + 1) <= status;

          when I_DATA =>
            -- DPRAM read data
            d_shift(d_shift'left downto d_shift'left - DATA_WIDTH + 2) <= (others => '0');

          when I_T_ADDR =>
            d_shift(d_shift'left downto d_shift'left - ADDR_WIDTH +1) <= t_addr;

          when others => d_shift <= (others => '0');
        end case;
      elsif shift = '1' then
        d_shift <= tdi & d_shift(d_shift'left downto 1);
      end if;
    end if;
  end process;

  latch_reg_p: process (reset, tck)
  begin
    if reset = '1' then
      cmd_latch    <= (others => '0');
      t_mask_latch <= (others => '0');
      t_data_latch <= (others => '0');
      t_post_latch <= (others => '0');
    elsif falling_edge(tck) then
      if update = '1' then
        case instr is

          when I_CMD =>
            cmd_latch <= d_shift(d_shift'left downto d_shift'left - CSR_WIDTH + 1);

          when I_T_MASK =>
            t_mask_latch <= d_shift(d_shift'left downto d_shift'left - DATA_WIDTH + 1);

          when I_T_DATA =>
            t_data_latch <= d_shift(d_shift'left downto d_shift'left - DATA_WIDTH + 1);

          when I_T_POST =>
            t_post_latch <= d_shift(d_shift'left downto d_shift'left - ADDR_WIDTH + 1);

          when others => null;
        end case;
      end if;
    end if;
  end process latch_reg_p;

end architecture rtl;
