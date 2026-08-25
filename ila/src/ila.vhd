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

entity ila is
  port (
    ser_clk   : in  std_logic;

    tck_i     : in  std_logic;
    tms_i     : in  std_logic;
    tdi_i     : in  std_logic;
    tdo_o     : out std_logic;

    ubtn_a    : in  std_logic;
    ubtn_b    : in  std_logic;
    uled      : out std_logic_vector(3 downto 0);

    led_green : out std_logic;
    led_red_n : out std_logic
    );
end entity ila;

architecture rtl of ila is
  -- signal led      : std_logic;
  signal cc_rst_n : std_logic;
  signal rst_sync : std_logic_vector(2 downto 0);
  signal reset    : std_logic;
  signal sys_clk  : std_logic;

  -- signal a, b     : std_logic;

begin

  led_green <= not ubtn_a;
  led_red_n <= ubtn_b;

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

  reset <= not rst_sync(0);

  i_tap: entity work.tap
    port map (
      reset => reset,
      tck_i => tck_i,
      tms_i => tms_i,
      tdi_i => tdi_i,
      tdo_o => tdo_o,

      do    => uled
      );

end architecture rtl;
