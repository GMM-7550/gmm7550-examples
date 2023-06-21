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

.PHONY: all synth impl libs manifest
.PHONY: $(DIRS)

all: impl

synth: $(NETLIST)

$(NETLIST): $(VHDL_SRC) $(CC_LIB) | $(SYNTHDIR) $(LOGDIR)
	$(call run_synthesis)

PINOUT := $(COMMONDIR)/mem-io.lua

impl: synth $(DIRS)

$(SYNTHDIR)/dirs.mk: Makefile | $(SYNTHDIR)
	$(RM) $@
	@for D in $(DIRS); do \
	  echo "#######################################################################################" >> $@; \
	  echo "# " $${D} >> $@; \
	  echo "#######################################################################################" >> $@; \
	  echo $${D}: $(IMPLDIR)_$${D}/$(TOP)_00.cfg >> $@; \
	  echo "" >> $@; \
	  echo $(IMPLDIR)_$${D}/$(TOP)_00.cfg: $(NETLIST) $(IMPLDIR)_$${D}/$(TOP)_$${D}.ccf "| " $(IMPLDIR)_$${D} >> $@; \
	  echo "" >> $@; \
	  echo -e "\t$(call run_place_and_route, " $(IMPLDIR)_$${D} ", " \
	          ../$(IMPLDIR)_$${D}/$(TOP)_$${D}.ccf ", " $(LOGDIR)/$(TOP)_$${D}_pnr.log ")" >> $@; \
	  echo "" >> $@; \
	  echo $(IMPLDIR)_$${D}/$(TOP)_$${D}.ccf: $(PINOUT) "| " $(IMPLDIR)_$${D} >> $@; \
	  echo "" >> $@; \
	  echo -e "\t" $(CAT) $(COMMONDIR)/gmm7550.ccf $(COMMONDIR)/hat-gmm7550.ccf " > " $(IMPLDIR)_$${D}/$(TOP)_$${D}.ccf >> $@; \
	  echo "" >> $@; \
	  echo -e "\t" $(LUA) $(PINOUT) $${D} " >> " $(IMPLDIR)_$${D}/$(TOP)_$${D}.ccf >> $@; \
	  echo "" >> $@; \
	done

include $(SYNTHDIR)/dirs.mk

CFGFILES := $(foreach D, $(DIRS), $(TOP)_$(D)_$(GITCOMMIT)_$(TIMESTAMP).cfg)
BITFILES := $(foreach D, $(DIRS), $(TOP)_$(D)_$(GITCOMMIT)_$(TIMESTAMP).bit)

CFGFILES := $(addprefix $(CFGDIR)/, $(CFGFILES) $(BITFILES))
MANIFEST := tools_manifest_$(TIMESTAMP).md

configs: $(CFGFILES) $(CFGDIR)/$(MANIFEST)

$(CFGDIR)/$(TOP)_%_$(GITCOMMIT)_$(TIMESTAMP).cfg: pnr_%/$(TOP)_00.cfg | $(CFGDIR)
	$(CP) $< $@

$(CFGDIR)/$(TOP)_%_$(GITCOMMIT)_$(TIMESTAMP).bit: pnr_%/$(TOP)_00.cfg.bit | $(CFGDIR)
	$(CP) $< $@

$(CFGDIR)/$(MANIFEST): | $(CFGDIR)
	$(call create_manifest, $(CFGDIR)/$(MANIFEST))

manifest: | $(LOGDIR)
	$(call create_manifest, $(LOGDIR)/$(MANIFEST))

$(IMPLDIR)_%:
	$(MKDIR) $@

$(SYNTHDIR) $(LOGDIR) $(CFGDIR) $(EXPORTDIR):
	$(MKDIR) $@

libs: $(CC_LIB)

$(CC_LIB):
	$(MAKE) -C $(CC_LIB_DIR)

clean:
	$(RM) -r $(SYNTHDIR) $(LOGDIR)
	$(RM) -r $(addprefix $(IMPLDIR)_, $(DIRS))

clean_libs:
	$(MAKE) -C $(CC_LIB_DIR) clean

distclean: clean clean_libs
	$(RM) $(CFGDIR)/$(TOP)_*
