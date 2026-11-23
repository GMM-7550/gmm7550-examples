library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rst_delay is
  generic (
    DELAY : integer := 15);
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    rst_o : out std_logic);
end entity rst_delay;

architecture rtl of rst_delay is
  constant CNT_WIDTH : integer := integer(ceil(log2(real(DELAY))));
  signal cnt : std_logic_vector(CNT_WIDTH downto 0); -- no -1
begin
  -- assert DELAY >= 2
  --   report "Minimal DELAY is 2 clock cycles"
  --   severity ERROR;

  -- p_report: process is
  -- begin
  --   report "Delay counter width: " & integer'image(CNT_WIDTH);
  --   wait;
  -- end process p_report;

  p_delay: process (clk_i, rst_i) is
  begin
    if rst_i = '1' then
      cnt <= "0" & std_logic_vector(to_unsigned(delay-2, CNT_WIDTH));
    elsif rising_edge(clk_i) then
      if cnt(cnt'left) = '0' then
        cnt <= std_logic_vector(unsigned(cnt) - 1);
      end if;
    end if;
  end process p_delay;

  rst_o <= not cnt(cnt'left);

end architecture rtl;
