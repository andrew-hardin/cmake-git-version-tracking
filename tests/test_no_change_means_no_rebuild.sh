#!/usr/bin/env bash
#
# Purpose:
# Confirm that the project doesn't update the git-state file when
# no changes have been made.

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

# Create git history
set -e
cd $src
git init
git add .
git commit -am "Initial commit."

# Build the project
set -e
cd $build
cmake -G "$TEST_GENERATOR" $src $version_tracking_module
cmake --build . --target demo

# Run the demo.
./demo &> output.txt

# Check that the git commit matches what git reports.
truth=$(cd $src && git rev-parse --verify HEAD)
if ! grep -q $truth output.txt; then
    # Commit ID wasn't found.
    echo "Demo didn't print the correct commit."
    assert "1 -eq 0" $LINENO
fi

# Watch the git-state file and make sure it doesn't change
# when we try to rebuild the project.
state_file=$build/_deps/cmake_git_version_tracking-build/git-state-hash
demo_file="$build/demo"
last_touched_state="$(stat -c %y $state_file)"
last_touched_exe="$(stat -c %y $demo_file)"
cmake --build . --target demo
new_touched_state="$(stat -c %y $state_file)"
new_touched_exe="$(stat -c %y $demo_file)"

if [ "$last_touched_state" != "$new_touched_state" ]; then
    assert "0 -eq 1" $LINENO
fi
if [ "$last_touched_exe" != "$new_touched_exe" ]; then
    assert "0 -eq 1" $LINENO
fi
