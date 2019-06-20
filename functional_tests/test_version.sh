#!/usr/bin/env bash
#
# Purpose:
# Test how the demo performs when parsing the version number from a git tag.

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
git tag "${VERSION_PREFIX}${VERSION}"
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

# Check that the version matches the git tag.
set -e
truth="${VERSION}"
if ! grep -q $truth output.txt; then
    # Version string wasn't found.
    echo "Demo didn't print the correct version."
    assert "1 -eq 0" $LINENO
fi
