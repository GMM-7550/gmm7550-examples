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

entity blink_25_pll is
  port (
    clk3      : in  std_logic;

    led_green : out std_logic;
    led_red_n : out std_logic
    );
end entity blink_25_pll;

architecture rtl of blink_25_pll is
  signal led      : std_logic;
  signal cc_rst_n : std_logic;
  signal rst_sync : std_logic_vector(2 downto 0);
  signal rst_n    : std_logic;
  signal sys_clk  : std_logic;
begin

  led_green <= rst_n;
  led_red_n <= not led;

  i_cc_usr_rstn: component CC_USR_RSTN
    port map (
      USR_RSTN => cc_rst_n
      );

  i_cc_pll: component CC_PLL
    generic map (
      REF_CLK => "25.0",
      OUT_CLK => "25.0",
      PERF_MD => "SPEED"
      )
    port map (
      CLK_REF => clk3,
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

end architecture rtl;
