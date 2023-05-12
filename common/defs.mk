# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/ak-fau/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>

ECHO  := @echo
#ECHO  := true

PWD   := pwd
CAT   := cat
CUT   := cut
CP    := cp --archive --update --force --backup=never
RM    := rm -f
MKDIR := mkdir -p
GREP  := grep
DATE  := date
GIT   := git
TAR   := tar
SED   := sed

SYNTHDIR := synthesis
IMPLDIR  ?= pnr
LOGDIR   := log
WORKDIRS := $(SYNTHDIR) $(IMPLDIR) $(LOGDIR)

CC_LIB_DIR := $(TOPDIR)/$(CC_LIB_NAME)
CC_LIB := $(CC_LIB_DIR)/$(SYNTHDIR)/$(CC_LIB_NAME)-obj$(VHDL_STANDARD).cf
