library ieee;
use ieee.std_logic_1164.all;

library cc;
use cc.gatemate.all;

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
    reb   : in  std_logic;
    web   : in  std_logic;
    addrb : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    dib   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    dob   : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end entity dpram;

architecture bram_40k_inst of dpram is
  constant BRAM_DATA_WIDTH : integer := 40;
  constant BRAM_ADDR_WIDTH : integer := 16;

  signal A_DI   : std_logic_vector(BRAM_DATA_WIDTH-1 downto 0);
  signal B_DI   : std_logic_vector(BRAM_DATA_WIDTH-1 downto 0);
  signal A_BM   : std_logic_vector(BRAM_DATA_WIDTH-1 downto 0);
  signal B_BM   : std_logic_vector(BRAM_DATA_WIDTH-1 downto 0);

  signal A_ADDR : std_logic_vector(BRAM_ADDR_WIDTH-1 downto 0);
  signal B_ADDR : std_logic_vector(BRAM_ADDR_WIDTH-1 downto 0);

  signal A_EN   : std_logic;
  signal B_EN   : std_logic;
  signal A_WE   : std_logic;
  signal B_WE   : std_logic;

  signal A_DO   : std_logic_vector(BRAM_DATA_WIDTH-1 downto 0);
  signal B_DO   : std_logic_vector(BRAM_DATA_WIDTH-1 downto 0);

begin

  A_ADDR <= addra & "00000";

  A_BM <= x"00000fffff" when wea = '1' else (others => '0');
  A_DI <= x"00000" & dia;
  doa  <= A_DO(doa'range);

  A_EN <= wea;
  A_WE <= wea;

  B_ADDR <= addrb & "00000";

  B_BM <= x"00000fffff" when web = '1' else (others => '0');
  B_DI <= x"00000" & dib;
  dob  <= B_DO(dob'range);

  B_EN <= reb or web;
  B_WE <= web;

  bram_i: component CC_BRAM_40K
    generic map (
      RAM_MODE   => "TDP",
      A_RD_WIDTH => 20,
      A_WR_WIDTH => 20,
      B_RD_WIDTH => 20,
      B_WR_WIDTH => 20,
      A_WR_MODE  => "NO_CHANGE", -- "WRITE_THROUGH",
      B_WR_MODE  => "NO_CHANGE"
      )
    port map (
      A_DI   => A_DI,
      B_DI   => B_DI,
      A_BM   => A_BM,
      B_BM   => B_BM,

      A_ADDR => A_ADDR,
      B_ADDR => B_ADDR,

      A_CLK  => clka,
      B_CLK  => clkb,

      A_EN   => A_EN,
      B_EN   => B_EN,
      A_WE   => A_WE,
      B_WE   => B_WE,

      A_DO   => A_DO,
      B_DO   => B_DO

      -- A_ECC_1B_ERR => open,
      -- A_ECC_2B_ERR => open,
      -- B_ECC_1B_ERR => open,
      -- B_ECC_2B_ERR => open
      );
end architecture bram_40k_inst;

-- library ieee;
-- use ieee.numeric_std.all;

-- architecture ram_inference of dpram is
--   type ram is array (0 to (2**ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
--   shared variable memory : ram;
-- begin

--   doa <= (others => '0');

--   -- process(clka)
--   -- begin
--   --   if rising_edge(clka) then
--   --     if wea = '1' then
--   --       memory(to_integer(unsigned(addra))) := dia;
--   --     else
--   --       doa <= memory(to_integer(unsigned(addra)));
--   --     end if;
--   --   end if;
--   -- end process;

--   process(clkb)
--   begin
--     if rising_edge(clkb) then
--       if web = '1' then
--         memory(to_integer(unsigned(addrb))) := dib;
--       else
--         dob <= addrb(3 downto 0) & memory(to_integer(unsigned(addrb)))(DATA_WIDTH-5 downto 0);
--       end if;
--     end if;
--   end process;

-- end architecture ram_inference;
