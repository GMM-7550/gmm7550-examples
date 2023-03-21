library ieee;
use ieee.std_logic_1164.all;

package gatemate is

  component CC_USR_RSTN is
    port (
      USR_RSTN : out std_logic
      );
  end component CC_USR_RSTN;

  component CC_PLL is
    generic (
      REF_CLK         : string  := "0"; -- e.g. "10.0"
      OUT_CLK         : string  := "0"; -- e.g. "50.0"
      PERF_MD         : string  := "UNDEFINED"; -- LOWPOWER, ECONOMY, SPEED
      LOW_JITTER      : integer := 1;
      LOCK_REQ        : integer := 1; -- PLL lock required before output enable
      CLK270_DOUB     : integer := 0; -- clock doubling on CLK270_OUT
      CLK180_DOUB     : integer := 0; -- clock doubling on CLK180_OUT

      -- Integral coefficient of loop filter, should be greater than zero.
      CI_FILTER_CONST : integer := 2;
      -- Proportional coefficient of loop filter, should be greater than CI.
      CP_FILTER_CONST : integer := 4
      -- The higher the CP/CI ratio is, the more stable is the loop
      -- (phase margin). Higher CP lead to larger period jitter.
      );
    port (
      CLK_REF             : in  std_logic;
      USR_CLK_REF         : in  std_logic;
      CLK_FEEDBACK        : in  std_logic;

      USR_LOCKED_STDY_RST : in  std_logic;
      USR_PLL_LOCKED_STDY : out std_logic;
      USR_PLL_LOCKED      : out std_logic;

      CLK0                : out std_logic;
      CLK90               : out std_logic;
      CLK180              : out std_logic;
      CLK270              : out std_logic;
      CLK_REF_OUT         : out std_logic
      );
  end component CC_PLL;

end package gatemate;
