#
# VHDL examples for GMM-7550 module
#
# Copyright (c) 2023 Anton Kuzmin
#

EXAMPLES := blink_25 blink_25_pll blink_100_pll

NOLIB_TARGETS := clean distclean
TARGETS := synth impl pgm configs

VHDL_STANDARD := 08
CC_LIB_NAME   := cc
export VHDL_STANDARD
export CC_LIB_NAME

.PHONY: all $(TARGETS) $(NOLIB_TARGETS) $(EXAMPLES)
.PHONY: libs $(CC_LIB_NAME)

SUBDIRS := $(filter     $(EXAMPLES),$(MAKECMDGOALS))
GOALS   := $(filter-out $(EXAMPLES),$(MAKECMDGOALS))

# if only some of examples should be build (listed on the make command line)
ifneq (,$(SUBDIRS))
EXAMPLES := $(SUBDIRS)
endif

all: libs $(EXAMPLES)

# if target is not a clean-up one, libraries are required to build examples
ifneq (,$(filter-out $(NOLIB_TARGETS),$(GOALS)))
$(EXAMPLES): libs
endif

TOPDIR := $(shell pwd)
COMMONDIR := $(TOPDIR)/common

include $(COMMONDIR)/tools-n-paths.mk

# Output directory for FPGA configuration files
CFGDIR := $(TOPDIR)/configs

export TOPDIR
export COMMONDIR
export CFGDIR

$(TARGETS): $(EXAMPLES)

$(EXAMPLES):
	$(MAKE) -C $@ $(GOALS)

clean: $(EXAMPLES)
	$(MAKE) -C $(CC_LIB_NAME) $@

distclean: $(EXAMPLES)
	$(MAKE) -C $(CC_LIB_NAME) $@
	$(RM) -r $(CFGDIR)

CC_LIB := $(CC_LIB_NAME)/$(CC_LIB_NAME)-obj$(VHDL_STANDARD).cf

libs: $(CC_LIB)

$(CC_LIB):
	$(MAKE) -C $(CC_LIB_NAME)
