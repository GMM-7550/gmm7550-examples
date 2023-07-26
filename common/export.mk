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
SED_CMD += -e 's/@DATE@/$(TIMESTAMP)/'
SED_CMD += -e 's/@GIT_COMMIT@/$(GITCOMMIT)/'

export: $(TARBALL) | $(EXPORTDIR)

$(TARBALL): $(EXPORTDIR)/$(EXP_NAME) | $(EXPORTDIR)
	(cd $(EXPORTDIR) && $(TAR) --xz --create --file $@ $(EXP_NAME))
	(cd $(EXPORTDIR) && $(RM) -r $(EXP_NAME))
	@echo "##### Standalone example code is exported to"
	@echo "##### " $(EXPORTDIR)/$(TARBALL)

$(EXPORTDIR)/$(EXP_NAME):
	$(MKDIR) $@
	$(CP) --recursive --dereference  src $@/
	$(MAKE) -C ../$(CC_LIB_NAME) distclean
	$(CP) --recursive --dereference ../$(CC_LIB_NAME) $@/
	-$(CP) --recursive --dereference sim $@/
	-$(CP) --recursive --dereference tb  $@/
	$(MKDIR) $@/common
	for f in $(COMMONDIR)/{defs.mk,ghdl.mk,flow.mk,rules.mk,*ccf}; do \
	  $(CP) $$f $@/common/; \
	done
	$(CP) $(TOPDIR)/LICENSE.txt $@/
	$(SED_CMD) $(COMMONDIR)/standalone_readme.in > $@/README.md
	$(SED_CMD) $(COMMONDIR)/standalone_makefile.in > $@/Makefile
