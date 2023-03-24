all: $(TOP)

include $(COMMONDIR)/defs.mk
include $(COMMONDIR)/flow.mk

.PHONY: all clean distclean configs $(TOP)

$(TOP): impl

$(WORKDIRS) $(CFGDIR):
	$(MKDIR) $@

configs: $(TOP) | $(CFGDIR)
	$(CP) $(IMPLDIR)/*.cfg     $(CFGDIR)
	$(CP) $(IMPLDIR)/*.cfg.bit $(CFGDIR)

clean:
	$(RM) -r $(WORKDIRS)

distclean: clean
