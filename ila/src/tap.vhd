library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library cc;
use cc.gatemate.all;

entity tap is
  generic (
    DATA_WIDTH : integer := 20;
    ADDR_WIDTH : integer := 11;
    CSR_WIDTH  : integer := 8);
  port (
    reset  : in  std_logic;
    tck_i  : in  std_logic;
    tms_i  : in  std_logic;
    tdi_i  : in  std_logic;
    tdo_o  : out std_logic;

    clk    : in  std_logic;
    cmd    : out std_logic_vector(CSR_WIDTH-1  downto 0);
    status : in  std_logic_vector(CSR_WIDTH-1  downto 0);
    t_mask : out std_logic_vector(DATA_WIDTH-1 downto 0);
    t_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    t_post : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    t_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);

    re_o   : out std_logic;
    we_o   : out std_logic;
    addr_o : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    data_i : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data_o : out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity tap;

architecture rtl of tap is
  constant IR_LENGHT : integer := 4;
  constant SHIFT_LENGTH_MAX : integer := maximum(DATA_WIDTH, ADDR_WIDTH);

  constant I_CMD    : std_logic_vector(IR_LENGHT-1 downto 0) := "0100";
  constant I_STATUS : std_logic_vector(IR_LENGHT-1 downto 0) := "0101";
  constant I_DATA   : std_logic_vector(IR_LENGHT-1 downto 0) := "0110";
  constant I_ADDR   : std_logic_vector(IR_LENGHT-1 downto 0) := "0111";
  constant I_T_DATA : std_logic_vector(IR_LENGHT-1 downto 0) := "1000";
  constant I_T_MASK : std_logic_vector(IR_LENGHT-1 downto 0) := "1001";
  constant I_T_POST : std_logic_vector(IR_LENGHT-1 downto 0) := "1010";
  constant I_T_ADDR : std_logic_vector(IR_LENGHT-1 downto 0) := "1110";

  signal tck, tms, tdi, tdo, tdo_en : std_logic;
  signal tck_b, tms_b, tdi_b : std_logic;
  signal tck_re, tck_fe : std_logic;

  signal tlr, rti : std_logic;
  signal sdi, capture, shift, update : std_logic;
  signal d_shift : std_logic_vector(SHIFT_LENGTH_MAX-1 downto 0);

  signal read_pending : std_logic;
  signal write_pending: std_logic;
  signal incr_pending : std_logic;

  signal cmd_latch    : std_logic_vector(CSR_WIDTH-1  downto 0);
  signal addr_latch   : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal data_latch   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal t_mask_latch : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal t_data_latch : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal t_post_latch : std_logic_vector(ADDR_WIDTH-1 downto 0);

  signal instr : std_logic_vector(IR_LENGHT-1 downto 0);
  signal i_upd : std_logic;
begin

  i_tck_buf: component CC_IBUF
    generic map (
      PIN_NAME => "IO_WA_A5",
      V_IO => "2.5V",
      SCHMITT_TRIGGER => 1)
    port map (
      I => tck_i,
      Y => tck_b);

  i_tms_buf: component CC_IBUF
    generic map (
      PIN_NAME => "IO_WA_B4",
      SCHMITT_TRIGGER => 1)
    port map (
      I => tms_i,
      Y => tms_b);

  i_tdi_buf: component CC_IBUF
    generic map (
      PIN_NAME => "IO_WA_A4")
    port map (
      I => tdi_i,
      Y => tdi_b);

  i_tdo_buf: component CC_TOBUF
    generic map (
      PIN_NAME => "IO_WA_B3")
    port map (
      A => tdo,
      T => not tdo_en,
      O => tdo_o);

  i_tck_ddff: entity work.ddff
    port map (
      clk => clk,
      di  => tck_b,
      do  => tck);

  i_tms_ddff: entity work.ddff
    port map (
      clk => clk,
      di  => tms_b,
      do  => tms);

  i_tsi_ddff: entity work.ddff
    port map (
      clk => clk,
      di  => tdi_b,
      do  => tdi);

  i_tck_detect: entity work.edge_detect
    port map (
      clk => clk,
      di  => tck,
      re  => tck_re,
      fe  => tck_fe);

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
      clk    => clk,

      tck_re => tck_re,
      tck_fe => tck_fe,
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

  -- sdi_mux_p: process (instr, d_shift)
  sdi_mux_p: process (clk)
  begin
    if rising_edge(clk) then
      case instr is
        when I_CMD    => sdi <= d_shift(d_shift'left - CSR_WIDTH  + 1);
        when I_STATUS => sdi <= d_shift(d_shift'left - CSR_WIDTH  + 1);
        when I_DATA   => sdi <= d_shift(d_shift'left - DATA_WIDTH + 1);
        when I_ADDR   => sdi <= d_shift(d_shift'left - ADDR_WIDTH + 1);
        when I_T_MASK => sdi <= d_shift(d_shift'left - DATA_WIDTH + 1);
        when I_T_DATA => sdi <= d_shift(d_shift'left - DATA_WIDTH + 1);
        when I_T_POST => sdi <= d_shift(d_shift'left - ADDR_WIDTH + 1);
        when I_T_ADDR => sdi <= d_shift(d_shift'left - ADDR_WIDTH + 1);
        when others   => sdi <= d_shift(d_shift'left);
      end case;
    end if;
  end process sdi_mux_p;

  tap_regs_p: process (clk)
  begin
    if rising_edge(clk) then

      if tlr = '1' then
        cmd_latch    <= (others => '0');
        data_latch   <= (others => '0');
        addr_latch   <= (others => '0');
        t_mask_latch <= (others => '0');
        t_data_latch <= (others => '0');
        t_post_latch <= (others => '0');

        d_shift <= (others =>'0');

        read_pending  <= '0';
        write_pending <= '0';
        incr_pending  <= '0';
      else

        if tck_re = '1' then
          if shift = '1' then
            d_shift <= tdi & d_shift(d_shift'left downto 1);
          elsif capture = '1' then
            case instr is

              when I_CMD =>
                d_shift <= cmd_latch & std_logic_vector(to_unsigned(0, d_shift'length - CSR_WIDTH));

              when I_STATUS =>
                d_shift <= status & std_logic_vector(to_unsigned(0, d_shift'length - CSR_WIDTH));

              when I_DATA =>
                d_shift <= data_i & std_logic_vector(to_unsigned(0, d_shift'length - DATA_WIDTH));

              when I_ADDR =>
                d_shift <= addr_latch & std_logic_vector(to_unsigned(0, d_shift'length - ADDR_WIDTH));

              when I_T_ADDR =>
                d_shift <= t_addr & std_logic_vector(to_unsigned(0, d_shift'length - ADDR_WIDTH));

              when I_T_DATA =>
                d_shift <= t_data_latch & std_logic_vector(to_unsigned(0, d_shift'length - DATA_WIDTH));

              when I_T_MASK =>
                d_shift <= t_mask_latch & std_logic_vector(to_unsigned(0, d_shift'length - DATA_WIDTH));

              when I_T_POST =>
                d_shift <= t_post_latch & std_logic_vector(to_unsigned(0, d_shift'length - ADDR_WIDTH));

              when others => d_shift <= (others => '0');
            end case;
          end if;
        end if; -- tck_re

        if tck_fe = '1' and update = '1' then
          case instr is

            when I_CMD =>
              cmd_latch <= d_shift(d_shift'left downto d_shift'left - CSR_WIDTH + 1);

            when I_DATA =>
              data_latch <= d_shift(d_shift'left downto d_shift'left - DATA_WIDTH + 1);
              incr_pending  <= cmd_latch(4);
              write_pending <= cmd_latch(5);

            when I_ADDR =>
              addr_latch <= d_shift(d_shift'left downto d_shift'left - ADDR_WIDTH + 1);
              read_pending <= '1';

            when I_T_MASK =>
              t_mask_latch <= d_shift(d_shift'left downto d_shift'left - DATA_WIDTH + 1);

            when I_T_DATA =>
              t_data_latch <= d_shift(d_shift'left downto d_shift'left - DATA_WIDTH + 1);

            when I_T_POST =>
              t_post_latch <= d_shift(d_shift'left downto d_shift'left - ADDR_WIDTH + 1);

            when others => null;
          end case;
        end if;
      end if; -- tck_fe

      if read_pending = '1' then
        re_o <= '1';
        read_pending <= '0';
      else
        re_o <= '0';
      end if;

      if write_pending = '1' then
        we_o <= '1';
        write_pending <= '0';
      else
        we_o <= '0';
      end if;

      if incr_pending = '1' and write_pending = '0' then
        addr_latch <= std_logic_vector(unsigned(addr_latch) + 1);
        incr_pending <= '0';
        read_pending <= '1';
      end if;

    end if; -- rising_edge(clk)
  end process;

  addr_o <= addr_latch;
  data_o <= data_latch;

  cmd    <= cmd_latch;
  t_mask <= t_mask_latch;
  t_data <= t_data_latch;
  t_post <= t_post_latch;

end architecture rtl;
