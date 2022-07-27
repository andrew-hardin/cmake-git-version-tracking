#!/usr/bin/env bash
#
# Purpose:
# Test if the demo detects DIRTY in the presence of
# untracked files. (PR #29)

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

# Create git history.
# Note that there's an untracked file.
set -e
cd $src
git init
git add .
git commit -am "Initial commit."
echo "This is an untracked file!" >> untracked.txt

# Build the project
set -e
cd $build
cmake -G "$TEST_GENERATOR" $src $version_tracking_module
cmake --build . --target demo

# Run the demo.
# It should report EXIT_SUCCESS because git history was found.
set +e
./demo &> output.txt
assert "$? -eq 0" $LINENO

# Check that the head is dirty (we have an untracked file).
set -e
if ! grep -q "uncommitted" output.txt; then
    echo "Demo didn't reported a dirty head."
    assert "1 -eq 0" $LINENO
fi

# Regenerate the build system but this time ignore
# untracked changes.
cmake -G "$TEST_GENERATOR" $src -DGIT_IGNORE_UNTRACKED=TRUE
cmake --build . --target demo

# Run the demo.
set +e
./demo &> output.txt
assert "$? -eq 0" $LINENO

# Check that demo didn't report uncommitted changes- we're ignoring
# the one untracked file.
set -e
if grep -q "uncommitted" output.txt; then
    echo "Demo reported a dirty head, but we should have ignored untracked changes."
    assert "1 -eq 0" $LINENO
fi
