# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/ak-fau/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>

EXAMPLE_NAME := $(notdir $(PWD))

EXP_NAME := $(EXAMPLE_NAME)_$(GITCOMMIT)_$(TIMESTAMP)
TARBALL  := $(EXP_NAME).tar.xz

SED_CMD := $(SED) -e 's/@NAME@/$(EXAMPLE_NAME)/'
SED_CMD += -e 's/@DATE@/$(EXPORT_DATE)/'
SED_CMD += -e 's/@GIT_COMMIT@/$(GIT_COMMIT)/'

export: $(TARBALL) | $(EXPORTDIR)

$(TARBALL): $(EXPORTDIR)/$(EXP_NAME) | $(EXPORTDIR)
	(cd $(EXPORTDIR) && $(TAR) --xz --create --file $@ $(EXP_NAME))
	(cd $(EXPORTDIR) && $(RM) -r $(EXP_NAME))
	@echo "##### Standalone example code is exported to"
	@echo "##### " $(EXPORTDIR)/$(TARBALL)

$(EXPORTDIR)/$(EXP_NAME):
	$(MKDIR) $(EXPORTDIR)/$(EXP_NAME)
	$(CP) --recursive --dereference  src $(EXPORTDIR)/$(EXP_NAME)/
	$(MAKE) -C ../$(CC_LIB_NAME) distclean
	$(CP) --recursive --dereference ../$(CC_LIB_NAME) $(EXPORTDIR)/$(EXP_NAME)/
	-$(CP) --recursive --dereference sim $(EXPORTDIR)/$(EXP_NAME)/
	-$(CP) --recursive --dereference tb  $(EXPORTDIR)/$(EXP_NAME)/
	$(MKDIR) $(EXPORTDIR)/$(EXP_NAME)/mk
	for f in $(COMMONDIR)/{defs.mk,ghdl.mk,flow.mk,*ccf}; do \
	  $(CP) $$f $(EXPORTDIR)/$(EXP_NAME)/mk/; \
	done
	$(CP) $(TOPDIR)/LICENSE.txt $(EXPORTDIR)/$(EXP_NAME)/
	$(SED_CMD) $(COMMONDIR)/standalone_readme.in > $(EXPORTDIR)/$(EXP_NAME)/README.md
	$(SED_CMD) $(COMMONDIR)/standalone_makefile.in > $(EXPORTDIR)/$(EXP_NAME)/Makefile
