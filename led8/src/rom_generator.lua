local co = coroutine

local patterns = {
   {{
         {0x0000000f, 600},
         {0x000000f8, 500},
         {0x00000f84, 400},
         {0x0000f842, 400},
         {0x000f8421, 400},
         {0x00f84210, 400},
         {0x0f842100, 400},
         {0xf8421000, 400},
         {0x84210000, 400},
         {0x42100000, 400},
         {0x21000000, 400},
         {0x10000000, 400},
         {0x00000000, 1000},
         {0x00000000, 1000},
    }, 5},
   {{
         {0x80000008, 600},
         {0x48000084, 500},
         {0x24800842, 500},
         {0x12488421, 500},
         {0x012ff210, 500},
         {0x001ff100, 500},
         {0x000ff000, 500},
         {0x00844800, 500},
         {0x08422480, 500},
         {0x84211248, 500},
         {0x42100124, 500},
         {0x21000012, 500},
         {0x10000001, 500},
         {0x00000000, 1500},
    }, 5}
}

local addr_width = arg[1] or 8

local function rnd()
   return math.random(0, 15)
end

local get_pattern = co.wrap(function()
      for p_i = 1, #patterns do
         local p = patterns[p_i][1]
         for i = 1, patterns[p_i][2] do
            for j = 1, #p do
               co.yield(p[j])
            end
         end
      end

      while true do
         local p = 0
         for j = 1, 8 do
            p = p * 16 + rnd()
         end
         co.yield({p, 600})
      end
end)

local p_t = {}

for i = 1, 2^addr_width do
   p_t[i] = get_pattern()
end

local rom_file_begin = [[
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bcm_pkg.all;

entity %s is
  generic (
    ADDR_WIDTH : integer);
  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;
    addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    data  : out std_logic_vector(32-1 downto 0));
end entity %s;

architecture Lua of %s is
begin

 i_rom: entity work.rom
   generic map (
     DATA_WIDTH => %d,
     ADDR_WIDTH => ADDR_WIDTH,
     INIT => (
]]

local rom_file_end = [[)
   ) port map (
     clk => clk,
     rst_n => rst_n,
     addr  => addr,
     data  => data);
end architecture Lua;
]]

local format = string.format

local _pattern = "pattern_rom"
local _time    = "time_rom"

local fp = io.open(_pattern .. ".vhd", "w")
local ft = io.open(_time .. ".vhd", "w")

fp:write(format(rom_file_begin, _pattern, _pattern, _pattern, 32))
ft:write(format(rom_file_begin, _time, _time, _time, 32))

for i,v in ipairs(p_t) do
   fp:write(format("  %3d => x\"%08x\"", i-1, v[1]))
   ft:write(format("  %3d => x\"%08x\"", i-1, v[2]))
   if i < #p_t then
      fp:write(",\n")
      ft:write(",\n")
   end
end

fp:write(rom_file_end)
fp:close()

ft:write(rom_file_end)
ft:close()
