# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/ak-fau/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>

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
