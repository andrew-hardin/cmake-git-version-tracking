#!/usr/bin/env bash
#
# Issue #9:
# Verify that the header is regenerated after a make clean.
# https://github.com/andrew-hardin/cmake-git-version-tracking/issues/9
#
# For additional context, see this issue:
# https://gitlab.kitware.com/cmake/cmake/issues/18300
#
# Depending on which version of CMake you're using, the makefile
# generator may or may-not remove byproducts of custom targets.

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

# Don't run the test if we're pre-3.13.
version=$(cmake --version | head -n 1)
version=${version##* }
major=${version%%.*}
patch=${version##*.}
minor=${version##$major.}
minor=${minor%%.$patch}
if [[ $major -lt 3 || ( $major -eq 3  &&  $minor -lt 13 ) ]]; then
    echo "CMake $version doesn't remove makefile byproducts- skipping test"
    exit 0
fi

# Create git history
set -e
cd $src
git init
git add .
git commit -am "Initial commit."

# Build the project
set -e
cd $build
cmake -G "$TEST_GENERATOR" $src $version_tracking_module
cmake --build . --target demo

# The configured source file should exist.
# The git-state file should exist.
configured_src=./_deps/cmake_git_version_tracking-build/git.c
git_state=./_deps/cmake_git_version_tracking-build/git-state-hash
assert "-f $configured_src" $LINENO
assert "-f $git_state" $LINENO

# Make followed by clean should scrub both these files.
cmake --build .
cmake --build . --target clean
assert "! -f $configured_src" $LINENO
assert "! -f $git_state" $LINENO

# We should generate them again after calling make.
cmake --build .
assert "-f $configured_src" $LINENO
assert "-f $git_state" $LINENO
