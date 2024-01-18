-------------------------------------------------------------------------------
-- This file is a part of the GMM-7550 VHDL Examples
-- <https://github.com/gmm-7550/gmm7550-examples.git>
--
-- SPDX-License-Identifier: MIT
--
-- Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library cc;
use cc.gatemate.all;

entity blink_25 is
  port (
    clk3      : in  std_logic;

    led_green : out std_logic;
    led_red_n : out std_logic
    );
end entity blink_25;

architecture rtl of blink_25 is
  signal led      : std_logic;
  signal cc_rst_n : std_logic;
  signal rst_sync : std_logic_vector(2 downto 0);
  signal rst_n    : std_logic;
begin

  led_green <= rst_n;
  led_red_n <= not led;

  i_cc_usr_rstn: component CC_USR_RSTN
    port map (
      USR_RSTN => cc_rst_n
      );

  p_rst: process(clk3, cc_rst_n) is
  begin
    if cc_rst_n = '0' then
      rst_sync <= (others => '0');
    elsif rising_edge(clk3) then
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
    clk   => clk3,
    rst_n => rst_n,
    o     => led
    );

end architecture rtl;
