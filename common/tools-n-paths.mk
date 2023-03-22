ECHO  := @echo
#ECHO  := true

PWD   := pwd
CAT   := cat
CUT   := cut
CP    := cp --archive --update --force --backup=never
RM    := rm -f
MKDIR := mkdir -p
GREP  := grep

SYNTHDIR := synthesis
IMPLDIR  := pnr
LOGDIR   := log
WORKDIRS := $(SYNTHDIR) $(IMPLDIR) $(LOGDIR)
