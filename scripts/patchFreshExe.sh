#!/bin/bash

# exit on error
set -e

. ./patchingVariables.sh

DATE="$(date +%Y%m%d-%H%M%S)"
COMMENT="for $TARGET_DESC; assembled $DATE"

if [ $# -eq 0 ] ; then
	echo "No sources specified. Consider running $0 *.asm"
	exit 1
fi

echo "copying clean executable..."
cp "$ORIGINAL_EXE" "$TARGET_EXE"

echo

echo "deleting old binaries..."
rm *.o || true

echo

echo "assembling patches..."
for a in "$@" ; do
	echo "  $a"
	nasm "$a" -o "${a/.asm/.o}"
done

echo

echo "linking patches..."
objects=()
for o in *.o ; do
	objects+=("--patch=$o")
done
expandOverlays=()
for eo in $EXPAND_OVERLAYS ; do
	expandOverlays+=("--expand-overlay=$eo")
done
java -jar "$ULTIMA_PATCHER_JAR" \
	--exe="$TARGET_EXE" \
	"${expandOverlays[@]}" \
	--eop-spacing="$EOP_SPACING" \
	"${objects[@]}" \
	--write-hack-proto="$HACK_PROTO" \
	--hack-comment="$COMMENT"

echo

echo "deleting assembled binaries..."

rm *.o || true

echo

echo "applying hack..."
java -jar "$ULTIMA_PATCHER_JAR" \
	--exe="$TARGET_EXE" \
	--hack-proto="$HACK_PROTO" \
	--write-to-exe
