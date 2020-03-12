#!/bin/sh

NASM_OUT=/tmp/nasmfoo

export BLOCK_SIZING_HINTS=1

(for a in *.asm ; do nasm "$a" -o "$NASM_OUT" ; done) 2>&1 \
		| grep fillLength \
		| sed -e 's#.*/##;s#warning.*block##' \
		| column -t \
		| sort -n -k5

