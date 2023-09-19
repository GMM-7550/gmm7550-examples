# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/ak-fau/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>

EXAMPLES := blink_100_pll
# EXAMPLES += blink_25 blink_25_pll
EXAMPLES += spi_bridge serial_loopback
EXAMPLES += led8

NOLIB_TARGETS := clean distclean export manifest
TARGETS := synth impl pgm configs

VHDL_STANDARD := 08
export VHDL_STANDARD

.PHONY: all $(TARGETS) $(NOLIB_TARGETS) $(EXAMPLES)
.PHONY: help
.PHONY: libs

SUBDIRS := $(filter     $(EXAMPLES),$(MAKECMDGOALS))
GOALS   := $(filter-out $(EXAMPLES),$(MAKECMDGOALS))

# if only some of examples should be build (listed on the make command line)
ifneq (,$(SUBDIRS))
EXAMPLES := $(SUBDIRS)
endif

help:
	$(ECHO) "Example projects for GMM-7550 module"
	$(ECHO)
	$(ECHO) "Usage: make [TARGETs] [EXAMPLEs]"
	$(ECHO)
	$(ECHO) "Available targets:"
	$(ECHO) "  help, all, clean, distclean,"
	$(ECHO) "  synth, impl, pgm,"
	$(ECHO) "  configs, export, manifest"
	$(ECHO)
	$(ECHO) "Available examples:"
	$(ECHO) "  " $(EXAMPLES)

all: $(EXAMPLES)

# if no build target is specified on the command line (only subdirs) default
# example build target (all) depends on the libraries
ifeq (,$(GOALS))
$(EXAMPLES): libs
endif

# if target is not a clean-up one, libraries are required to build examples
ifneq (,$(filter-out $(NOLIB_TARGETS),$(GOALS)))
$(EXAMPLES): libs
endif

TOPDIR := $(shell pwd)
COMMONDIR := $(TOPDIR)/common

include $(COMMONDIR)/defs.mk

export CC_LIB_NAME
export TOPDIR
export COMMONDIR
export CFGDIR
export EXPORTDIR

export: $(EXAMPLES)

$(TARGETS) manifest: $(EXAMPLES)
	@true

$(EXAMPLES):
	$(MAKE) -C $@ $(GOALS)

clean: $(EXAMPLES)
	$(MAKE) -C $(CC_LIB_DIR) $@

distclean: $(EXAMPLES)
	$(MAKE) -C $(CC_LIB_DIR) $@
	$(RM) -r $(OUTPUT_DIRS)

libs: $(CC_LIB)

$(CC_LIB):
	$(MAKE) -C $(CC_LIB_DIR)
