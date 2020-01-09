#!/usr/bin/env bash
# Purpose: load scripts and variables that are common between tests.
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/assert.sh

# Making a temporary directory is tricky depending on the platform.
# Solution pulled from here:
#  https://unix.stackexchange.com/questions/30091/fix-or-alternative-for-mktemp-in-os-x
create_temp_directory=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
demo_src=$DIR/../demo

# Create a root directory and copy the demo code to there.
root=$create_temp_directory
src=$root/source
build=$root/build
mkdir -p $build
cp -Lr $demo_src $src  # note -L flag to grab symlink content.

# Make sure we don't carry along a preconfigured git.h header.
if [ -f src/git.h ]; then
    rm $src/git.h
fi

# Set the default generator if it hasn't been set already.
if [ ! -n "$TEST_GENERATOR" ]; then
  TEST_GENERATOR="Unix Makefiles"
fi

function cleanup () {
  # Remove the git directory with a force, then remove the root.
  if [ -d "$src/.git" ]; then
    echo "TEST: removing git directory..."
    rm -rf "$src/.git"
  fi
  if [ -d "$root" ]; then
    echo "TEST: removing test root directory..."
    rm -r "$root"
  fi
}
trap cleanup EXIT

echo "========================="
echo "Running test in \"$root\""
echo "-------------------------"
cd $root