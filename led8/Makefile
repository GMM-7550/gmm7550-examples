# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/gmm-7550/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <ak@gmm7550.dev>

PWD := $(shell pwd)

TOPDIR ?= $(PWD)/..
COMMONDIR ?= $(TOPDIR)/common
export TOPDIR
export COMMONDIR

include $(COMMONDIR)/defs.mk

# By default, top entity name is the same as an example directory
TOP := $(notdir $(PWD))

ROM_ADDR_WIDTH ?= 8

ROM_FILES := src/pattern_rom.vhd src/time_rom.vhd

VHDL_SRC := $(wildcard src/*.vhd)
VHDL_SRC += $(ROM_FILES)

CCF := $(IMPLDIR)/blink.ccf

EXTRA_GHDL_FLAGS := -gADDR_WIDTH=$(ROM_ADDR_WIDTH)

include $(COMMONDIR)/rules.mk
include $(COMMONDIR)/export.mk

$(CCF): | $(IMPLDIR)
	$(CAT) $(COMMONDIR)/gmm7550.ccf $(COMMONDIR)/hat-gmm7550.ccf > $@

$(ROM_FILES) &: src/rom_generator.lua Makefile
	(cd ./src && $(LUA) rom_generator.lua $(ROM_ADDR_WIDTH))

.PHONY: clean_rom

clean: clean_rom
clean_rom:
	$(RM) $(ROM_FILES)
