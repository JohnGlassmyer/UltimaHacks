#!/bin/bash

# exit on error
set -e

. patchingVariables.sh

if [ $# -eq 0 ] ; then
	echo "No sources specified. Consider running $0 *.asm"
	exit 1
fi

echo "deleting old binaries..."
rm *.o || true

echo

echo "assembling patches..."
for a in "$@" ; do
	echo "  $a"
	nasm "$a" -o "${a/.asm/.o}"
done

echo

echo "applying patches..."
objects=()
for o in *.o ; do
	objects+=("--patch=$o")
done
java -jar "$ULTIMA_PATCHER_JAR" \
	--exe="$TARGET_EXE" \
	"${objects[@]}" \
	--write-to-exe

echo

echo "deleting assembled binaries..."

rm *.o || true
