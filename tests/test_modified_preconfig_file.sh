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

# Make the state dirty, so that when we modify the
# preconfigure file it doesn't regenerate just
# because the git-state changed.
echo "hello world" > dirty

# Configure and build the project.
set -e
cd $build
cmake -G "$TEST_GENERATOR" $src $version_tracking_module
cmake --build . --target demo

# Record the date on the post-configure file, then
# modify the pre-configure file.
file_to_check=./_deps/cmake_git_version_tracking-build/git.c
file_to_modify=./_deps/cmake_git_version_tracking-src/git.c.in
before=$(stat -c %y $file_to_check)
echo "// this is a modification" >> "$file_to_modify"

# Make the project again. Verify that it regenerated
# our git file.
cmake --build . --target demo
after=$(stat -c %y $file_to_check)

# Modified stamps need to be different.
if [ "$before" == "$after" ]; then
    assert "1 -eq 0" $LINENO
fi
