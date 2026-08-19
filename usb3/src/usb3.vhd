-------------------------------------------------------------------------------
-- This file is a part of the GMM-7550 VHDL Examples
-- <https://github.com/gmm-7550/gmm7550-examples.git>
--
-- SPDX-License-Identifier: MIT
--
-- Copyright (c) 2025 Anton Kuzmin <ak@gmm7550.dev>
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library cc;
use cc.gatemate.all;

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

    led_green   : out   std_logic;
    led_red_n   : out   std_logic
    );
end entity usb3;

architecture rtl of usb3 is
  signal led      : std_logic;
  signal cc_rst_n : std_logic;
  signal rst_sync : std_logic_vector(2 downto 0);
  signal rst_n    : std_logic;
  signal sys_clk  : std_logic;

  signal a, b     : std_logic;
  signal cnt      : std_logic_vector(3 downto 0);

begin

  uart_tx <= 'Z';

  pd_en_n <= b;
  pd_scl  <= 'Z';
  pd_sda  <= 'Z';

  pd_src_en  <= b; -- '0';
  pd_disc    <= '0';

  ulpi_rst_n <= not b; -- '0';
  ulpi_stp   <= 'Z';
  ulpi_d     <= (others => 'Z');

  usb1_vp   <= 'Z';
  usb1_vm   <= 'Z';
  usb1_oe_n <= '1';
  usb1_con  <= '0';
  usb1_sus  <= '0';

  -- led_green <= rst_n;
  led_red_n <= not led;

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
      CLK0    => sys_clk,

      USR_CLK_REF  => '0',
      CLK_FEEDBACK => '0',
      USR_LOCKED_STDY_RST => '0'
      );

  p_rst: process(sys_clk, cc_rst_n) is
  begin
    if cc_rst_n = '0' then
      rst_sync <= (others => '0');
    elsif rising_edge(sys_clk) then
      rst_sync <= '1' & rst_sync(rst_sync'left downto 1);
    end if;
  end process p_rst;

  rst_n <= rst_sync(0);

  i_blink: entity work.blink
    generic map (
      period_g    => 25000000,
      high_g      =>  2000000
    )
  port map (
    clk   => sys_clk,
    rst_n => rst_n,
    o     => led
    );

  a <= not ubtn_a;
  b <= not ubtn_b;

  p_cnt: process(a, b) is
  begin
    if b = '1' then
      cnt <= (others => '0');
    elsif rising_edge(a) then
      cnt <= std_logic_vector(unsigned(cnt) + 1);
    end if;
  end process;

  uled <= cnt;
  led_green <= a;

end architecture rtl;
