-------------------------------------------------------------------------------
-- This file is a part of the GMM-7550 VHDL Examples
-- <https://github.com/gmm-7550/gmm7550-examples.git>
--
-- SPDX-License-Identifier: MIT
--
-- Copyright (c) 2026 Anton Kuzmin <ak@gmm7550.dev>
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library cc;
use cc.gatemate.all;

library usb;

entity usb3 is
  port (
    ser_clk     : in    std_logic;

    ubtn_a      : in    std_logic;
    ubtn_b      : in    std_logic;
    uled        : out   std_logic_vector(3 downto 0);

    uart_tx     : out   std_logic;
    uart_rx     : in    std_logic;

    pd_en_n     : out   std_logic;
    pd_scl      : out   std_logic;
    pd_sda      : inout std_logic;
    pd_alert_n  : in    std_logic;

    pd_src_en   : out   std_logic;
    pd_disc     : out   std_logic;

    ulpi_clk    : in    std_logic;
    ulpi_rst_n:   out   std_logic;
    ulpi_stp    : out   std_logic;
    ulpi_dir    : in    std_logic;
    ulpi_nxt    : in    std_logic;
    ulpi_d      : inout std_logic_vector(7 downto 0);

    usb1_vp     : inout std_logic;
    usb1_vm     : inout std_logic;
    usb1_rcv    : in    std_logic;
    usb1_busdet : in    std_logic;
    usb1_oe_n   : out   std_logic;
    usb1_con    : out   std_logic;
    usb1_sus    : out   std_logic;

    tck_i       : in    std_logic;
    tms_i       : in    std_logic;
    tdi_i       : in    std_logic;
    tdo_o       : out   std_logic;

    led_green   : out   std_logic;
    led_red_n   : out   std_logic
    );
end entity usb3;

architecture rtl of usb3 is
  constant ILA_DATA_WIDTH : integer := 20;
  signal ila_data : std_logic_vector(ILA_DATA_WIDTH-1 downto 0);
  signal ila_clk  : std_logic;

  signal btn_a, btn_b, p1ms : std_logic;

  signal cc_rst_n : std_logic;
  signal rst_sync : std_logic_vector(2 downto 0);
  signal rst      : std_logic;

  signal reset_sync : std_logic_vector(2 downto 0);
  signal reset    : std_logic;
  signal sys_clk  : std_logic;

  signal ulpi_phy_rst  : std_logic;
  signal ulpi_init_rst : std_logic;

  signal ulpi_dat_i : std_logic_vector(7 downto 0);
  signal ulpi_dat_o : std_logic_vector(7 downto 0);
  signal ulpi_oe    : std_logic;
  signal ulpi_init_done : std_logic;

  signal clk48      : std_logic;
  signal pll48_lock : std_logic;

  signal usb1_rst   : std_logic;
  signal usb1_reset : std_logic;

begin

  uart_tx <= 'Z';

  -- User LEDs
  uled <= (0 => btn_b, 3 => btn_a, others => '0');

  -- USB-C PD controller
  pd_en_n <= '1';
  pd_scl  <= 'Z';
  pd_sda  <= 'Z';
  -- USB-C Power
  pd_src_en  <= '0';
  pd_disc    <= '0';

  usb1_vp   <= 'Z';
  usb1_vm   <= 'Z';
  usb1_oe_n <= '1';
  usb1_con  <= ulpi_init_done; -- '0';
  usb1_sus  <= '0';

  led_green <= reset; -- ulpi_init_done;
  led_red_n <= not ulpi_init_rst;

  i_cc_usr_rstn: component CC_USR_RSTN
    port map (
      USR_RSTN => cc_rst_n
      );

  i_cc_pll25: component CC_PLL
    generic map (
      REF_CLK => "100.0",
      OUT_CLK => "25.0",
      PERF_MD => "SPEED"
      )
    port map (
      CLK_REF => ser_clk,
      CLK0    => sys_clk,

      USR_CLK_REF  => '0',
      CLK_FEEDBACK => '0',
      USR_LOCKED_STDY_RST => '0'
      );

  i_cc_pll48: component CC_PLL
    generic map (
      REF_CLK => "60.0",
      OUT_CLK => "48.0",
      PERF_MD => "SPEED"
      )
    port map (
      CLK_REF => ulpi_clk,
      CLK0    => clk48,

      USR_PLL_LOCKED => pll48_lock,

      USR_CLK_REF  => '0',
      CLK_FEEDBACK => '0',
      USR_LOCKED_STDY_RST => '0'
      );

  -- Power-on reset
  p_rst: process(sys_clk, cc_rst_n) is
  begin
    if cc_rst_n = '0' then
      rst_sync <= (others => '0');
    elsif rising_edge(sys_clk) then
      rst_sync <= '1' & rst_sync(rst_sync'left downto 1);
    end if;
  end process p_rst;

  rst   <= not rst_sync(0);

  -- De-bounce A and B buttons
  clk_div_0: entity work.clk_div
    generic map (
      DIV => 25000)
    port map (
      clk => sys_clk,
      reset => rst,
      pulse => p1ms);

  debounce_a_i: entity work.debounce
    port map (
      clk => sys_clk,
      reset => rst,
      p1ms => p1ms,
      d => ubtn_a,
      q => btn_a);

  debounce_b_i: entity work.debounce
    port map (
      clk => sys_clk,
      reset => rst,
      p1ms => p1ms,
      d => ubtn_b,
      q => btn_b);

  -- User reset (power-on combined with de-bounced button B and target USB Vbus)
  p_reset: process(sys_clk, rst) is
  begin
    if rst = '1' then
      reset_sync <= (others => '0');
    elsif rising_edge(sys_clk) then
      if btn_b = '1' or usb1_busdet = '0' then
        reset_sync <= (others => '0');
      else
        reset_sync <= '1' & reset_sync(reset_sync'left downto 1);
      end if;
    end if;
  end process p_reset;

  reset <= not reset_sync(0);

  -- Reset chain
  phy_rst_i: entity work.rst_delay
    generic map (
      DELAY => 10)
    port map (
      clk_i => sys_clk,
      rst_i => reset,
      rst_o => ulpi_phy_rst);

  ulpi_rst_n <= not ulpi_phy_rst;

  ulpi_rst_i: entity work.rst_delay
    generic map (
      DELAY => 10)
    port map (
      clk_i => ulpi_clk,
      rst_i => ulpi_phy_rst,
      rst_o => ulpi_init_rst);

  -- Switch ULPI PHY to Audio mode (to connect D+/D- lines to USB 1 transceiver)
  ulpi_init_i: entity work.ulpi_init_seq
    port map (
      clk_i  => ulpi_clk, -- 60 MHz input from a PHY
      rst_i  => ulpi_init_rst,
      -- ULPI Signals
      dir    => ulpi_dir,
      nxt    => ulpi_nxt,
      stp    => ulpi_stp,
      dat_i  => ulpi_dat_i,
      dat_o  => ulpi_dat_o,
      dat_oe => ulpi_oe,
      done   => ulpi_init_done);

  ulpi_dat_i <= ulpi_d when ulpi_oe = '0' else (others => '0');
  ulpi_d <= ulpi_dat_o when ulpi_oe = '1' else (others => 'Z');

  usb1_rst <= reset or not pll48_lock or not ulpi_init_done;

  usb1_rst_p: entity work.rst_delay
    generic map (
      DELAY => 10)
    port map (
      clk_i => clk48,
      rst_i => usb1_rst,
      rst_o => usb1_reset);

  -- In-system Logic Analyzer
  ila_clk  <= sys_clk;
  ila_data <= (15 => reset,
               16 => pll48_lock,
               17 => ulpi_init_rst,
               18 => ulpi_init_done,
               19 => usb1_reset,
               others => '0');

  i_la: entity work.la
    generic map (
      DATA_WIDTH => ILA_DATA_WIDTH)
    port map (
      reset => rst,

      tck_i => tck_i,
      tms_i => tms_i,
      tdi_i => tdi_i,
      tdo_o => tdo_o,

      clk   => ila_clk,
      data  => ila_data);

end architecture rtl;
