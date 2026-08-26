library ieee;
use ieee.std_logic_1164.all;

entity la_trigger is

  generic (
    DATA_WIDTH : integer := 8
    );
  port (
    clk    :  in std_logic;
    reset  :  in std_logic;
    inp    :  in std_logic_vector(DATA_WIDTH-1 downto 0);
    pattern:  in std_logic_vector(DATA_WIDTH-1 downto 0);
    mask   :  in std_logic_vector(DATA_WIDTH-1 downto 0);
    d_out  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    t_out  : out std_logic
    );

end entity la_trigger;

architecture rtl of la_trigger is

  signal t_vec : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal t_vec_and : std_logic;

begin

  process (clk, reset) is
  begin
    if reset = '1' then
      d_out <= (others => '0');
      t_out <= '0';
    elsif rising_edge(clk) then
      d_out <= inp;
      t_out <= t_vec_and;
    end if;
  end process;

  t_vec <= (not mask) or (inp and pattern) or ((not inp) and (not pattern));
  t_vec_and <= '1' when (t_vec = (t_vec'range => '1')) else '0';

end architecture rtl;
