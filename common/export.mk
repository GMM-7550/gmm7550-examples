# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/gmm-7550/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <ak@gmm7550.dev>

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

COMMON_FILES ?= $(COMMONDIR)/{defs.mk,ghdl.mk,flow.mk,rules.mk,*ccf}
MAKEFILE_IN  ?= $(COMMONDIR)/standalone_makefile.in

$(EXPORTDIR)/$(EXP_NAME): T_COMMON=$@/common
$(EXPORTDIR)/$(EXP_NAME):
	$(MKDIR) $@
	$(CP) --recursive --dereference  src $@/
	$(MAKE) -C ../$(CC_LIB_NAME) distclean
	$(CP) --recursive --dereference ../$(CC_LIB_NAME) $@/
	-$(CP) --recursive --dereference sim $@/
	-$(CP) --recursive --dereference tb  $@/
	$(MKDIR) $(T_COMMON)
	for f in $(COMMON_FILES); do \
	  $(CP) $$f $(T_COMMON); \
	done
	$(CP) $(TOPDIR)/LICENSE.txt $@/
	$(SED_CMD) $(COMMONDIR)/standalone_readme.in > $@/README.md
	$(SED_CMD) $(MAKEFILE_IN) > $@/Makefile
