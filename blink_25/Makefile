# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/ak-fau/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>

include $(COMMONDIR)/defs.mk

# By default, top entity name is the same as an example directory
TOP := $(notdir $(shell $(PWD)))

VHDL_SRC := $(wildcard src/*.vhd)

CCF := $(IMPLDIR)/blink.ccf

include $(COMMONDIR)/rules.mk
include $(COMMONDIR)/export.mk

$(CCF): | $(IMPLDIR)
	$(CAT) $(COMMONDIR)/gmm7550.ccf $(COMMONDIR)/hat-gmm7550.ccf > $@
