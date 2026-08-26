library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity la_control is
  generic (
    L_COUNTER_BITS : integer := 10); -- record length == 1024 -> 10 bit
  port (
    clk     : in  std_logic;
    reset   : in  std_logic;
    post_st : in std_logic_vector(L_COUNTER_BITS-1 downto 0);
    arm     : in  std_logic;
    restart : in  std_logic;
    trigger : in  std_logic;
    state   : out std_logic_vector(3 downto 0);
    done    : out std_logic;
    t_addr  : out std_logic_vector(L_COUNTER_BITS-1 downto 0);
    dp_wadr : out std_logic_vector(L_COUNTER_BITS downto 0);
    dp_we   : out std_logic
    );
end la_control;

architecture rtl of la_control is

  -- Counters are 1-bit longer for roll-over mark and overflow detection
  signal t_ptr : std_logic_vector(L_COUNTER_BITS downto 0) := (others => '0');
  signal d_ptr : std_logic_vector(L_COUNTER_BITS downto 0) := (others => '0');
  signal post_cnt : std_logic_vector(L_COUNTER_BITS downto 0) := (others => '0');

  type la_state is (LA_IDLE_ST, LA_PREFILL_ST, LA_ARMED_ST, LA_RUN_ST, LA_DONE_ST);
  signal la_current, la_next : la_state;

  signal post_cnt_load, post_cnt_dec : std_logic;
  signal dp_write : std_logic;

begin

  process (clk, reset)
  begin
    if reset = '1' then
      la_current <= LA_IDLE_ST;
    elsif rising_edge(clk) then
      la_current <= la_next;
    end if;
  end process;

  -- Output current FSM state for debugging/status register
  process (la_current)
  begin
    case la_current is
      when LA_IDLE_ST =>
        state <= "0000";
      when LA_PREFILL_ST =>
        state <= "0001";
      when LA_ARMED_ST =>
        state <= "0011";
      when LA_RUN_ST =>
        state <= "0111";
      when LA_DONE_ST =>
        state <= "1111";
      -- when others =>
      --   state <= "1110"; -- _E_rror state
    end case;
  end process;

  process (la_current, d_ptr, arm, restart, trigger, post_cnt)
  begin
    case la_current is
      when LA_IDLE_ST =>
        if arm = '1' then
          la_next <= LA_PREFILL_ST;
        else
          la_next <= LA_IDLE_ST;
        end if;

      when LA_PREFILL_ST =>
        if d_ptr = (d_ptr'range => '1') then
          la_next <= LA_ARMED_ST;
        else
          la_next <= LA_PREFILL_ST;
        end if;

      when LA_ARMED_ST =>
        if trigger = '1' then
          la_next <= LA_RUN_ST;
        else
          la_next <= LA_ARMED_ST;
        end if;

      when LA_RUN_ST =>
        if post_cnt(L_COUNTER_BITS) = '1' then
          la_next <= LA_DONE_ST;
        else
          la_next <= LA_RUN_ST;
        end if;

      when LA_DONE_ST =>
        if restart = '1' then
          la_next <= LA_IDLE_ST;
        else
          la_next <= LA_DONE_ST;
        end if;

      -- when others =>
      --  la_next <= LA_IDLE_ST;
    end case;
  end process;

  process (la_current)
  begin
    post_cnt_load <= '0';
    post_cnt_dec <= '0';
    dp_write <= '0';
    done <= '0';

    case la_current is
      when LA_IDLE_ST =>
        null;

      when LA_PREFILL_ST =>
        dp_write <= '1';

      when LA_ARMED_ST =>
        dp_write <= '1';
        post_cnt_load <= '1';

      when LA_RUN_ST =>
        dp_write <= '1';
        post_cnt_dec <= '1';

      when LA_DONE_ST =>
        done <= '1';

      -- when others => null;
    end case;
  end process;

  process (clk, reset)
  begin
    if reset = '1' then
      d_ptr <= (others => '0');
    elsif rising_edge(clk) then
      if la_current = LA_IDLE_ST then
        d_ptr <= (others => '0');
      elsif dp_write = '1' then
        d_ptr <= std_logic_vector(unsigned(d_ptr)+1);
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if reset = '1' then
      post_cnt <= (others => '0');
    elsif rising_edge(clk) then
      if post_cnt_load = '1' then
        post_cnt <= "0" & post_st;
      elsif post_cnt_dec = '1' then
        post_cnt <= std_logic_vector(unsigned(post_cnt) - 1);
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if reset = '1' then
      t_ptr <= (others => '0');
    elsif rising_edge(clk) then
      if trigger = '1' and la_current = LA_ARMED_ST then
        t_ptr <= d_ptr;
      end if;
    end if;
  end process;

  t_addr <= t_ptr(L_COUNTER_BITS-1 downto 0);

  dp_wadr <= d_ptr;
  dp_we   <= dp_write;

end rtl;
