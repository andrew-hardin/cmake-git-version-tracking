#!/usr/bin/env bash
#
# Purpose:
# Test that commit attributes are being tracked.

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

# Create git history
set -e
cd $src
git init
git add .
git commit --author="Author Name <author@address.com>" -am "Initial commit." -m "Commit body."

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

set -e
# Check name.
if ! grep -q "Author Name" output.txt; then
    echo "Missing author name"
    assert "1 -eq 0" $LINENO
fi
# Check address.
if ! grep -q "author@address.com" output.txt; then
    echo "Missing author email address"
    assert "1 -eq 0" $LINENO
fi
# Check subject.
if ! grep -q "Initial commit." output.txt; then
    echo "Missing commit subject line"
    assert "1 -eq 0" $LINENO
fi
# Check body.
if ! grep -q "Commit body." output.txt; then
    echo "Missing commit body"
    assert "1 -eq 0" $LINENO
fi