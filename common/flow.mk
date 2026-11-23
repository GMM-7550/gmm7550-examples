# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/gmm-7550/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <ak@gmm7550.dev>

DEVICE ?= CCGM1A1

PRFLAGS ?= --router router2 --detailed-timing-report

ifeq ($(D),1)
PRFLAGS += +d
endif

include $(COMMONDIR)/ghdl.mk
GHDL_FLAGS += -P$(CC_LIB_DIR)/$(SYNTHDIR)
EXTRA_GHDL_FLAGS += -frelaxed --warn-no-shared

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
  @$(GHDL) import $(GHDL_FLAGS) -P$(SYNTHDIR) --warn-no-default-binding $(VHDL_SRC)
  @echo
  @echo "### Analyze VHDL files"
  @for f in `$(GHDL) elab-order $(GHDL_FLAGS) --warn-no-binding $(TOP)`; do \
    echo "  " `basename $$f`; \
    $(GHDL) analyze $(GHDL_FLAGS) --workdir=$(SYNTHDIR) -P$(SYNTHDIR)  --warn-no-default-binding $$f; \
  done
  @echo
  @echo "### Run Yosys synthesis for" $(TOP)
  @echo
  $(YOSYS) -ql $(LOGFILE_SYN) \
  -p 'ghdl $(GHDL_FLAGS) --workdir=$(SYNTHDIR) -P$(SYNTHDIR) $(EXTRA_GHDL_FLAGS) --vendor-library=$(CC_LIB_NAME) $(TOP)' \
  -p 'synth_gatemate -top $(TOP) -luttree -nomx8' \
  -p 'write_json $(JNETLST)' \
  -p 'write_verilog -noattr $(NETLIST)'
endef

define run_place_and_route
  @echo
  @echo "### Run Place and Route"
  @echo
  $(PR) --device $(DEVICE) \
        --json $(JNETLST) \
        -o ccf=$(strip $(2)) \
        -o out=$(strip $(1))/$(notdir $(CFG)) \
        $(PRFLAGS) > $(3) 2>&1
  @echo
  @echo "### Create configuration bitstream" $(BIT)
  @echo
  (cd $(1) && $(PACK) $(notdir $(CFG)) $(notdir $(BIT))) >> $(3)
endef

define run_configure
  $(OFL) $(OFLFLAGS) -c dirtyJtag --bitstream $(1)
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
