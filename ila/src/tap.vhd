library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library cc;
use cc.gatemate.all;

entity tap is
  generic (
    DATA_WIDTH : integer := 20;
    ADDR_WIDTH : integer := 11;
    CSR_WIDTH  : integer := 8);
  port (
    reset  : in  std_logic;
    tck_i  : in  std_logic;
    tms_i  : in  std_logic;
    tdi_i  : in  std_logic;
    tdo_o  : out std_logic;

    tck   : out std_logic;
    tms   : out std_logic;
    tdi   : out std_logic;
    tdo   : out std_logic;
    tdo_en: out std_logic;

    -- System clock domain
    clk    : in  std_logic;
    cmd    : out std_logic_vector(CSR_WIDTH-1  downto 0);
    status : in  std_logic_vector(CSR_WIDTH-1  downto 0);
    t_mask : out std_logic_vector(DATA_WIDTH-1 downto 0);
    t_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    t_post : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    t_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);

    clk_o  : out std_logic;
    we_o   : out std_logic;
    addr_o : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    data_i : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data_o : out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity tap;

architecture rtl of tap is
  constant IR_LENGHT : integer := 4;
  constant SHIFT_LENGTH_MAX : integer := maximum(DATA_WIDTH, ADDR_WIDTH);

  constant I_CMD    : std_logic_vector(IR_LENGHT-1 downto 0) := "0100";
  constant I_STATUS : std_logic_vector(IR_LENGHT-1 downto 0) := "0101";
  constant I_DATA   : std_logic_vector(IR_LENGHT-1 downto 0) := "0110";
  constant I_ADDR   : std_logic_vector(IR_LENGHT-1 downto 0) := "0111";
  constant I_T_DATA : std_logic_vector(IR_LENGHT-1 downto 0) := "1000";
  constant I_T_MASK : std_logic_vector(IR_LENGHT-1 downto 0) := "1001";
  constant I_T_POST : std_logic_vector(IR_LENGHT-1 downto 0) := "1010";
  constant I_T_ADDR : std_logic_vector(IR_LENGHT-1 downto 0) := "1110";

  signal tck_b : std_logic;
  signal tlr, rti : std_logic;
  signal sdi, capture, shift, update : std_logic;
  signal d_shift : std_logic_vector(SHIFT_LENGTH_MAX-1 downto 0);

  signal cmd_latch    : std_logic_vector(CSR_WIDTH-1  downto 0);
  signal addr_latch   : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal data_latch   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal t_mask_latch : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal t_data_latch : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal t_post_latch : std_logic_vector(ADDR_WIDTH-1 downto 0);

  signal instr : std_logic_vector(IR_LENGHT-1 downto 0);
  signal i_upd : std_logic;
begin

  i_tck: component CC_IBUF
    generic map (
      PIN_NAME => "IO_WA_A5",
      V_IO => "2.5V",
      SCHMITT_TRIGGER => 1)
    port map (
      I => tck_i,
      Y => tck_b);

  i_tckg: component CC_BUFG
    port map (
      I => tck_b,
      O => tck);

  i_tms: component CC_IBUF
    generic map (
      PIN_NAME => "IO_WA_B4",
      SCHMITT_TRIGGER => 1)
    port map (
      I => tms_i,
      Y => tms);

  i_tdi: component CC_IBUF
    generic map (
      PIN_NAME => "IO_WA_A4")
    port map (
      I => tdi_i,
      Y => tdi);

  i_tdo: component CC_TOBUF
    generic map (
      PIN_NAME => "IO_WA_B3")
    port map (
      A => tdo,
      T => not tdo_en,
      O => tdo_o);

  i_tap_ctrl: entity work.tap_ctrl
    generic map (
      IR_LENGHT => IR_LENGHT,
      IDCODE    => "0001",
      MANUFACTURER_ID => "11101110000",
      PART_NUMBER => x"c0ff",
      VERSION => x"1"
      )
    port map (
      reset  => reset,
      tck    => tck,
      tms    => tms,
      tdi    => tdi,
      tdo    => tdo,
      tdo_en => tdo_en,

      tlr    => tlr,
      rti    => rti,

      instr  => instr,
      i_upd  => i_upd,

      sdi    => sdi,
      capture=> capture,
      shift  => shift,
      update => update);

  -- process(tck) is
  -- begin
  --   if rising_edge(tck) then
  --     if tlr = '1' then
  --       shift_length <= 1;
  --     elsif i_upd = '1' then
  --       case instr is
  --         when I_CMD    => shift_length <= CSR_WIDTH;
  --         when I_STATUS => shift_length <= CSR_WIDTH;
  --         when I_DATA   => shift_length <= DATA_WIDTH;
  --         when I_ADDR   => shift_length <= ADDR_WIDTH;
  --         when I_T_MASK => shift_length <= DATA_WIDTH;
  --         when I_T_DATA => shift_length <= DATA_WIDTH;
  --         when I_T_POST => shift_length <= ADDR_WIDTH;
  --         when I_T_ADDR => shift_length <= ADDR_WIDTH;
  --         when others => shift_length <= 1;
  --       end case;
  --     end if;
  --   end if;
  -- end process;

  -- sdi <= d_shift(SHIFT_LENGTH_MAX - shift_length);

  sdi_mux_p: process (instr, d_shift)
  begin
    case instr is
      when I_CMD    => sdi <= d_shift(d_shift'left - CSR_WIDTH  + 1);
      when I_STATUS => sdi <= d_shift(d_shift'left - CSR_WIDTH  + 1);
      when I_DATA   => sdi <= d_shift(d_shift'left - DATA_WIDTH + 1);
      when I_ADDR   => sdi <= d_shift(d_shift'left - ADDR_WIDTH + 1);
      when I_T_MASK => sdi <= d_shift(d_shift'left - DATA_WIDTH + 1);
      when I_T_DATA => sdi <= d_shift(d_shift'left - DATA_WIDTH + 1);
      when I_T_POST => sdi <= d_shift(d_shift'left - ADDR_WIDTH + 1);
      when I_T_ADDR => sdi <= d_shift(d_shift'left - ADDR_WIDTH + 1);
      when others   => sdi <= d_shift(d_shift'left);
    end case;
  end process sdi_mux_p;

  shift_reg_p: process (tck)
  begin
    if rising_edge(tck) then
      if tlr = '1' then
        d_shift <= (others =>'0');
      elsif capture = '1' then
        case instr is

          when I_CMD =>
            d_shift <= cmd_latch & std_logic_vector(to_unsigned(0, d_shift'length - CSR_WIDTH));

          when I_STATUS =>
            d_shift <= status & std_logic_vector(to_unsigned(0, d_shift'length - CSR_WIDTH));

          when I_DATA =>
            d_shift <= data_i & std_logic_vector(to_unsigned(0, d_shift'length - DATA_WIDTH));

          when I_ADDR =>
            d_shift <= addr_latch & std_logic_vector(to_unsigned(0, d_shift'length - ADDR_WIDTH));

          when I_T_ADDR =>
            d_shift <= t_addr & std_logic_vector(to_unsigned(0, d_shift'length - ADDR_WIDTH));

          when I_T_DATA =>
            d_shift <= t_data_latch & std_logic_vector(to_unsigned(0, d_shift'length - DATA_WIDTH));

          when I_T_MASK =>
            d_shift <= t_mask_latch & std_logic_vector(to_unsigned(0, d_shift'length - DATA_WIDTH));

          when I_T_POST =>
            d_shift <= t_post_latch & std_logic_vector(to_unsigned(0, d_shift'length - ADDR_WIDTH));

          when others => d_shift <= (others => '0');
        end case;
      elsif shift = '1' then
        d_shift <= tdi & d_shift(d_shift'left downto 1);
      end if;
    end if;
  end process;

  latch_reg_p: process (tlr, tck)
  begin
    if tlr = '1' then
      cmd_latch    <= (others => '0');
      data_latch   <= (others => '0');
      addr_latch   <= (others => '0');
      t_mask_latch <= (others => '0');
      t_data_latch <= (others => '0');
      t_post_latch <= (others => '0');
    elsif falling_edge(tck) then
      if update = '1' then
        case instr is

          when I_CMD =>
            cmd_latch <= d_shift(d_shift'left downto d_shift'left - CSR_WIDTH + 1);

          when I_DATA =>
            data_latch <= d_shift(d_shift'left downto d_shift'left - DATA_WIDTH + 1);

          when I_ADDR =>
            addr_latch <= d_shift(d_shift'left downto d_shift'left - ADDR_WIDTH + 1);

          when I_T_MASK =>
            t_mask_latch <= d_shift(d_shift'left downto d_shift'left - DATA_WIDTH + 1);

          when I_T_DATA =>
            t_data_latch <= d_shift(d_shift'left downto d_shift'left - DATA_WIDTH + 1);

          when I_T_POST =>
            t_post_latch <= d_shift(d_shift'left downto d_shift'left - ADDR_WIDTH + 1);

          when others => null;
        end case;
      end if;
    end if;
  end process latch_reg_p;

  -- no sync: tck clock domain
  clk_o  <= tck and (capture or update);
  we_o   <= update when instr = I_DATA else '0';
  addr_o <= addr_latch;
  data_o <= data_latch;

  -- Sync output vectors to system clock domain
  cmd_sync_i: entity work.ddff_vector
    generic map (DATA_WIDTH => CSR_WIDTH)
    port map (
      clk => clk,
      di  => cmd_latch,
      do  => cmd);

  t_mask_sync_i: entity work.ddff_vector
    generic map (DATA_WIDTH => DATA_WIDTH)
    port map (
      clk => clk,
      di  => t_mask_latch,
      do  => t_mask);

  t_data_sync_i: entity work.ddff_vector
    generic map (DATA_WIDTH => DATA_WIDTH)
    port map (
      clk => clk,
      di  => t_data_latch,
      do  => t_data);

  t_post_sync_i: entity work.ddff_vector
    generic map (DATA_WIDTH => ADDR_WIDTH)
    port map (
      clk => clk,
      di  => t_post_latch,
      do  => t_post);

end architecture rtl;
