-------------------------------------------------------------------------------
-- This file is a part of the GMM-7550 VHDL Examples
-- <https://github.com/ak-fau/gmm7550-examples.git>
--
-- SPDX-License-Identifier: MIT
--
-- Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library cc;
use cc.gatemate.all;

entity led8 is
  generic (
    pmod : string := "J9" -- J9 or J10 P-mod connector
    );
  port (
    ser_clk   : in  std_logic;

    J9_EN     : out   std_logic;
    J9_IO     : inout std_logic_vector(7 downto 0);
    J10_EN    : out   std_logic;
    J10_IO    : inout std_logic_vector(7 downto 0);

    led_green : out std_logic;
    led_red_n : out std_logic
    );
end entity led8;

architecture rtl of led8 is
  signal cc_rst_n : std_logic;
  signal rst_sync : std_logic_vector(2 downto 0);
  signal rst_n    : std_logic;
  signal sys_clk  : std_logic;
  signal led      : std_logic;

  signal led_o    : std_logic_vector(7 downto 0);
begin

  led_green <= rst_n;
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

  led_o <= (others => led);

  g_j9: if pmod = "J9" generate
    J9_EN <= '1';
    J9_IO <= led_o;

    J10_EN <= '0';
    J10_IO <= (others => 'Z');
  else generate
    J10_EN <= '1';
    J10_IO <= led_o;

    J9_EN <= '0';
    J9_IO <= (others => 'Z');
  end generate;

end architecture rtl;
