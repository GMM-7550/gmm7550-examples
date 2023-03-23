#
# VHDL examples for GMM-7550 module
#
# Copyright (c) 2023 Anton Kuzmin
#

EXAMPLES := blink_25 blink_25_pll blink_100_pll

NOLIB_TARGETS := clean distclean export
TARGETS := synth impl pgm configs

VHDL_STANDARD := 08
CC_LIB_NAME   := cc
export VHDL_STANDARD
export CC_LIB_NAME

.PHONY: all $(TARGETS) $(NOLIB_TARGETS) $(EXAMPLES)
.PHONY: libs

SUBDIRS := $(filter     $(EXAMPLES),$(MAKECMDGOALS))
GOALS   := $(filter-out $(EXAMPLES),$(MAKECMDGOALS))

# if only some of examples should be build (listed on the make command line)
ifneq (,$(SUBDIRS))
EXAMPLES := $(SUBDIRS)
endif

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

include $(COMMONDIR)/tools-n-paths.mk

# Output directory for FPGA configuration files
CFGDIR := $(TOPDIR)/configs

# Output directory for exported (standalone) examples
EXPORTDIR := $(TOPDIR)/exports

export TOPDIR
export COMMONDIR
export CFGDIR
export EXPORTDIR

export: $(EXAMPLES)
$(TARGETS): $(EXAMPLES)

$(EXAMPLES):
	$(MAKE) -C $@ $(GOALS)

clean: $(EXAMPLES)
	$(MAKE) -C $(CC_LIB_DIR) $@

distclean: $(EXAMPLES)
	$(MAKE) -C $(CC_LIB_DIR) $@
	$(RM) -r $(CFGDIR)
	$(RM) -r $(EXPORTDIR)

libs: $(CC_LIB)

$(CC_LIB):
	$(MAKE) -C $(CC_LIB_DIR)
