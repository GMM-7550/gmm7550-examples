# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/ak-fau/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>

all: $(TOP)

include $(COMMONDIR)/flow.mk

.PHONY: all clean clean_libs distclean $(TOP)
.PHONY: configs export manifest
.PHONY: libs synth impl pgm

$(TOP): impl

synth: $(NETLIST)

SRC_FILES := $(VHDL_SRC) $(VERILOG_SRC)

$(NETLIST): $(SRC_FILES) libs | $(SYNTHDIR) $(LOGDIR)
	$(call run_synthesis)

impl: $(CFGFILE)

pgm: $(CFGFILE)
	$(call run_configure)

libs: $(CC_LIB)

$(CC_LIB):
	$(MAKE) -C $(CC_LIB_DIR)

$(CFGFILE): $(NETLIST) $(CCF) | $(IMPLDIR) $(LOGDIR)
	$(call run_place_and_route)

$(BITFILE): $(CFGFILE)
	@true

$(WORKDIRS) $(CFGDIR) $(EXPORTDIR):
	$(MKDIR) $@

CFGFILES ?= $(CFGFILE) $(BITFILE)

configs: $(CFGFILES) | $(CFGDIR)
	$(CP) $(CFGFILES) $(CFGDIR)
	$(call create_manifest, $(CFGDIR)/$(MANIFEST))

manifest: | $(IMPLDIR)
	$(call create_manifest, $(IMPLDIR)/$(MANIFEST))

clean:
	$(RM) -r $(WORKDIRS)

clean_libs:
	$(MAKE) -C $(CC_LIB_DIR) clean

distclean: clean clean_libs
