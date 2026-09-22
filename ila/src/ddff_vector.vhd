library ieee;
use ieee.std_logic_1164.all;

entity ddff_vector is
  generic (
    DATA_WIDTH : integer;
    NUM_STAGES : integer := 2);
  port (
    clk : in  std_logic;
    di  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    do  : out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity ddff_vector;

architecture rtl of ddff_vector is
  type pipeline_t is array(1 to NUM_STAGES) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal buf : pipeline_t;
begin

  process (clk) is
  begin
    if rising_edge(clk) then
      buf <= di & buf(1 to NUM_STAGES-1);
    end if;
  end process;

  do <= buf(NUM_STAGES);

end architecture rtl;
