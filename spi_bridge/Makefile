# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/ak-fau/gmm7550-examples.git>
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
include $(COMMONDIR)/flow.mk

# By default, top entity name is the same as an example directory
TOP := $(notdir $(PWD))

VHDL_SRC := $(wildcard src/*.vhd)

DIRS := east west north

.PHONY: all synth impl manifest
.PHONY: $(DIRS)

all: impl

synth: $(NETLIST)

$(NETLIST): $(VHDL_SRC) $(CC_LIB) | $(SYNTHDIR) $(LOGDIR)
	$(call run_synthesis)

PINOUT := $(COMMONDIR)/{gmm7550-io.lua,mem-io.lua}

impl: synth $(DIRS)

LOCAL_MAKEFILE := spi_bridge.mk
include $(LOCAL_MAKEFILE)
include $(SYNTHDIR)/dirs.mk

COMMON_FILES := $(COMMONDIR)/{defs.mk,ghdl.mk,flow.mk,*ccf} ${PINOUT} $(LOCAL_MAKEFILE)
MAKEFILE_IN  := ./standalone_makefile.in

include $(COMMONDIR)/export.mk
