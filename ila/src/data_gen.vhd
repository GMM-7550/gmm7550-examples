library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_gen is
  generic (
    DATA_WIDTH : integer := 8);
  port (
    clk   : in std_logic;
    reset : in std_logic;
    en    : in std_logic;
    mode  : in std_logic;
    data  : out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity data_gen;

architecture rtl of data_gen is
  signal d : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal d_next : std_logic_vector(DATA_WIDTH-1 downto 0);
begin

  data <= d;

  process (clk, reset)
  begin
    if reset = '1' then
      d <= (others => '0');
    elsif rising_edge(clk) then
      if en = '1' then
        d <= d_next;
      end if;
    end if;
  end process;

  process (d, mode)
  begin
    if mode = '0' then
      d_next <= std_logic_vector(unsigned(d) + 1);
    else
      d_next(7 downto 1) <= d(6 downto 0);
      d_next(0) <= d(7) xor d(5) xor d(4) xor d(3);
    end if;
  end process;

end rtl;
