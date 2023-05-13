--
-- GMM-7550 IO connector pin assignments for Memory Extension Module
--

local direction = arg[1] or "east"

print("")
print("# Memory Extension Module IO assignments")
print("# for " .. direction .. " connector")
print("")

local gmm = require "gmm7550-io"

local addr = {
  -- 0..7
  [0] = 10, 12, 16, 18, 22, 46, 50, 52,
  -- 8..15
  56, 58, 57, 55, 51, 49, 45, 23,
  -- 16..18
  21, 17, 15
}

local data = {
  [0] = 28, 30, 38, 40, 43, 39, 37, 29
}

print([[Pin_out   "M_SPI_nCS"     Loc = "]] .. gmm[direction][  3 ] .. [[";]])
print([[Pin_out   "M_SPI_CLK"     Loc = "]] .. gmm[direction][  6 ] .. [[";]])
print([[Pin_out   "M_SPI_MOSI"    Loc = "]] .. gmm[direction][ 11 ] .. [[";]]) -- IO0
print([[Pin_in    "M_SPI_MISO"    Loc = "]] .. gmm[direction][  5 ] .. [[";]]) -- IO1

print([[Pin_inout "M_SPI_IO2"     Loc = "]] .. gmm[direction][  9 ] .. [[";]])
print([[Pin_inout "M_SPI_IO3"     Loc = "]] .. gmm[direction][  4 ] .. [[";]])

-- print("")
