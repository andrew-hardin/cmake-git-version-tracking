#!/usr/bin/env bash
#
# Purpose:
# Test that we can regenerate the header if it goes missing.
# See issue #9.

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

# Create git history
set -e
cd $src
git init
git add .
git commit -am "Initial commit."

# Build the project
set -e
cd $build
cmake -G "$TEST_GENERATOR" $src
cmake --build . --target demo

# Nuke the header, then check that it gets generated automatically
# when we try to build the project again.
rm $src/git.h
cmake --build .
assert "-f $src/git.h" $LINENO
