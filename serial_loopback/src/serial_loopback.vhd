-------------------------------------------------------------------------------
-- This file is a part of the GMM-7550 VHDL Examples
-- <https://github.com/ak-fau/gmm7550-examples.git>
--
-- SPDX-License-Identifier: MIT
--
-- Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- SPI mux bit 2 -- to enable SPI_D2/D3 connection to RPi 40-pin header
--                  pins 8 and 10
-- SPI mux bit 0 -- to connect SPI configuration inteface to RPi
-- 0101 == 5
--
-- ~# gmm7550 -s 5 -m spi_passive cfg -f serial_loopback.bit
-- ~# picocom -b 115200 /dev/ttyAMA0
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library cc;
use cc.gatemate.all;

entity serial_loopback is
  port (
    ser_clk   : in  std_logic;

    uart_tx   : out std_logic;
    uart_rx   : in  std_logic;

    led_green : out std_logic;
    led_red_n : out std_logic
    );
end entity serial_loopback;

architecture rtl of serial_loopback is
  constant LED_STRETCH_TIME : integer := 1250000; -- 50 ms at 25 MHz clock

  signal cc_rst_n : std_logic;
  signal rst_sync : std_logic_vector(2 downto 0);
  signal rst_n    : std_logic;
  signal sys_clk  : std_logic;
  signal led_cnt  : std_logic_vector(25 downto 0);
begin

  -- Serial loopback
  uart_tx <= uart_rx;

  led_green <= rst_n;
  led_red_n <= led_cnt(led_cnt'left);

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

  -------------------------------------------------------
  -- Stretch UART data pulses for activity indication LED
  -------------------------------------------------------
  p_led: process(sys_clk, rst_n) is
  begin
    if rst_n = '0' then
      led_cnt <= (led_cnt'left => '1', others => '0');
    elsif rising_edge(sys_clk) then
      if uart_rx = '0' then
        led_cnt <= std_logic_vector(to_unsigned(LED_STRETCH_TIME, led_cnt'length));
      elsif led_cnt(led_cnt'left) = '0' then
        led_cnt <= std_logic_vector(unsigned(led_cnt) - 1);
      end if;
    end if;
  end process p_led;

end architecture rtl;
