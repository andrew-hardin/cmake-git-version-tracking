#!/usr/bin/env bash
#
# Purpose:
# Test that git --describe reports a tag.

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

# Create git history
set -e
cd $src
git init
git add .
git commit -am "Initial commit."
echo "this is a new file" > some_file
git add .
git commit -am "Second commit."
git tag -a v1.2 -m "version 1.2"
echo "another file after the tag" > some_file_two
git add .
git commit -am "Third commit."


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

# Check that the tag was printed
set -e
if ! grep -q "v1.2" output.txt; then
    echo "Missing the version from describe."
    assert "1 -eq 0" $LINENO
fi
