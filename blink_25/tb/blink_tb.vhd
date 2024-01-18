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

entity tb_blink is begin
end entity tb_blink;

architecture sim of tb_blink is
  signal clk   : std_logic := '0';
  signal rst_n : std_logic := '0';
  signal led   : std_logic;
begin

  clk <= not clk after 5 ns;

  p_rst: process is
  begin
    wait until rising_edge(clk);
    rst_n <= '1';
  end process p_rst;

  i_dut: entity work.blink
    generic map (
      period_g    => 10,
      high_g      => 1
    )
  port map (
    clk   => clk,
    rst_n => rst_n,
    o     => led
    );

end architecture sim;
