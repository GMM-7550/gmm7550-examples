# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/gmm-7550/gmm7550-examples.git>
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

$(NETLIST): $(SRC_FILES) $(LIBS) | $(SYNTHDIR) $(LOGDIR)
	$(call run_synthesis)

CFG_00  ?= $(IMPLDIR)/$(TOP)_00.cfg

impl: $(CFG_00)

$(CFG_00) $(CFG_00).bit &: $(NETLIST) $(CCF) | $(IMPLDIR) $(LOGDIR)
	$(call run_place_and_route, $(IMPLDIR), ../$(CCF), $(LOGFILE_PNR))

pgm: $(CFG_00)
	$(call run_configure, $<)

libs: $(LIBS)

$(CC_LIB):
	$(MAKE) -C $(CC_LIB_DIR)

CFGFILE ?= $(TOP)_$(GITCOMMIT)_$(TIMESTAMP).cfg
BITFILE ?= $(TOP)_$(GITCOMMIT)_$(TIMESTAMP).bit

CFGFILES := $(addprefix $(CFGDIR)/, $(CFGFILE) $(BITFILE))
MANIFEST ?= tools_manifest_$(TIMESTAMP).md

$(WORKDIRS) $(CFGDIR) $(EXPORTDIR):
	$(MKDIR) $@

configs: $(addprefix $(CFGDIR)/, $(CFGFILE) $(BITFILE) $(MANIFEST))

$(CFGDIR)/$(CFGFILE): $(CFG_00) | $(CFGDIR)
	$(CP) $(CFG_00) $(CFGDIR)/$(CFGFILE)

$(CFGDIR)/$(BITFILE): $(CFG_00).bit | $(CFGDIR)
	$(CP) $(CFG_00).bit $(CFGDIR)/$(BITFILE)

$(CFGDIR)/$(MANIFEST): | $(CFGDIR)
	$(call create_manifest, $(CFGDIR)/$(MANIFEST))

manifest: | $(LOGDIR)
	$(call create_manifest, $(LOGDIR)/$(MANIFEST))

clean:
	$(RM) -r $(WORKDIRS)

clean_libs:
	$(MAKE) -C $(CC_LIB_DIR) clean

distclean: clean clean_libs
	$(RM) $(CFGDIR)/$(TOP)_*
