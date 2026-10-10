#!/usr/bin/env lua

local common = require "tools.lua.common"

-- Produce DPCM data.
common.convert_dpcm_files_in_directory("sound/dac/dpcm")

-- Build the ROM.
common.build_rom_and_handle_failure("main", "s1built", "", "-p=FF -z=0," .. "uncompressed" .. ",Size_of_DAC_driver_guess,after", false, "https://github.com/sonicretro/s1disasm")

-- A successful build; we can quit now.
common.exit()
