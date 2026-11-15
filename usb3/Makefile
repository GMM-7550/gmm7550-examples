# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/gmm-7550/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023-2026 Anton Kuzmin <ak@gmm7550.dev>

PWD := $(shell pwd)

TOPDIR ?= $(PWD)/..
COMMONDIR ?= $(TOPDIR)/common
export TOPDIR
export COMMONDIR

include $(COMMONDIR)/defs.mk

# By default, top entity name is the same as an example directory
TOP := $(notdir $(PWD))

VHDL_SRC := $(wildcard src/*.vhd)

ILA_SRC := src-ila
VHDL_SRC += $(ILA_SRC)/ddff.vhd $(ILA_SRC)/dpram.vhd
VHDL_SRC += $(ILA_SRC)/edge_detect.vhd
VHDL_SRC += $(ILA_SRC)/tap_ctrl.vhd $(ILA_SRC)/tap.vhd
VHDL_SRC += $(ILA_SRC)/la_control.vhd $(ILA_SRC)/la_trigger.vhd $(ILA_SRC)/la.vhd

CCF := $(IMPLDIR)/usb3.ccf

include $(COMMONDIR)/rules.mk
include $(COMMONDIR)/export.mk

$(CCF): $(COMMONDIR)/gmm7550.ccf $(COMMONDIR)/usb3-gmm7550.ccf | $(IMPLDIR)
	$(CAT) $^ > $@
	@echo "" >> $@
	@echo "Pin_out \"dbg_csn\"  Loc = \"IO_NA_B2\";" >> $@
	@echo "Pin_out \"dbg_clk\"  Loc = \"IO_NA_A0\";" >> $@
	@echo "Pin_out \"dbg_q[0]\" Loc = \"IO_NA_A3\";" >> $@
	@echo "Pin_out \"dbg_q[1]\" Loc = \"IO_NA_A2\";" >> $@
	@echo "Pin_out \"dbg_q[2]\" Loc = \"IO_NA_B3\";" >> $@
	@echo "Pin_out \"dbg_q[3]\" Loc = \"IO_NA_B0\";" >> $@
