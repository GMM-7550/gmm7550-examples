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
  -- Use Block RAM 40K in 2k x 20 bit configuration by default
  constant DATA_WIDTH : integer := 19;

  signal clk    : std_logic;
  signal data   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal enable : std_logic;

  signal pulse_1ms : std_logic;
  signal pulse_500ms : std_logic;

  signal btn0, btn1 : std_logic;
  signal btn0d, btn1d : std_logic := '0';
  signal btn0_down, btn1_down : std_logic;

  signal mode : std_logic := '0';
  signal auto : std_logic := '0';
  signal fast : std_logic := '0';

  signal cc_rst_n : std_logic;
  signal rst_sync : std_logic_vector(2 downto 0);
  signal reset    : std_logic;
  signal sys_clk  : std_logic;

begin

  clk <= sys_clk;

  led_green <= btn0;
  led_red_n <= not mode;

  uled <= data(uled'range); -- only subset of data[] signals is displayed

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


  -- Enable signal for visible LED effects
  --
  u0: entity work.clk_div
    generic map (
      DIV => 12500000)
    port map (
      clk => clk,
      reset => reset,
      pulse => pulse_500ms);

  -- LED (data pattern) switching rate:
  --   system clock (25 MHz)
  --   2 Hz
  --   manual (push button)
  enable <= '1' when fast = '1' else pulse_500ms when auto = '1' else btn0_down;

  -- Pattern generator:
  --   binary counter
  --   LFSR-8
  u1: entity work.data_gen
    generic map (
      DATA_WIDTH => DATA_WIDTH)
    port map (
      clk => clk,
      reset => reset,
      mode => mode,
      en => enable,
      data => data);

  -- 1ms interval for push-button debouncers
  u2_0: entity work.clk_div
    generic map (
      DIV => 25000)
    port map (
      clk => clk,
      reset => reset,
      pulse => pulse_1ms);

  u2_1: entity work.debounce
    port map (
      clk => clk,
      reset => reset,
      p1ms => pulse_1ms,
      d => ubtn_a,
      q => btn0);

  u2_2: entity work.debounce
    port map (
      clk => clk,
      reset => reset,
      p1ms => pulse_1ms,
      d => ubtn_b,
      q => btn1);

  -- Generate single-clock pulses for button down events
  process (clk, reset)
  begin
    if reset = '1' then
      btn0d <= '0';
      btn1d <= '0';
    elsif rising_edge(clk) then
      btn0d <= btn0;
      btn1d <= btn1;
    end if;
  end process;

  btn0_down <= '1' when btn0 = '1' and btn0d = '0' else '0';
  btn1_down <= '1' when btn1 = '1' and btn1d = '0' else '0';

  -- Mode switcher:
  --   on button 1 down event
  --   if button 0 is not pressed, then
  --     switch between counter and LFSR modes
  --   if button 0 is depressed then
  --     switch speed in cycle
  --     - manual (auto = 0, fast = 0)
  --     - 2 Hz   (auto = 1, fast = 0)
  --     - 25 MHz (auto = 1, fast = 1)
  process (clk, reset)
  begin
    if reset = '1' then
      mode <= '0';
      auto <= '0';
      fast <= '0';
    elsif rising_edge(clk) then
      if btn1_down = '1' then
        if btn0 = '1' then
          if auto = '0' then
            auto <= '1';
          else
            if fast = '0' then
              fast <= '1';
            else
              auto <= '0';
              fast <= '0';
            end if;
          end if;
        else
          mode <= not mode;
        end if;
      end if;
    end if;
  end process;

  u10: entity work.la
    generic map (
      DATA_WIDTH => DATA_WIDTH)
    port map (
      reset => reset,
      tck_i => tck_i,
      tms_i => tms_i,
      tdi_i => tdi_i,
      tdo_o => tdo_o,

      clk   => clk,
      data  => data);

end architecture rtl;
