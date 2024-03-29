-------------------------------------------------------------------------------
-- This file is a part of the GMM-7550 VHDL Examples
-- <https://github.com/gmm-7550/gmm7550-examples.git>
--
-- SPDX-License-Identifier: MIT
--
-- Copyright (c) 2023 Anton Kuzmin <ak@gmm7550.dev>
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
-- GateMate FPGA Primitives Library
-------------------------------------------------------------------------------
package gatemate is

  -----------------------------------------------------------------------------
  -- I/O Buffers
  -----------------------------------------------------------------------------
  component CC_IBUF is
    generic (
      PIN_NAME  : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
                                          -- dir:  N, E, S, W
                                          -- bank: A, B, C
                                          -- pin:  A, B
                                          -- pin#: 0..8
      V_IO      : string  := "UNDEFINED"; -- 1.2, 1.8 or 2.5 V
      PULLUP    : integer := 0;           -- 0: disable, 1: enable
      PULLDOWN  : integer := 0;           -- 0: disable, 1: enable
      KEEPER    : integer := 0;           -- 0: disable, 1: enable
      SCHMITT_TRIGGER : integer := 0;     -- 0: disable, 1: enable
      DELAY_IBF : integer := 0;           -- 0..15 x 50 ps
      FF_IBF    : integer := 0            -- 0: disable, 1: enable
      );
    port (
      I : in  std_logic; -- input from device pin
      Y : out std_logic  -- output to FPGA-internal circuitry
      );
  end component CC_IBUF;

  component CC_OBUF is
    generic (
      PIN_NAME  : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      V_IO      : string  := "UNDEFINED"; -- 1.2, 1.8 or 2.5
      DRIVE     : string  := "3";         -- 3, 6, 9, 12 mA
      SLEW      : string  := "UDEFINED";  -- SLOW or FAST
      DELAY_OBF : integer := 0;           -- 0..15 x 50 ps
      FF_OBF    : integer := 0            -- 0: disable, 1: enable
      );
    port (
      A : in  std_logic;
      O : out std_logic
      );
  end component CC_OBUF;

  component CC_TOBUF is
    generic (
      PIN_NAME  : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      V_IO      : string  := "UNDEFINED"; -- 1.2, 1.8 or 2.5
      DRIVE     : string  := "3";         -- 3, 6, 9, 12 mA
      SLEW      : string  := "UDEFINED";  -- SLOW or FAST
      PULLUP    : integer := 0;           -- 0: disable, 1: enable
      PULLDOWN  : integer := 0;           -- 0: disable, 1: enable
      KEEPER    : integer := 0;           -- 0: disable, 1: enable
      DELAY_OBF : integer := 0;           -- 0..15 x 50 ps
      FF_OBF    : integer := 0            -- 0: disable, 1: enable
      );
    port (
      A : in  std_logic; -- input from FPGA-internal circuitry
      T : in  std_logic; -- active Low output enable
      O : out std_logic  -- tri-state if T = 1
      );
  end component CC_TOBUF;

  component CC_IOBUF is
    generic (
      PIN_NAME  : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      V_IO      : string  := "UNDEFINED"; -- 1.2, 1.8 or 2.5
      DRIVE     : string  := "3";         -- 3, 6, 9, 12 mA
      SLEW      : string  := "UDEFINED";  -- SLOW or FAST
      PULLUP    : integer := 0;           -- 0: disable, 1: enable
      PULLDOWN  : integer := 0;           -- 0: disable, 1: enable
      KEEPER    : integer := 0;           -- 0: disable, 1: enable
      DELAY_OBF : integer := 0;           -- 0..15 x 50 ps
      FF_OBF    : integer := 0            -- 0: disable, 1: enable
      );
    port (
      A  : in    std_logic; -- input from FPGA-internal circuitry
      T  : in    std_logic; -- active Low output enable from FPGA-internal circuitry
      Y  : out   std_logic; -- output to FPGA-internal circuitry
      IO : inout std_logic  -- bidirectional in- or output to device pin
      );
  end component CC_IOBUF;

  component CC_LVDS_IBUF is
    generic (
      PIN_NAME_P : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      PIN_NAME_N : string  := "UNPLACED";
      V_IO       : string  := "UNDEFINED"; -- 1.8 or 2.5 V
      LVDS_RTERM : integer := 0;           -- 0: disable, 1: enable
      DELAY_IBF  : integer := 0;           -- 0..15 x 50 ps
      FF_IBF     : integer := 0            -- 0: disable, 1: enable
      );
    port (
      I_P : in  std_logic; -- positive differential input from device pin
      I_N : in  std_logic; -- negative differential input from device pin
      Y   : out std_logic  -- output to FPGA-internal circuitry
      );
  end component CC_LVDS_IBUF;

  component CC_LVDS_OBUF is
    generic (
      PIN_NAME_P : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      PIN_NAME_N : string  := "UNPLACED";
      V_IO       : string  := "UNDEFINED"; -- 1.8 or 2.5 V
      LVDS_BOOST : integer := 0;           -- 0: 3.2 mA nominal current, default
                                           -- 1: 6.4 mA increased current
      DELAY_OBF : integer := 0;           -- 0..15 x 50 ps
      FF_OBF    : integer := 0            -- 0: disable, 1: enable
      );
    port (
      A   : in  std_logic; -- input from FPGA-internal circuitry
      O_P : out std_logic; -- positive differential output to device pin
      O_N : out std_logic  -- negative differential output to device pin
      );
  end component CC_LVDS_OBUF;

  component CC_LVDS_TOBUF is
    generic (
      PIN_NAME_P : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      PIN_NAME_N : string  := "UNPLACED";
      V_IO       : string  := "UNDEFINED"; -- 1.8 or 2.5 V
      LVDS_BOOST : integer := 0;           -- 0: 3.2 mA nominal current, default
                                           -- 1: 6.4 mA increased current
      DELAY_OBF  : integer := 0;           -- 0..15 x 50 ps
      FF_OBF     : integer := 0            -- 0: disable, 1: enable
      );
    port (
      A   : in  std_logic; -- input from FPGA-internal circuitry
      T   : in  std_logic; -- active Low output enable from FPGA-internal circuitry
      O_P : out std_logic; -- positive differential output to device pin
      O_N : out std_logic  -- negative differential output to device pin
      );
  end component CC_LVDS_TOBUF;

  component CC_LVDS_IOBUF is
    generic (
      PIN_NAME_P : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      PIN_NAME_N : string  := "UNPLACED";
      V_IO       : string  := "UNDEFINED"; -- 1.8 or 2.5 V
      LVDS_RTERM : integer := 0;           -- 0: disable, 1: enable
      LVDS_BOOST : integer := 0;           -- 0: 3.2 mA nominal current, default
                                           -- 1: 6.4 mA increased current
      DELAY_IBF  : integer := 0;           -- 0..15 x 50 ps
      DELAY_OBF  : integer := 0;           -- 0..15 x 50 ps
      FF_IBF     : integer := 0;           -- 0: disable, 1: enable
      FF_OBF     : integer := 0            -- 0: disable, 1: enable
      );
    port (
      A    : in    std_logic; -- input from FPGA-internal circuitry
      T    : in    std_logic; -- active Low output enable from FPGA-internal circuitry
      Y    : out   std_logic; -- output to FPGA-internal circuitry
      IO_P : inout std_logic; -- positive differential bidirectional signal to device pin
      IO_N : inout std_logic  -- negative differential bidirectional signal to device pin
      );
  end component CC_LVDS_IOBUF;

  component CC_IDDR is
    generic (
      CLK_INV : integer := 0  -- clock polarity for Q0
                              -- 0: rising edge (default)
                              -- 1: falling edge
      );
    port (
      D   : in  std_logic; -- data input from any input buffer
      CLK : in  std_logic; -- clock signal input
      Q0  : out std_logic; -- data output to FPGA-internal circuitry
      Q1  : out std_logic  -- data output to FPGA-internal circuitry
      );
  end component CC_IDDR;

  component CC_ODDR is
    generic (
      CLK_INV : integer := 0  -- clock polarity for Q0
                              -- 0: rising edge (default)
                              -- 1: falling edge
      );
    port (
      D0  : in  std_logic; -- data input from FPGA-internal circuitry
      D1  : in  std_logic; -- data input from FPGA-internal circuitry
      CLK : in  std_logic; -- clock signal input to flip-flops
      DDR : in  std_logic; -- clock signal input to flip-flop switch
      Q   : out std_logic  -- data output to any output buffer
      );
  end component CC_ODDR;

  -----------------------------------------------------------------------------
  -- Registers/Latches
  -----------------------------------------------------------------------------
  component CC_DFF is
    generic (
      CLK_INV : integer := 0; -- clock polarity, 0: rising edge, 1: falling edge
      EN_INV  : integer := 0; -- enable signal inversion, 0: disable, 1: enable
      SR_INV  : integer := 0; -- set/reset signal inversion
      SR_VAL  : integer := 0; -- 0: reset to zero, 1: set to one
      INIT    : integer := 0  -- initial value of Q output after configuration
      );
    port (
      D   : in  std_logic; -- data input
      CLK : in  std_logic; -- clock signal
      EN  : in  std_logic; -- clock enable signal
      SR  : in  std_logic; -- configurable asynchronous  set/reset signal
      Q   : out std_logic  -- data output
      );
  end component CC_DFF;

  component CC_DLT is
    generic (
      G_INV   : integer := 0; -- enable signal inverting
      SR_INV  : integer := 0; -- set/reset signal inversion
      SR_VAL  : integer := 0; -- 0: reset to zero, 1: set to one
      INIT    : integer := 0  -- initial value of Q output after configuration
      );
    port (
      D  : in  std_logic; -- data input
      G  : in  std_logic; -- enable input
      SR : in  std_logic; -- configurable asynchronous set/reset signal
      Q  : out std_logic  -- data output
      );
  end component CC_DLT;

  -----------------------------------------------------------------------------
  -- LUT
  -----------------------------------------------------------------------------
  component CC_LUT1 is
    generic (
      INIT : std_logic_vector(1 downto 0) := "00"
      );
    port (
      I0 : in  std_logic;
      O  : out std_logic
      );
  end component CC_LUT1;

  component CC_LUT2 is
    generic (
      INIT : std_logic_vector(3 downto 0) := "0000"
      );
    port (
      I0 : in  std_logic;
      I1 : in  std_logic;
      O  : out std_logic
      );
  end component CC_LUT2;

  component CC_LUT3 is
    generic (
      INIT : std_logic_vector(7 downto 0) := x"00"
      );
    port (
      I0 : in  std_logic;
      I1 : in  std_logic;
      I2 : in  std_logic;
      O  : out std_logic
      );
  end component CC_LUT3;

  component CC_LUT4 is
    generic (
      INIT : std_logic_vector(15 downto 0) := x"0000"
      );
    port (
      I0 : in  std_logic;
      I1 : in  std_logic;
      I2 : in  std_logic;
      I3 : in  std_logic;
      O  : out std_logic
      );
  end component CC_LUT4;

  --        +-----+
  -- I0 --->|     |
  --        | L00 |---\
  -- I1 --->|     |   |    +-----+
  --        +-----+   \--->|     |
  --                       | L10 |---> O
  --        +-----+   /--->|     |
  -- I2 --->|     |   |    +-----+
  --        | L01 |---/
  -- I3 --->|     |
  --        +-----+
  --
  -- Figure 4.1 CC_L2T4 primitive schematic
  -- GateMate FPGA User Guide
  -- Primitivers Library
  component CC_L2T4 is
    generic (
      INIT_L00 : std_logic_vector(3 downto 0) := x"0"; -- LUT L00 configuration
      INIT_L01 : std_logic_vector(3 downto 0) := x"0"; -- LUT L01 configuration
      INIT_L10 : std_logic_vector(3 downto 0) := x"0"  -- LUT L10 configuration
      );
    port (
      I0 : in  std_logic;
      I1 : in  std_logic;
      I2 : in  std_logic;
      I3 : in  std_logic;
      O  : out std_logic
      );
  end component CC_L2T4;

  -- I4 -----------------------------\
  --                                 |    +-----+
  --        +-----+                  \--->|     |
  -- I0 --->|     |                       | L20 |---> O
  --        | L02 |---\              /--->|     |
  -- I1 --->|     |   |    +-----+   |    +-----+
  --        +-----+   \--->|     |   |
  --                       | L11 |---/
  --        +-----+   /--->|     |
  -- I2 --->|     |   |    +-----+
  --        | L03 |---/
  -- I3 --->|     |
  --        +-----+
  --
  -- Figure 4.3 CC_L2T5 primitive schematic
  -- GateMate FPGA User Guide
  -- Primitivers Library
  component CC_L2T5 is
    generic (
      INIT_L02 : std_logic_vector(3 downto 0) := x"0"; -- LUT L02 configuration
      INIT_L03 : std_logic_vector(3 downto 0) := x"0"; -- LUT L03 configuration
      INIT_L11 : std_logic_vector(3 downto 0) := x"0"; -- LUT L11 configuration
      INIT_L20 : std_logic_vector(3 downto 0) := x"0"  -- LUT L20 configuration
      );
    port (
      I0 : in  std_logic;
      I1 : in  std_logic;
      I2 : in  std_logic;
      I3 : in  std_logic;
      I4 : in  std_logic;
      O  : out std_logic
      );
  end component CC_L2T5;

  --        +------+
  -- I0 --->|      |
  -- I1 --->| L2T4 |---+---> O0
  -- I2 --->|      |   |
  -- I3 --->|      |   |
  --        +------+   |
  --   /---------------/
  --   |    +------+
  --   \--->|      |
  -- I4 --->| L2T5 |-------> O1
  -- I5 --->|      |
  -- I6 --->|      |
  -- I7 --->|      |
  --        +------+
  --
  -- Figure 4.4: Combined CC_L2T4 and CC_L2T5
  -- primitives forming an 8-input LUT-tree

  -----------------------------------------------------------------------------
  -- Multiplexers
  -----------------------------------------------------------------------------
  component CC_MX2 is
    port (
      D0 : in  std_logic;
      D1 : in  std_logic;
      S0 : in  std_logic;
      Y  : out std_logic
      );
  end component CC_MX2;

  component CC_MX4 is
    port (
      D0 : in  std_logic;
      D1 : in  std_logic;
      D2 : in  std_logic;
      D3 : in  std_logic;
      S0 : in  std_logic;
      S1 : in  std_logic;
      Y  : out std_logic
      );
  end component CC_MX4;

  -----------------------------------------------------------------------------
  -- Arithmetic Functions
  -----------------------------------------------------------------------------

  -- Full adder using dedicated logic and routing resources inside
  -- and between CPE cells. Two cascaded CC_ADDF primitives can be combined
  -- into a single CPE forming a two-bit full adder.
  component CC_ADDF is
    port (
      A  : in  std_logic;
      B  : in  std_logic;
      CI : in  std_logic;
      CO : out std_logic;
      S  : out std_logic
      );
  end component CC_ADDF;

  -- The CC_MULT primitive is a scalable, signed multiplier with inputs of any width
  component CC_MULT is
    generic (
      A_WIDTH : integer := 2; -- maximum 100
      B_WIDTH : integer := 2;
      P_WIDTH : integer := 4
      );
    port (
      A : in  std_logic_vector(A_WIDTH-1 downto 0);
      B : in  std_logic_vector(B_WIDTH-1 downto 0);
      P : out std_logic_vector(P_WIDTH-1 downto 0)
      );
  end component CC_MULT;

  -----------------------------------------------------------------------------
  -- Block RAM
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Special Function Blocks
  -----------------------------------------------------------------------------
  component CC_BUFG is
    port (
      I : in  std_logic;
      O : out std_logic
      );
  end component CC_BUFG;

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

  component CC_PLL_ADV is
    generic (
      PLL_CFG_A           : std_logic_vector(95 downto 0);
      PLL_CFG_B           : std_logic_vector(95 downto 0)
      );
    port (
      CLK_REF             : in  std_logic;
      USR_CLK_REF         : in  std_logic;
      USR_SEL_A_B         : in  std_logic;
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
  end component CC_PLL_ADV;

  component CC_CFG_CTRL is
    port (
      CLK   : in  std_logic;
      DATA  : in  std_logic_vector(7 downto 0);
      VALID : in  std_logic;
      EN    : in  std_logic;
      RECFG : in  std_logic
      );
  end component CC_CFG_CTRL;

end package gatemate;
