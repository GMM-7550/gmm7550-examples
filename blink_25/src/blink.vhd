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
use ieee.numeric_std.all;
use ieee.math_real.all;

entity blink is
  generic (
    period_g    : positive := 10;
    high_g      : positive := 4
    );
  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;
    o     : out std_logic
    );
end entity blink;

architecture rtl of blink is
  constant cnt_width_c : positive := integer(ceil(log2(real(period_g-2))));
  signal cnt : std_logic_vector(cnt_width_c downto 0);  -- plus overflow bit
  signal oo  : std_logic;
begin

  -- assert period_g <= 2 ** cnt_width_c + 2
  --   report "Blink period is too long for the configured counter width"
  --   severity error;

  assert high_g < period_g
    report "Period should be longer than High time"
    severity error;

  o <= oo;

  p_cnt: process (clk, rst_n) is
  begin
    if rst_n = '0' then
      oo <= '0';
      cnt <= (others => '0');
    elsif rising_edge(clk) then
      if cnt(cnt'left) = '0' then
        cnt <= std_logic_vector(unsigned(cnt) - 1);
      else
        if oo = '0' then
          oo <= '1';
          cnt <= std_logic_vector(to_signed(high_g - 2, cnt'length));
        else
          oo <= '0';
          cnt <= std_logic_vector(to_signed(period_g - high_g - 2, cnt'length));
        end if;
      end if;
    end if;
  end process p_cnt;

end architecture rtl;
