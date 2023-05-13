library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library cc;
use cc.gatemate.all;

entity spi_bridge is
  port (
    ser_clk     : in  std_logic;
    led_green   : out std_logic;
    led_red_n   : out std_logic;

    J9_EN       : out std_logic;
    J10_EN      : out std_logic;

    -- SPI slave interface (from a baseboard)
    CFG_SPI_nCS : inout std_logic;
    CFG_SPI_CLK : inout std_logic;
    CFG_SPI_IO0 : inout std_logic; -- MOSI
    CFG_SPI_IO1 : inout std_logic; -- MISO

    -- SPI master interface (to a memory module)
    M_SPI_nCS   : out std_logic;
    M_SPI_CLK   : out std_logic;
    M_SPI_MOSI  : out std_logic;
    M_SPI_MISO  : in  std_logic;

    M_SPI_IO2   : inout std_logic;
    M_SPI_IO3   : inout std_logic
    );
end entity spi_bridge;

architecture rtl of spi_bridge is
  constant CS_LED_STRETCH_TIME : integer := 5000000; -- 200 ms at 25 MHz clock

  signal cc_rst_n : std_logic;
  signal rst_sync : std_logic_vector(2 downto 0);
  signal rst_n    : std_logic;
  signal clk      : std_logic;

  signal spi_cs_n : std_logic;
  signal spi_clk  : std_logic;
  signal spi_io   : std_logic_vector(3 downto 0);

  -- 2**25 / 25e6 ~ 1.32 s (and one extra bit for overflow)
  signal led_cnt  : std_logic_vector(25 downto 0);
begin

  J9_EN <= '0';
  J10_EN <= '0';
  led_green <= '1';

  -- spi_cs_n  <= S_SPI_nCS;
  cs_ibuf: component CC_IOBUF
    generic map (
      -- PIN_NAME => "IO_WA_A8",
      PULLUP => 1)
  port map (
    A  => '1',
    T  => '1',
    Y  => spi_cs_n,
    IO => CFG_SPI_nCS);

  -- spi_clk   <= S_SPI_CLK;
  clk_ibuf: component CC_IOBUF
    generic map (
      -- PIN_NAME => "IO_WA_B8",
      -- SCHMITT_TRIGGER => 1,
      PULLDOWN => 1)
  port map (
    A  => '1',
    T  => '1',
    Y  => spi_clk,
    IO => CFG_SPI_CLK);

  -- spi_io(0) <= S_SPI_MOSI;
  io0_ibuf: component CC_IOBUF
    generic map (
      -- PIN_NAME => "IO_WA_B7",
      PULLDOWN => 1)
  port map (
    A  => '1',
    T  => '1',
    Y  => spi_io(0),
    IO => CFG_SPI_IO0);

  -- spi_io(1) <= M_SPI_MISO;
  io1_ibuf: component CC_IBUF
    generic map (
      PULLDOWN => 1)
  port map (
    I => M_SPI_MISO,
    Y => spi_io(1));

  spi_io(2) <= '1';
  spi_io(3) <= '1';

  io1_driver: component CC_IOBUF
    generic map (
      -- PIN_NAME => "IO_WA_A7",
      PULLDOWN => 1)
  port map (
    A  => spi_io(1),
    T  => spi_cs_n,
    Y  => open,
    IO => CFG_SPI_IO1);

  -- M_SPI_nCS  <= spi_cs_n;
  cs_driver: component CC_OBUF
  port map (
    A => spi_cs_n,
    O => M_SPI_nCS);

  -- M_SPI_CLK  <= spi_clk;
  clk_driver: component CC_TOBUF
    generic map (
      PULLDOWN => 1)
  port map (
    A => spi_clk,
    T => spi_cs_n,
    O => M_SPI_CLK);

  -- M_SPI_MOSI <= spi_io(0);
  mosi_driver: component CC_TOBUF
    generic map (
      PULLDOWN => 1)
  port map (
    A => spi_io(0),
    T => spi_cs_n,
    O => M_SPI_MOSI);

  io2_driver: component CC_IOBUF
    generic map (
      PULLUP => 1)
  port map (
    A  => spi_io(2),
    T  => spi_cs_n,
    Y  => open,
    IO => M_SPI_IO2);

  io3_driver: component CC_IOBUF
    generic map (
      PULLUP => 1)
  port map (
    A  => spi_io(3),
    T  => spi_cs_n,
    Y  => open,
    IO => M_SPI_IO3);

  -------------------------------------------------------
  -- Power-up reset synchronizer and System clock
  -------------------------------------------------------
  i_cc_usr_rstn: component CC_USR_RSTN
    port map (
      USR_RSTN => cc_rst_n
      );

  i_cc_pll: component CC_PLL
    generic map (
      REF_CLK => "100.0",
      OUT_CLK => "25.0",
      PERF_MD => "SPEED"
      )
    port map (
      CLK_REF => ser_clk,
      CLK0    => clk,

      USR_CLK_REF  => '0',
      CLK_FEEDBACK => '0',
      USR_LOCKED_STDY_RST => '0'
      );

  p_rst: process(clk, cc_rst_n) is
  begin
    if cc_rst_n = '0' then
      rst_sync <= (others => '0');
    elsif rising_edge(clk) then
      rst_sync <= '1' & rst_sync(rst_sync'left downto 1);
    end if;
  end process p_rst;

  rst_n <= rst_sync(0);
  -------------------------------------------------------

  -------------------------------------------------------
  -- Stretch nCS pulse for activity indication LED
  -------------------------------------------------------
  p_led: process(clk, rst_n) is
  begin
    if rst_n = '0' then
      led_cnt <= (led_cnt'left => '1', others => '0');
    elsif rising_edge(clk) then
      if spi_cs_n = '0' then
        led_cnt <= std_logic_vector(to_unsigned(CS_LED_STRETCH_TIME, led_cnt'length));
      elsif led_cnt(led_cnt'left) = '0' then
        led_cnt <= std_logic_vector(unsigned(led_cnt) - 1);
      end if;
    end if;
  end process p_led;

  led_red_n <= led_cnt(led_cnt'left);

end architecture rtl;
