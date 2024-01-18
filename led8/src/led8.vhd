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

use work.bcm_pkg.all;

entity led8 is
  generic (
    ADDR_WIDTH : integer := 8;
    pmod : string := "J10" -- J9 or J10 P-mod connector
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
  constant ch_num    : integer := 8;
  constant bcm_width : integer := 4;

  signal cc_rst_n : std_logic;
  signal rst_sync : std_logic_vector(2 downto 0);
  signal rst_n    : std_logic;
  signal sys_clk  : std_logic;

  signal data     : std_logic_vector(31 downto 0);

  signal cycle    : std_logic;
  signal bcm_data : std_logic_vector_array_t(ch_num-1 downto 0)(bcm_width-1 downto 0);
  signal led_o    : std_logic_vector(7 downto 0);
begin

  led_green <= '0';
  led_red_n <= rst_n;

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

  i_seq: entity work.seq
    generic map (
      DATA_WIDTH => ch_num * bcm_width,
      ADDR_WIDTH => ADDR_WIDTH)
    port map (
      clk   => sys_clk,
      rst_n => rst_n,
      step  => cycle,
      data  => data,
      last  => open);

  g_data: for i in 0 to ch_num-1 generate
    bcm_data(i) <= data((i+1)*bcm_width - 1 downto i*bcm_width);
  end generate;

  i_bcm: entity work.bcm
    generic map (
      CH_NUM    => ch_num,
      BCM_WIDTH => bcm_width)
    port map (
      clk       => sys_clk,
      rst_n     => rst_n,
      bcm_data  => bcm_data,
      bcm_start => cycle,
      bcm_out   => led_o);

  -- i_blink: entity work.blink
  --   generic map (
  --     period_g    => 25000000,
  --     high_g      =>  2000000
  --   )
  -- port map (
  --   clk   => sys_clk,
  --   rst_n => rst_n,
  --   o     => cycle
  --   );

  -- led_o <= x"55" when cycle = '1' else x"aa";

  g_j9: if pmod = "J9" generate
    J9_EN <= '1';
    g_j9_i: for i in 7 downto 0 generate
      i_iobuf: component CC_IOBUF
        port map (
          A  => led_o(i),
          T  => '0',
          Y  => open,
          IO => J9_IO(i));
      end generate;

    J10_EN <= '0';
    J10_IO <= (others => 'Z');
  else generate
    J10_EN <= '1';
    g_j10_i: for i in 7 downto 0 generate
      i_iobuf: component CC_IOBUF
        port map (
          A  => led_o(i),
          T  => '0',
          Y  => open,
          IO => J10_IO(i));
      end generate;

    J9_EN <= '0';
    J9_IO <= (others => 'Z');
  end generate;

end architecture rtl;
