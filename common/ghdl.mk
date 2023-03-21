GHDL          := ghdl
VHDL_STANDARD ?= 08
GHDL_FLAGS    := --std=$(VHDL_STANDARD) -Wall --workdir=$(SYNTHDIR) -P$(SYNTHDIR)
