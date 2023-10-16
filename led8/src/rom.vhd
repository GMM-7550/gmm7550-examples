library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bcm_pkg.all;

entity rom is
  generic (
    DATA_WIDTH : integer;
    ADDR_WIDTH : integer;
    INIT       : std_logic_vector_array_t(natural range 0 to 2**ADDR_WIDTH-1)(DATA_WIDTH-1 downto 0));
  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;
    addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    data  : out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity rom;

architecture rtl of rom is
  constant mem : std_logic_vector_array_t (0 to 2**ADDR_WIDTH-1)(DATA_WIDTH-1 downto 0) := INIT;
begin

  p_rom : process (clk, rst_n) is
  begin
    if rst_n = '0' then
      data <= (others => '0');
    elsif rising_edge(clk) then
      data <= mem(to_integer(unsigned(addr)));
    end if;
  end process p_rom;

end architecture rtl;
