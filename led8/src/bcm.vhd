--
-- Binary Code Modulation
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

use work.bcm_pkg.all;

entity bcm is
  generic (
    CH_NUM    : integer := 1;
    BCM_WIDTH : integer := 4
    );
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    bcm_data  : in  std_logic_vector_array_t(CH_NUM-1 downto 0)(BCM_WIDTH-1 downto 0);
    bcm_start : out std_logic;
    bcm_out   : out std_logic_vector(CH_NUM-1 downto 0)
    );
end entity bcm;

architecture rtl of bcm is
  constant CNT_WIDTH : integer := 12;

  signal bcm_e : std_logic_vector_array_t(CH_NUM-1 downto 0)(CNT_WIDTH-1 downto 0);
  signal mask  : std_logic_vector(CNT_WIDTH-1 downto 0);
  signal cnt   : std_logic_vector(CNT_WIDTH-1 downto 0);
  signal shift : std_logic;

  function exp_4_12(constant x : std_logic_vector(3 downto 0))
    return std_logic_vector is
    variable f : std_logic_vector(11 downto 0);
  begin
    case x is
      when x"0" => f := x"000";
      when x"1" => f := x"0a4";
      when x"2" => f := x"154";
      when x"3" => f := x"210";
      when x"4" => f := x"2d8";
      when x"5" => f := x"3af";
      when x"6" => f := x"494";
      when x"7" => f := x"589";
      when x"8" => f := x"68f";
      when x"9" => f := x"7a7";
      when x"a" => f := x"8d3";
      when x"b" => f := x"a13";
      when x"c" => f := x"b69";
      when x"d" => f := x"cd6";
      when x"e" => f := x"e5d";
      when x"f" => f := x"fff";
      when others => f := x"000";
    end case;
    return f;
  end function exp_4_12;

begin

  -- assert BCM_WIDTH = CNT_WIDTH
  --                     report "Modulation width should be equal to the counter width"
  --                     severity error;
  assert BCM_WIDTH <= CNT_WIDTH
                      report "Modulation width should not be higher than counter width"
                      severity error;

  p_mask: process(clk, rst_n)
  begin
    if rst_n = '0' then
      mask <= (0 => '1', others => '0');
    elsif rising_edge(clk) then
      if shift = '1' then
        mask <= mask(CNT_WIDTH-2 downto 0) & mask(CNT_WIDTH-1);
      end if;
    end if;
  end process p_mask;

  p_cnt: process(clk, rst_n)
  begin
    if rst_n = '0' then
      cnt <= (0=>'1', others => '0');
    elsif rising_edge(clk) then
      if shift = '1' then
        cnt <= (0 => '1', others => '0');
      else
        cnt <= std_logic_vector(unsigned(cnt) + 1);
      end if;
    end if;
  end process;

  shift <= or_reduce(cnt and mask);

  g_bcm: for i in 0 to CH_NUM-1 generate
    g_bcm_width: if CNT_WIDTH = BCM_WIDTH generate
      bcm_e(i) <= bcm_data(i);
    else generate
      bcm_e(i) <= exp_4_12(bcm_data(i));
    end generate;

    bcm_out(i) <= rst_n and or_reduce(mask and bcm_e(i));
  end generate g_bcm;

  bcm_start <= rst_n and mask(0);

end architecture rtl;
