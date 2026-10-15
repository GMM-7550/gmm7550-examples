library ieee;
use ieee.std_logic_1164.all;

entity ddff is
  port (
    clk : in  std_logic;
    di  : in  std_logic;
    do  : out std_logic);
end entity ddff;

architecture rtl of ddff is
  constant NUM_STAGES : integer := 2;
  signal buf : std_logic_vector(NUM_STAGES-1 downto 0);
begin

  process (clk) is
  begin
    if rising_edge(clk) then
      buf <= di & buf(NUM_STAGES-1 downto 1);
    end if;
  end process;

  do <= buf(0);

end architecture rtl;
