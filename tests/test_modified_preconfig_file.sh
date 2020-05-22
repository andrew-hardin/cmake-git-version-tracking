#!/usr/bin/env bash
#
# Purpose:
# Test that items are regenerated after modifying the pre-configure
# file. See issue 14.

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

# Create git history
cd $src
git init
git add .
git commit -am "Initial commit."

# Configure and build the project.
set -e
cd $build
cmake -G "$TEST_GENERATOR" $src
cmake --build . --target demo

# Record the date on the post-configure file, then
# modify the pre-configure file.
before=$(stat -c %y $src/git.h)
echo "// this is a modification" >> "$src/git.h.in"

# Make the project again. Verify that it regenerated
# our git file.
cmake --build . --target demo
after=$(stat -c %y $src/git.h)

# Modified stamps need to be different.
if [ "$before" == "$after" ]; then
    assert "1 -eq 0" $LINENO
fi
