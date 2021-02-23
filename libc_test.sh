#!/bin/sh

#
# Somewhat hackish solution to automatically
# force ld.lld on musl. This is because using
# GNU ld creates a ~15kb binary, while Clang
# ld.lld creates a ~6kb binary.
#
# There is most likely a better way to do this,
# but this works for the time being.
#

if [ -e "/lib/ld-musl-x86_64.so.1" ]; then
  if [ "$1" = "linker" ]; then
    echo "ld.lld"
  elif [ "$1" = "libs" ]; then
    echo "-dynamic-linker /lib/ld-musl-x86_64.so.1 -lc"
  fi
else
  if [ "$1" = "linker" ]; then
    echo "ld"
  elif [ "$1" = "libs" ]; then
    echo "-lc"
  fi
fi
