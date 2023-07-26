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
