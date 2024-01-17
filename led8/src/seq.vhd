library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity seq is
  generic (
    DATA_WIDTH  : integer := 32;
    ADDR_WIDTH  : integer := 8;
    SINGLE_STEP : boolean := false);
  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;
    step  : in  std_logic;
    data  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    last  : out std_logic);
end entity seq;

architecture rtl of seq is
  constant STEP_CNT_WIDTH : integer := 25;

  signal ptr  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal cnt  : std_logic_vector(STEP_CNT_WIDTH downto 0);
  signal icnt : std_logic_vector(STEP_CNT_WIDTH-1 downto 0);

  signal t_data : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal load : std_logic;
begin

  load <= step and cnt(cnt'left);

  g_single_step : if SINGLE_STEP generate
    cnt <= (others => '1');
  else generate
    p_cnt : process (clk, rst_n) is
    begin
      if rst_n = '0' then
        cnt <= (others => '1');
      elsif rising_edge(clk) then
        if load = '1' then
          cnt <= '0' & icnt;
        elsif step = '1' then
          cnt <= std_logic_vector(unsigned(cnt) - 1);
        end if;
      end if;
    end process p_cnt;
  end generate;

  p_ptr : process (clk, rst_n) is
  begin
    if rst_n = '0' then
      ptr <= (others => '0');
    elsif rising_edge(clk) then
      if load = '1' then
        if last = '1' then
          ptr <= (others => '0');
        else
          ptr <= std_logic_vector(unsigned(ptr) + 1);
        end if;
      end if;
    end if;
  end process p_ptr;

  last <= and_reduce(ptr);

  i_rom_0 : entity work.pattern_rom
    generic map (
      ADDR_WIDTH => ADDR_WIDTH)
    port map (
      clk   => clk,
      rst_n => rst_n,
      addr  => ptr,
      data  => data);

  -- icnt <= std_logic_vector(to_unsigned(600, icnt'length));

  i_rom_1 : entity work.time_rom
    generic map (
      ADDR_WIDTH => ADDR_WIDTH)
    port map (
      clk   => clk,
      rst_n => rst_n,
      addr  => ptr,
      data  => t_data);

  icnt <= t_data(icnt'range);

end architecture rtl;
