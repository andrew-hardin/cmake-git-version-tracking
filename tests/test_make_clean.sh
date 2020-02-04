#!/usr/bin/env bash
#
# Issue #9:
# Verify that the header is regenerated after a make clean.
# https://github.com/andrew-hardin/cmake-git-version-tracking/issues/9


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

# The configured header should exist.
# The git-state file should exist.
assert "-f $src/git.h" $LINENO
assert "-f $build/git-state-hash" $LINENO

# Make clean should scrub both these files.
make clean
assert "! -f $src/git.h" $LINENO
assert "! -f $build/git-state-hash" $LINENO

# We should generate them again after calling make.
make
assert "-f $src/git.h" $LINENO
assert "-f $build/git-state-hash" $LINENO
