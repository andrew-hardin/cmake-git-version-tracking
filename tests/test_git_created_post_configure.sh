#!/usr/bin/env bash
#
# Purpose:
# Test how the demo performs when the .git directory is created
# after the project has been configure.

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

# Configure and build the project.
# Should fail because the git commands can't run.
set -e
cd build
cmake -G "$TEST_GENERATOR" $src $version_tracking_module
set +e
cmake --build . --target demo
assert "$? -ne 0" $LINENO
set -e

# Regenerate, but this time allow git commands to fail.
# The build should pass.
cmake -G "$TEST_GENERATOR" $src $version_tracking_module -DGIT_FAIL_IF_NONZERO_EXIT=FALSE
cmake --build . --target demo
assert "$? -eq 0" $LINENO

# Run the demo.
# It should report EXIT_FAILURE because no git history was found.
set +e
./demo
assert "$? -eq 1" $LINENO

# Create git history
set -e
cd $src
git init
git add .
git commit -am "Initial commit."

# Build again.
cd $build
cmake --build . --target demo

# Run the demo.
# It should report EXIT_SUCCESS because git history was found.
set +e
./demo
assert "$? -eq 0" $LINENO
