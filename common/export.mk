# Build an exported example directory and archive name
# from the example name, current date and git revision

EXAMPLE_NAME := $(notdir $(shell $(PWD)))
EXPORT_DATE  := $(shell $(DATE) -I)
GIT_COMMIT   := $(shell $(GIT) rev-parse --short HEAD)
ifneq (,$(shell git status --porcelain))
GIT_COMMIT   := $(GIT_COMMIT)-dirty
endif

EXP_NAME := $(EXAMPLE_NAME)_$(EXPORT_DATE)_$(GIT_COMMIT)
TARBALL  := $(EXP_NAME).tar.xz

SED_CMD := $(SED) -e 's/@NAME@/$(EXAMPLE_NAME)/'
SED_CMD += -e 's/@DATE@/$(EXPORT_DATE)/'
SED_CMD += -e 's/@GIT_COMMIT@/$(GIT_COMMIT)/'

export: $(TARBALL) | $(EXPORTDIR)

$(EXPORTDIR):
	$(MKDIR) $@

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
