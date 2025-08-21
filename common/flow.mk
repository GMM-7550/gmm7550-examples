# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/gmm-7550/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <ak@gmm7550.dev>

DEVICE ?= CCGM1A1

PRFLAGS ?= --router router2

ifeq ($(D),1)
PRFLAGS += +d
endif

include $(COMMONDIR)/ghdl.mk
GHDL_FLAGS += -P$(CC_LIB_DIR)/$(SYNTHDIR) --vendor-library=$(CC_LIB_NAME)

YOSYS := yosys -m ghdl
OFL   := openFPGALoader

PR   := nextpnr-himbaechel
PACK := gmpack

NETLIST ?= $(SYNTHDIR)/$(TOP)_synth.v
JNETLST ?= $(NETLIST:.v=.json)

CFG ?= $(IMPLDIR)/$(TOP).cfg
BIT ?= $(CFG:.cfg=.bit)

LOGFILE_SYN ?= $(LOGDIR)/$(TOP)_synth.log
LOGFILE_PNR ?= $(LOGDIR)/$(TOP)_pnr.log

define run_synthesis
  $(YOSYS) -ql $(LOGFILE_SYN) \
  -p 'ghdl $(GHDL_FLAGS) $(EXTRA_GHDL_FLAGS) $(VHDL_SRC) -e $(TOP)' \
  -p 'synth_gatemate -top $(TOP) -luttree -nomx8' \
  -p 'setparam -unset KEEPER */r:KEEPER' \
  -p 'setparam -unset V_IO */r:V_IO=UNDEFINED' \
  -p 'setparam -unset SLEW */r:SLEW=UNDEFINED' \
  -p 'setparam -unset PIN_NAME */r:PIN_NAME=UNPLACED' \
  -p 'write_json $(JNETLST)' \
  -p 'write_verilog -noattr $(NETLIST)'
endef

define run_place_and_route
  $(PR) --device $(DEVICE) \
        --json $(JNETLST) \
        -o ccf=$(strip $(2)) \
        -o out=$(strip $(1))/$(notdir $(CFG)) \
        $(PRFLAGS) > $(3) 2>&1
  (cd $(1) && $(PACK) $(notdir $(CFG)) $(notdir $(BIT))) >> $(3)
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

  @echo "# \`nextpnr\`"       >> $(1)
  @echo ""                    >> $(1)
  @echo "\`\`\`"              >> $(1)
  @echo "PR =" $(PR)          >> $(1)
  @echo "#   " $(realpath $(shell which $(firstword $(PR)))) >> $(1)
  @echo "~$$ $(PR) --version" >> $(1)
  @$(PR) --version            >> $(1) 2>&1
  @echo "\`\`\`"              >> $(1)
  @echo ""                    >> $(1)
endef
