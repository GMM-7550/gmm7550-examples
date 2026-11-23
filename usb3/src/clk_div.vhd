library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_div is
  generic (
    DIV : integer := 25000000);
  port (
    clk  : in std_logic;
    reset : in std_logic;
    pulse : out std_logic);
end entity clk_div;

architecture rtl of clk_div is
  signal cnt : std_logic_vector(31 downto 0) := (others => '0');
begin

  process (clk, reset)
  begin
    if reset = '1' then
      cnt <= (others => '0');
    elsif rising_edge(clk) then
      if cnt(cnt'left) = '1' then
        cnt <= std_logic_vector(to_unsigned(DIV-2, cnt'length));
      else
        cnt <= std_logic_vector(unsigned(cnt) - 1);
      end if;
    end if;
  end process;

  pulse <= cnt(cnt'left);

end architecture rtl;
