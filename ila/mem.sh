#!/usr/bin/env -S sh -c "jtag \$0"
cable dirtyJtag
frequency 5000000
reset
detect

register ID   32

register CMD  8
register STAT 8
register ADDR 11
register DATA 20

instruction length 4

instruction id   0001 ID
instruction cmd  0100 CMD
instruction stat 0101 STAT
instruction data 0110 DATA
instruction addr 0111 ADDR

# instruction ID
# shift ir
# dr 0xaaaa5555
# shift dr
# dr

#############################################################
# instruction cmd
# shift ir
# dr 0x20
# shift dr
# dr

# instruction addr
# shift ir
# dr 11011111110
# shift dr
# dr

# instruction data
# shift ir
# dr 0x43210
# shift dr
# dr

# shift dr
# dr
# shift dr
# dr
# shift dr
# dr
# shift dr
# dr
# shift dr
# dr

# instruction addr
# shift ir
# dr 00000000000
# shift dr
# dr
# shift dr
# dr
# shift dr
# dr

# instruction cmd
# shift ir
# dr 0x00
# shift dr
# dr

# instruction data
# shift ir
# dr 0xaaaaa
# shift dr
# dr
#############################################################

instruction cmd
shift ir
dr 0x80
shift dr

instruction cmd
shift ir
dr 0x30
shift dr

instruction addr
shift ir
dr 11100000000
shift dr

instruction data
shift ir
dr 0x00000
shift dr

dr 0x11111
shift dr
dr 0x22222
shift dr
dr 0x44444
shift dr
dr 0x88888
shift dr

dr 0x33333
shift dr
dr 0x66666
shift dr
dr 0xccccc
shift dr
dr 0x99999
shift dr

dr 0x77777
shift dr
dr 0xeeeee
shift dr
dr 0xddddd
shift dr
dr 0xbbbbb
shift dr

dr 0x01234
shift dr
dr 0x56789
shift dr
dr 0xabcde
shift dr
dr 0xf0123
shift dr

instruction cmd
shift ir
dr 0x10
shift dr

instruction addr
shift ir
dr 11100000000
shift dr
dr

instruction data
shift ir

dr 0xfffff
shift dr
dr

shift dr
dr
shift dr
dr
shift dr
dr
shift dr
dr

shift dr
dr
shift dr
dr
shift dr
dr
shift dr
dr

shift dr
dr
shift dr
dr
shift dr
dr
shift dr
dr

shift dr
dr
shift dr
dr
shift dr
dr
shift dr
dr

instruction addr
shift ir
dr 00000000000
shift dr

instruction addr
shift ir
dr 11100001010
shift dr
dr

instruction data
shift ir
dr 0x00000
shift dr
dr

instruction cmd
shift ir
dr 0x00
shift dr
