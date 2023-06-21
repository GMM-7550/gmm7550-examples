# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/ak-fau/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>

ECHO  := @echo
#ECHO  := true

CAT   := cat
CUT   := cut
CP    := cp --archive --update --force --backup=off
RM    := rm -f
MKDIR := mkdir -p
GREP  := grep
DATE  := date
GIT   := git
TAR   := tar
SED   := sed

VHDL_STANDARD := 08

TIMESTAMP := $(shell $(DATE) --utc --iso-8601=date)

GITCOMMIT := $(shell $(GIT) rev-parse --short HEAD)
ifneq (,$(shell $(GIT) status --porcelain))
GITCOMMIT := $(GITCOMMIT)-dirty
endif

LUA       := /usr/bin/lua5.1
LUA_INIT  :=
LUA_PATH  := $(COMMONDIR)/?.lua
LUA_CPATH :=

SYNTHDIR := synthesis
IMPLDIR  := pnr
LOGDIR   := log
WORKDIRS := $(SYNTHDIR) $(IMPLDIR) $(LOGDIR)

# Output directory for FPGA configuration files
CFGDIR := $(TOPDIR)/configs

# Output directory for exported (standalone) examples
EXPORTDIR := $(TOPDIR)/exports

OUTPUT_DIRS := $(CFGDIR) $(EXPORTDIR)

CC_LIB_NAME := cc
CC_LIB_DIR  := $(TOPDIR)/$(CC_LIB_NAME)
CC_LIB := $(CC_LIB_DIR)/$(SYNTHDIR)/$(CC_LIB_NAME)-obj$(VHDL_STANDARD).cf

LIBS := $(CC_LIB)
