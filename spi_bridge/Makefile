# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/ak-fau/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>

ifdef COMMONDIR
  include $(COMMONDIR)/defs.mk
else
  TOPDIR := ..
  COMMONDIR := $(TOPDIR)/common
  include ../common/defs.mk
endif

# By default, top entity name is the same as an example directory
TOP := $(notdir $(shell $(PWD)))

VHDL_SRC := $(wildcard src/*.vhd)

DIRS := east west north

.PHONY: local_all local_clean local_impl

local_impl:
	for DIR in $(DIRS); do \
	    DIR=$${DIR} CCF=$(IMPLDIR)_$${DIR}/spi_bridge_$${DIR}.ccf \
	    IMPLDIR=$(IMPLDIR)_$${DIR} LOGFILE_PNR=$(LOGDIR)/$(TOP)_$${DIR}_pnr.log \
	    $(MAKE) -C .. $(TOP) impl; \
	done

clean: local_clean

local_clean:
	$(foreach D, $(DIRS), $(RM) -r $(IMPLDIR)_$(D);)

include $(COMMONDIR)/rules.mk
include $(COMMONDIR)/export.mk

$(IMPLDIR)/spi_bridge_%.ccf: src/mem-module-%.ccf | $(IMPLDIR)
	$(CAT) $(COMMONDIR)/gmm7550.ccf $(COMMONDIR)/hat-gmm7550.ccf $< > $@
