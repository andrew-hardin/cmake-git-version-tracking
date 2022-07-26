#!/usr/bin/env bash
#
# Purpose:
# Test how the demo performs when a new commit is made.

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

# Create git history
set -e
cd $src
git init
git add .
git commit -am "Initial commit."
git checkout -b true-branch-name

# Build the project
set -e
cd $build
cmake -G "$TEST_GENERATOR" $src $version_tracking_module -DGIT_FAIL_IF_NONZERO_EXIT=FALSE
cmake --build . --target demo 

# Run the demo.
# It should report EXIT_SUCCESS because git history was found.
set +e
./demo &> output.txt
assert "$? -eq 0" $LINENO

# Check that we picked up the true branch name.
set -e
truth=true-branch-name
if ! grep -q $truth output.txt; then
    echo "Demo didn't pickup the branch name"
    assert "1 -eq 0" $LINENO
fi

# Got to a detached head state.
cd $src
touch thing.txt
git add thing.txt
git commit -am "Second commit"
git checkout HEAD~1

# Verify that we show HEAD when there isn't a symbolic ref.
cd $build
cmake --build . --target demo
./demo &> output.txt
if ! grep -q HEAD output.txt; then
    echo "We didn't output HEAD as the branch name."
    assert "1 -eq 0" $LINENO
fi