# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/gmm-7550/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <ak@gmm7550.dev>

PRFLAGS ?= +uCIO -cCP

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

LOGFILE_SYN ?= $(LOGDIR)/$(TOP)_synth.log
LOGFILE_PNR ?= $(LOGDIR)/$(TOP)_pnr.log

define run_synthesis
  $(YOSYS) -ql $(LOGFILE_SYN) \
  -p 'ghdl $(GHDL_FLAGS) $(EXTRA_GHDL_FLAGS) $(VHDL_SRC) -e $(TOP)' \
  -p 'synth_gatemate -top $(TOP) -nomx8' \
  -p 'write_verilog -noattr $(NETLIST)'
endef

define run_place_and_route
  (cd $(1) && $(WINE) $(PR) -i ../$(NETLIST) -o $(TOP) $(PRFLAGS) -ccf $(2)) > $(3)
endef

define run_configure
  $(OFL) $(OFLFLAGS) -c gatemate_pgm $(1)
endef

define create_manifest
  @$(RM) $(1)
  @echo "Creating tools manifest file: " $(1)
  @echo "# Yosys"              > $(1)
  @echo ""                    >> $(1)
  @echo "\`\`\`"              >> $(1)
  @echo "YOSYS =" $(YOSYS)    >> $(1)
  @echo "#      " $(realpath $(shell which $(firstword $(YOSYS)))) >> $(1)
  @echo "~$$ yosys -V"        >> $(1)
  @$(YOSYS) -V                >> $(1)
  @echo "\`\`\`"              >> $(1)
  @echo ""                    >> $(1)

  @echo "# GHDL" >> $(1)
  @echo ""                    >> $(1)
  @echo "\`\`\`"              >> $(1)
  @echo "GHDL =" $(GHDL)      >> $(1)
  @echo "#     " $(realpath $(shell which $(firstword $(GHDL)))) >> $(1)
  @echo "~$$ ghdl --version"  >> $(1)
  @$(GHDL) --version | head -3 >> $(1)
  @echo "\`\`\`"              >> $(1)
  @echo ""                    >> $(1)

  @echo "# GHDL Yosys Plugin" >> $(1)
  @echo ""                    >> $(1)
  @echo "\`\`\`"              >> $(1)
  @echo "~$$ pacman -Qi ghdl-yosys-plugin" >> $(1)
  @LC_ALL=C pacman -Qi ghdl-yosys-plugin >> $(1)
  @echo "\`\`\`"              >> $(1)
  @echo ""                    >> $(1)

  @echo "# Cologne Chip Place-n-Route" >> $(1)
  @echo ""                    >> $(1)
  @echo "\`\`\`"              >> $(1)
  @echo "PR =" $(PR)          >> $(1)
  @echo "#   " $(realpath $(shell which $(firstword $(PR)))) >> $(1)
  @echo "~$$ p_r --help"      >> $(1)
  @$(PR) --help | head -3     >> $(1)
  @echo "\`\`\`"              >> $(1)
  @echo ""                    >> $(1)
endef
