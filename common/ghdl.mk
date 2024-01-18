# This file is a part of the GMM-7550 VHDL Examples
# <https://github.com/gmm-7550/gmm7550-examples.git>
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2023 Anton Kuzmin <anton.kuzmin@cs.fau.de>

GHDL          := ghdl
VHDL_STANDARD ?= 08
GHDL_FLAGS    := --std=$(VHDL_STANDARD) --workdir=$(SYNTHDIR) -P$(SYNTHDIR)

# Diagnostics Control
# GHDL_FLAGS += -fcolor-diagnostics
# GHDL_FLAGS += -fdiagnostics-show-option
# GHDL_FLAGS += -fcaret-diagnostics

# Slightly relax some rules to be compatible with various other simulators or synthesizers
# The effects of this option are reset by --std, so it should be placed after that option.
# GHDL_FLAGS += -frelaxed-rules

# turns warnings into errors
GHDL_FLAGS += -Werror

# enables all warnings
GHDL_FLAGS += -Wall

# Allow UTF8 or multi-bytes chars in a comment
# GHDL_FLAGS += --mb-comments

# warns for component not bound
# GHDL_FLAGS += -Wbinding
# GHDL_FLAGS += -Wdefault-binding

# Emit a warning on unconnected input port without defaults (in relaxed mode)
# GHDL_FLAGS += -Wport

# Emit a warning for unknown pragma
# GHDL_FLAGS += -Wpragma

# Emit a warning if a /* appears within a block comment (vhdl 2008)
# GHDL_FLAGS += -Wnested-comment

# Emit a warning in case of weird use of parentheses
# GHDL_FLAGS += -Wparenthesis

# Emit a warning on incorrect use of universal values
# GHDL_FLAGS += -Wuniversal

# Emit a warning on bounds mismatch between the actual and formal in a scalar port association
# GHDL_FLAGS += -Wport-bounds

# Emit a warning in case of runtime error that is detected during analysis
# GHDL_FLAGS += -Wruntime-error

# Emit a warning if a signal assignemnt creates a delta cycle in a postponed process
# GHDL_FLAGS += -Wdelta-cycle

# Emit a warning if there is no wait statement in a non-sensitized process
# GHDL_FLAGS += -Wno-wait

# Emit a warning when a shared variable is declared and its type it not a protected type
# GHDL_FLAGS += -Wshared

# Emit a warning when a declaration hides a previous hide
# GHDL_FLAGS += -Whide

# Emit a warning if a variable or a signal is never assigned (only for synthesis)
# GHDL_FLAGS += -Wnowrite

# Emit a warning if an others choice is not required because all the choices have been explicitly covered
# GHDL_FLAGS += -Wothers

# Emit a warning when a pure rules is violated (like declaring a pure function with access parameters)
# GHDL_FLAGS += -Wpure

# Emit a warning for assertions that are statically evaluated during analysis
# GHDL_FLAGS += -Wanalyze-assert

# Emit a warning on incorrect use of attributes
# GHDL_FLAGS += -Wattribute

# Emit a warning on useless code (like conditions that are always false or true, assertions that cannot be triggered)
# GHDL_FLAGS += -Wuseless

# Emit a warning on missing association for a port association. Open associations are required
# GHDL_FLAGS += -Wno-assoc
GHDL_FLAGS += --warn-no-no-assoc

# Emit a warning when a non-static expression is used at a place where the standard requires a static expression
# GHDL_FLAGS += -Wstatic

# warns use of 93 reserved words in vhdl87
# GHDL_FLAGS += -Wreserved

# warns for redefinition of a design unit
# GHDL_FLAGS += -Wlibrary

# warns of non-vital generic names
# GHDL_FLAGS += -Wvital-generic

# warns for checks performed at elaboration
# GHDL_FLAGS += -Wdelayed-checks

# warns for not necessary package body
# GHDL_FLAGS += -Wbody

# warns if a all/others spec does not apply
# GHDL_FLAGS += -Wspecs

# warns if a subprogram is never used
# GHDL_FLAGS += -Wunused
