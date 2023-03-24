VHDL_FILES := $(wildcard src/*.vhd)

include $(COMMONDIR)/defs.mk
include $(COMMONDIR)/ghdl.mk

.PHONY: all clean distclean $(CC_LIB_NAME)

all: $(CC_LIB_NAME)

CC_LIB := $(SYNTHDIR)/$(CC_LIB_NAME)-obj$(VHDL_STANDARD).cf

$(CC_LIB_NAME): $(CC_LIB)

$(CC_LIB): $(VHDL_FILES) | $(SYNTHDIR)
	for f in $(VHDL_FILES); do \
	  $(GHDL) -a $(GHDL_FLAGS) --work=$(CC_LIB_NAME) $$f; \
	done

$(SYNTHDIR):
	$(MKDIR) $@

clean:
	$(RM) -r $(SYNTHDIR)

distclean: clean
