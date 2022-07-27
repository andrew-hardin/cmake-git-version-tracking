#!/usr/bin/env bash
#
# Purpose:
# Test how the demo performs when uncommitted changes are made.

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

# Create git history
set -e
cd $src
git init
touch README.md
git add .
git commit -am "Initial commit."

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

# Check that the head isn't dirty.
set -e
if grep -q "uncommitted" output.txt; then
    echo "Demo reported a dirty head."
    assert "1 -eq 0" $LINENO
fi

# Modify a file then rebuild.
cd $src
echo "this is a cool edit" >> README.md
cd $build
cmake --build . --target demo

# Run the demo.
set +e
./demo &> output.txt
assert "$? -eq 0" $LINENO

# Check that demo reported that there were uncommitted changes.
set -e
if ! grep -q "uncommitted" output.txt; then
    echo "Demo didn't report a dirty head."
    assert "1 -eq 0" $LINENO
fi
