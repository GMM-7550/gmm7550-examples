library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dpram is
  generic (
    ADDR_WIDTH : integer := 11;
    DATA_WIDTH : integer := 20
    );
  port (
    clka  : in  std_logic;
    wea   : in  std_logic;
    addra : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    dia   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    doa   : out std_logic_vector(DATA_WIDTH-1 downto 0);

    clkb  : in  std_logic;
    web   : in  std_logic;
    addrb : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    dib   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    dob   : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end entity dpram;

-- Inferred Block RAM 40K
architecture inferred of dpram is
  type ram is array (0 to (2**ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  shared variable memory : ram;
begin
  a_p: process (clka) is
  begin
    if rising_edge(clka) then
      if wea = '1' then
        memory(to_integer(unsigned(addra))) := dia;
      else
        doa <= memory(to_integer(unsigned(addra)));
      end if;
    end if;
  end process a_p;

  b_p: process (clkb) is
  begin
    if rising_edge(clkb) then
      if web = '1' then
        memory(to_integer(unsigned(addrb))) := dib;
      else
        dob <= memory(to_integer(unsigned(addrb)));
      end if;
    end if;
  end process b_p;
end architecture inferred;
