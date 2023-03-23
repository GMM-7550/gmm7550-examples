include $(COMMONDIR)/tools-n-paths.mk

# By default, top entity name is the same as an example directory
TOP := $(notdir $(shell $(PWD)))

VHDL_SRC := $(wildcard src/*.vhd)

CCF := $(IMPLDIR)/blink.ccf

include $(COMMONDIR)/rules.mk
include $(COMMONDIR)/export.mk

$(CCF): | $(IMPLDIR)
	$(CAT) $(COMMONDIR)/gmm7550.ccf $(COMMONDIR)/hat-gmm7550.ccf > $@
