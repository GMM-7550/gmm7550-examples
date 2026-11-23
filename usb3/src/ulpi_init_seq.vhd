library ieee;
use ieee.std_logic_1164.all;

entity ulpi_init_seq is
  generic (
    N_SYNC_STAGES : integer := 2;

    ULPI_REG_1 : std_logic_vector(5 downto 0) := "000100"; -- 0x04
    ULPI_DAT_1 : std_logic_vector(7 downto 0) := x"48";
    ULPI_REG_2 : std_logic_vector(5 downto 0) := "011001"; -- 0x19
    ULPI_DAT_2 : std_logic_vector(7 downto 0) := x"30";
    ULPI_REG_3 : std_logic_vector(5 downto 0) := "000111"; -- 0x07
    ULPI_DAT_3 : std_logic_vector(7 downto 0) := x"04");
  port (
    clk_i  : in  std_logic; -- 60 MHz input from a PHY
    rst_i  : in  std_logic;

    -- ULPI Signals
    dir    : in  std_logic;
    nxt    : in  std_logic;
    stp    : out std_logic;
    dat_i  : in  std_logic_vector(7 downto 0);
    dat_o  : out std_logic_vector(7 downto 0);
    dat_oe : out std_logic;
    done   : out std_logic
    );
end entity ulpi_init_seq;

architecture rtl of ulpi_init_seq is
  signal reset : std_logic;
  signal rst_sync : std_logic_vector(N_SYNC_STAGES downto 0); -- no '-1'

  type ulpi_wr_fsm_t is (wr_fsm_idle_st, wr_fsm_wait_dir_st, wr_fsm_wait_nxt_st,
                         wr_fsm_dat_st, wr_fsm_stp_st);
  signal wr_fsm_state : ulpi_wr_fsm_t;
  signal wr_fsm_next  : ulpi_wr_fsm_t;

  signal ulpi_wr_start : std_logic;
  signal ulpi_wr_done  : std_logic;

  signal ulpi_reg : std_logic_vector(5 downto 0);
  signal ulpi_dat : std_logic_vector(7 downto 0);

  type init_fsm_t is (init_idle_st, init_start_st,
                      init_wr1_st, init_wr2_st, init_wr3_st,
                      init_done_st);
  signal init_fsm_state : init_fsm_t;
  signal init_fsm_next  : init_fsm_t;

begin

  -- Sync Reset to ULPI clock
  p_rst_sync: process(rst_i, clk_i) is
  begin
    if rst_i = '1' then
      rst_sync <= (others => '1');
    elsif rising_edge(clk_i) then
      rst_sync <= rst_sync(rst_sync'left - 1 downto 0) & '0';
    end if;
  end process p_rst_sync;

  reset <= rst_sync(rst_sync'left-1);

  -- Write ULPI Register
  p_ulpi_wr_state: process(reset, clk_i) is
  begin
    if reset = '1' then
      wr_fsm_state <= wr_fsm_idle_st;
    elsif rising_edge(clk_i) then
      wr_fsm_state <= wr_fsm_next;
    end if;
  end process p_ulpi_wr_state;

  p_ulpi_wr: process(all) is
  begin
    wr_fsm_next  <= wr_fsm_idle_st;
    ulpi_wr_done <= '0';

    dat_o  <= (others => '0');
    dat_oe <= not dir;
    stp    <= '0';

    case wr_fsm_state is
      when wr_fsm_idle_st =>
        if ulpi_wr_start = '1' then
          wr_fsm_next <= wr_fsm_wait_dir_st;
        else
          wr_fsm_next <= wr_fsm_idle_st;
        end if;

      when wr_fsm_wait_dir_st =>
        if dir = '0' then
          wr_fsm_next <= wr_fsm_wait_nxt_st;
        else
          wr_fsm_next <= wr_fsm_wait_dir_st;
        end if;

      when wr_fsm_wait_nxt_st =>
        dat_o  <= "10" & ulpi_reg;
        dat_oe <= '1';
        if nxt = '0' then
          wr_fsm_next <= wr_fsm_wait_nxt_st;
        else
          wr_fsm_next <= wr_fsm_dat_st;
        end if;

      when wr_fsm_dat_st =>
        wr_fsm_next <= wr_fsm_stp_st;
        dat_o  <= ulpi_dat;
        dat_oe <= '1';

      when wr_fsm_stp_st =>
        wr_fsm_next <= wr_fsm_idle_st;
        stp <= '1';
        ulpi_wr_done <= '1';

      -- when others => null;
    end case;
  end process p_ulpi_wr;

  -- Initialization data write sequencer
  -- 3 register writes to enter Audio Mode
  -- (to connect LS/FS transceiver to the D+/D- lines)
  p_init_state: process(reset, clk_i) is
  begin
    if reset = '1' then
      init_fsm_state <= init_idle_st;
    elsif rising_edge(clk_i) then
      init_fsm_state <= init_fsm_next;
    end if;
  end process p_init_state;

  p_init_fsm: process(all) is
  begin
    init_fsm_next <= init_idle_st;
    ulpi_wr_start <= '0';
    ulpi_reg <= (others => '0');
    ulpi_dat <= (others => '0');
    done <= '0';

    case init_fsm_state is
      when init_idle_st =>
        init_fsm_next <= init_start_st;

      when init_start_st =>
        init_fsm_next <= init_wr1_st;

      when init_wr1_st =>
        ulpi_reg <= ULPI_REG_1;
        ulpi_dat <= ULPI_DAT_1;
        ulpi_wr_start <= '1';
        if ulpi_wr_done = '0' then
          init_fsm_next <= init_wr1_st;
        else
          init_fsm_next <= init_wr2_st;
        end if;

      when init_wr2_st =>
        ulpi_reg <= ULPI_REG_2;
        ulpi_dat <= ULPI_DAT_2;
        ulpi_wr_start <= '1';
        if ulpi_wr_done = '0' then
          init_fsm_next <= init_wr2_st;
        else
          init_fsm_next <= init_wr3_st;
        end if;

      when init_wr3_st =>
        ulpi_reg <= ULPI_REG_3;
        ulpi_dat <= ULPI_DAT_3;
        ulpi_wr_start <= '1';
        if ulpi_wr_done = '0' then
          init_fsm_next <= init_wr3_st;
        else
          init_fsm_next <= init_done_st;
        end if;

      when init_done_st =>
        done <= '1';
        init_fsm_next <= init_done_st;

      -- when others => null;
    end case;
  end process p_init_fsm;

end architecture;
