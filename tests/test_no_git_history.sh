#!/usr/bin/env bash
#
# Purpose:
# Test how the demo performs when no .git directory was found.

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

# Configure and build the project.
set -e
cd build
cmake -g "$TEST_GENERATOR" $src
cmake --build . --target demo

# Run the demo.
# It should report EXIT_FAILURE because no git history was found.
set +e
./demo &> out_err.txt
assert "$? -eq 1" $LINENO