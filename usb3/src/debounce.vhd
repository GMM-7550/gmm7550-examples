library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
  port (
    clk : in std_logic;
    reset : in std_logic;
    p1ms : in std_logic;
    d : in std_logic;
    q : out std_logic);
end entity debounce;

architecture rtl of debounce is
  signal di : std_logic_vector(2 downto 0);  -- input re-sample
  signal cnt : std_logic_vector(4 downto 0); -- debounce delay
  signal d_out : std_logic := '0';
  signal d_next : std_logic := '0';
begin

  process (clk, reset)
  begin
    if reset = '1' then
      di <= (others => '0');
    elsif rising_edge(clk) then
      di(0) <= not d;
      di(di'left downto 1) <= di(di'left-1 downto 0);
    end if;
  end process;

  process (clk, reset)
  begin
    if reset = '1' then
      d_out <= '0';
      d_next <= '0';
      cnt <= (cnt'left => '0', others => '1');
    elsif rising_edge(clk) then
      if p1ms = '1' then
        if d_next = di(di'left) then
          if cnt(cnt'left) = '1' then
            d_out <= d_next;
          else
            cnt <= std_logic_vector(unsigned(cnt) - 1);
          end if;
        else
          d_next <= di(di'left);
          cnt <= (cnt'left => '0', others => '1');
        end if;
      end if;
    end if;
  end process;

  q <= d_out;

end architecture rtl;
