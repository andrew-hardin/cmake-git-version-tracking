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

# Check that the git commit matches what git reports.
set -e
truth=$(cd $src && git rev-parse --verify HEAD)
if ! grep -q $truth output.txt; then
    # Commit ID wasn't found.
    echo "Demo didn't print the correct commit."
    assert "1 -eq 0" $LINENO
fi

# Modify a file and commit the changes.
# Then rebuild.
cd $src
echo "this is a cool edit" >> README.md
git commit -am "A new commit with a new ID."
cd $build
cmake --build . --target demo

# Repeat the prior two tests by running the demo and checking
# the commit ID.
set +e
./demo &> output.txt
assert "$? -eq 0" $LINENO

# Check that the git commit matches what git reports.
set -e
truth_2=$(cd $src && git rev-parse --verify HEAD)
assert "! "$truth" = "$truth_2"" $LINENO
if ! grep -q $truth_2 output.txt; then
    # Commit ID wasn't found.
    echo "Demo didn't print the correct commit."
    assert "1 -eq 0" $LINENO
fi
