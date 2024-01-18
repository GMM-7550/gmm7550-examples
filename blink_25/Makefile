# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/gmm-7550/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>

PWD := $(shell pwd)

TOPDIR ?= $(PWD)/..
COMMONDIR ?= $(TOPDIR)/common
export TOPDIR
export COMMONDIR

include $(COMMONDIR)/defs.mk

# By default, top entity name is the same as an example directory
TOP := $(notdir $(PWD))

VHDL_SRC := $(wildcard src/*.vhd)

CCF := $(IMPLDIR)/blink.ccf

include $(COMMONDIR)/rules.mk
include $(COMMONDIR)/export.mk

$(CCF): | $(IMPLDIR)
	$(CAT) $(COMMONDIR)/gmm7550.ccf $(COMMONDIR)/hat-gmm7550.ccf > $@
