library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seq is
  generic (
    DATA_WIDTH : integer := 32;
    SINGLE_STEP: boolean := false);
  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;
    step  : in  std_logic;
    data  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    last  : out std_logic);
end entity seq;

architecture rtl of seq is
  constant STEP_CNT_WIDTH : integer := 25;

  signal ptr  : integer;
  signal cnt  : std_logic_vector(STEP_CNT_WIDTH   downto 0);
  signal icnt : std_logic_vector(STEP_CNT_WIDTH-1 downto 0);
  signal rdat : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal rlst : std_logic;
  signal load : std_logic;
begin

  load <= step and cnt(cnt'left);

  g_single_step: if SINGLE_STEP generate
    cnt <= (others => '1');
  else generate
    p_cnt: process (clk, rst_n) is
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

  p_ptr: process (clk, rst_n) is
  begin
    if rst_n = '0' then
      ptr <= 0;
    else
      if rising_edge(clk) then
        if load = '1' then
          if rlst = '1' then
            ptr <= 0;
          else
            ptr <= ptr + 1;
          end if;
        end if;
      end if;
    end if;
  end process p_ptr;

  p_dat: process (clk, rst_n) is
  begin
    if rst_n = '0' then
      data <= (others => '0');
      last <= '0';
    elsif rising_edge(clk) then
      if load = '1' then
        data <= rdat;
        last <= rlst;
      end if;
    end if;
  end process p_dat;

  p_rom: process (ptr) is
  begin
    rdat <= (others => '1');
    icnt <= (others => '0');
    rlst <= '0';

    case ptr is
      when 0 =>
        rdat <= x"00000000";
        icnt <= std_logic_vector(to_unsigned(1000, icnt'length));
        rlst <= '0';

      when 1 =>
        rdat <= x"ffffffff";
        icnt <= std_logic_vector(to_unsigned(1000, icnt'length));
        rlst <= '1';

      when others =>
        rdat <= x"deadbeef";
        icnt <= (others => '0');
        rlst <= '1';
    end case;
  end process p_rom;

end architecture rtl;
