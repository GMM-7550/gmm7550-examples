.PHONY: synth impl pgm

PRFLAGS ?= +uCIO

CCF ?= ../src/$(TOP).ccf
PRFLAGS += -ccf ../$(CCF)

ifeq ($(D),1)
PRFLAGS += +d
endif

include $(COMMONDIR)/ghdl.mk
GHDL_FLAGS += -P../$(CC_LIB_NAME)/$(SYNTHDIR) --vendor-library=$(CC_LIB_NAME)

CC_LIB := ../$(CC_LIB_NAME)/$(SYNTHDIR)/$(CC_LIB_NAME)-obj$(VHDL_STANDARD).cf

YOSYS := yosys -m ghdl
OFL   := openFPGALoader

ifeq ($(shell uname -s),Linux)
WINE :=
PR   := $(TOPDIR)/../cc-toolchain-linux/bin/p_r/p_r
else
WINE := WINEDEBUG=-all wine
PR   := $(TOPDIR)/../cc-toolchain-win/bin/p_r/p_r.exe
endif

NETLIST=$(SYNTHDIR)/$(TOP)_synth.v
CFGFILE=$(IMPLDIR)/$(TOP)_00.cfg

synth: $(NETLIST)

$(NETLIST): $(VHDL_SRC) $(CC_LIB) | $(WORKDIRS)
	$(YOSYS) -ql $(LOGDIR)/$(TOP)_synth.log \
	-p 'ghdl $(GHDL_FLAGS) $(VHDL_SRC) -e $(TOP)' \
	-p 'synth_gatemate -top $(TOP) -nomx8' \
	-p 'write_verilog -noattr $(NETLIST)'

impl: $(CFGFILE)

$(CFGFILE): $(NETLIST) $(CCF) | $(WORKDIRS)
	(cd $(IMPLDIR) && $(WINE) $(PR) -i ../$(NETLIST) -o $(TOP) $(PRFLAGS)) > $(LOGDIR)/$(TOP)_pnr.log

pgm: $(CFGFILE)
	$(OFL) $(OFLFLAGS) -c gatemate_pgm $(CFGFILE)
