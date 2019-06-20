#!/usr/bin/env bash
#
# Purpose:
# Test how the demo performs when no git tag is present. This test was added
# because git describe will fallback to a hash without prefix if that happens
# due to its --always option.

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

VERSION_PREFIX='version-'
VERSION='7.3.17'

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

# Run the demo.
# It should report EXIT_SUCCESS because git history was found.
set +e
./demo &> output.txt
assert "$? -eq 0" $LINENO

# Check that the git commit matches what git reports.
set -e
truth=$(cd $src && git rev-parse --verify HEAD)
if ! grep -q $truth output.txt; then
    # Commit ID wasn't found.
    echo "Demo didn't print the correct commit."
    assert "1 -eq 0" $LINENO
fi