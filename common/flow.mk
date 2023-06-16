# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/ak-fau/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>

PRFLAGS ?= +uCIO

CCF ?= ../src/$(TOP).ccf
PRFLAGS += -ccf ../$(CCF)

ifeq ($(D),1)
PRFLAGS += +d
endif

include $(COMMONDIR)/ghdl.mk
GHDL_FLAGS += -P$(CC_LIB_DIR)/$(SYNTHDIR) --vendor-library=$(CC_LIB_NAME)

YOSYS := yosys -m ghdl
OFL   := openFPGALoader
CC_TOOLCHAIN ?= $(TOPDIR)/../cc-toolchain
ifeq ($(shell uname -s),Linux)
WINE :=
PR   := $(CC_TOOLCHAIN)-linux/bin/p_r/p_r
else
WINE := WINEDEBUG=-all wine
PR   := $(CC_TOOLCHAIN)-win/bin/p_r/p_r.exe
endif

NETLIST ?= $(SYNTHDIR)/$(TOP)_synth.v

CFG_00  ?= $(IMPLDIR)/$(TOP)_00.cfg
CFGFILE ?= $(IMPLDIR)/$(TOP)_$(GITCOMMIT)_$(TIMESTAMP).cfg
BITFILE ?= $(IMPLDIR)/$(TOP)_$(GITCOMMIT)_$(TIMESTAMP).bit

LOGFILE_SYN ?= $(LOGDIR)/$(TOP)_synth.log
LOGFILE_PNR ?= $(LOGDIR)/$(TOP)_pnr.log

define run_synthesis
  $(YOSYS) -ql $(LOGFILE_SYN) \
  -p 'ghdl $(GHDL_FLAGS) $(VHDL_SRC) -e $(TOP)' \
  -p 'synth_gatemate -top $(TOP) -nomx8' \
  -p 'write_verilog -noattr $(NETLIST)'
endef

define run_place_and_route
  (cd $(IMPLDIR) && $(WINE) $(PR) -i ../$(NETLIST) -o $(TOP) $(PRFLAGS)) > $(LOGFILE_PNR)
  $(CP) $(CFG_00)     $(CFGFILE)
  $(CP) $(CFG_00).bit $(BITFILE)
endef

define run_configure
  $(OFL) $(OFLFLAGS) -c gatemate_pgm $(CFGFILE)
endef
