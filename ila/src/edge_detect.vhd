library ieee;
use ieee.std_logic_1164.all;

entity edge_detect is
  port (
    clk : in  std_logic;
    di  : in  std_logic;
    re  : out std_logic;
    fe  : out std_logic);
end entity edge_detect;

architecture rtl of edge_detect is
  signal d : std_logic;
begin

  process (clk) is
  begin
    if rising_edge(clk) then
      d <= di;
    end if;
  end process;

  re <= di and not d;
  fe <= not di and d;

end architecture rtl;
