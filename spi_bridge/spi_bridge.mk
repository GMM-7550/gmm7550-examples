PINOUT := $(COMMONDIR)/mem-io.lua

$(SYNTHDIR)/dirs.mk: Makefile | $(SYNTHDIR)
	$(RM) $@
	@for D in $(DIRS); do \
	  echo "#######################################################################################" >> $@; \
	  echo "# " $${D} >> $@; \
	  echo "#######################################################################################" >> $@; \
	  echo $${D}: $(IMPLDIR)_$${D}/$(TOP).cfg >> $@; \
	  echo "" >> $@; \
	  echo $(IMPLDIR)_$${D}/$(TOP).cfg: $(NETLIST) $(IMPLDIR)_$${D}/$(TOP).ccf "| " $(IMPLDIR)_$${D} >> $@; \
	  echo "" >> $@; \
	  echo -ne "\t$$" >> $@; \
	  echo -ne "(call run_place_and_route," $(IMPLDIR)_$${D} "," >> $@; \
	  echo $(IMPLDIR)_$${D}/$(TOP).ccf "," $(LOGDIR)/$(TOP)_$${D}_pnr.log ")" >> $@; \
	  echo "" >> $@; \
	  echo $(IMPLDIR)_$${D}/$(TOP).ccf: $(PINOUT_FILES) "| " $(IMPLDIR)_$${D} >> $@; \
	  echo "" >> $@; \
	  echo -e "\t" $(CAT) $(COMMONDIR)/gmm7550.ccf $(COMMONDIR)/hat-gmm7550.ccf " > " $(IMPLDIR)_$${D}/$(TOP).ccf >> $@; \
	  echo "" >> $@; \
	  echo -ne "\t" LUA_PATH=$(LUA_PATH) $(LUA) $(PINOUT) $${D} " >> " >> $@; \
	  echo          $(IMPLDIR)_$${D}/$(TOP).ccf >> $@; \
	  echo "" >> $@; \
	done

CFGFILES := $(foreach D, $(DIRS), $(TOP)_$(D)_$(GITCOMMIT)_$(TIMESTAMP).cfg)
BITFILES := $(foreach D, $(DIRS), $(TOP)_$(D)_$(GITCOMMIT)_$(TIMESTAMP).bit)

CFGFILES := $(addprefix $(CFGDIR)/, $(CFGFILES) $(BITFILES))
MANIFEST := tools_manifest_$(TIMESTAMP).md

configs: $(CFGFILES) $(CFGDIR)/$(MANIFEST)

$(CFGDIR)/$(TOP)_%_$(GITCOMMIT)_$(TIMESTAMP).cfg: pnr_%/$(TOP).cfg | $(CFGDIR)
	$(CP) $< $@

$(CFGDIR)/$(TOP)_%_$(GITCOMMIT)_$(TIMESTAMP).bit: pnr_%/$(TOP).bit | $(CFGDIR)
	$(CP) $< $@

$(CFGDIR)/$(MANIFEST): | $(CFGDIR)
	$(call create_manifest, $(CFGDIR)/$(MANIFEST))

manifest: | $(LOGDIR)
	$(call create_manifest, $(LOGDIR)/$(MANIFEST))

$(IMPLDIR)_%:
	$(MKDIR) $@

$(SYNTHDIR) $(LOGDIR) $(CFGDIR) $(EXPORTDIR):
	$(MKDIR) $@

.PHONY: libs

libs: $(CC_LIB)

$(CC_LIB):
	$(MAKE) -C $(CC_LIB_DIR)

.PHONY: clean clean_libs distclean

clean:
	$(RM) -r $(SYNTHDIR) $(LOGDIR)
	$(RM) -r $(addprefix $(IMPLDIR)_, $(DIRS))

clean_libs:
	$(MAKE) -C $(CC_LIB_DIR) clean

distclean: clean clean_libs
	$(RM) $(CFGDIR)/$(TOP)_*
