
#!/usr/bin/env bash
#
# Purpose:
# Test how the demo performs when no .git directory was found.

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

# Configure and build the project.
# The build should fail because the git repo is missing.
set -e
cd build
cmake -G "$TEST_GENERATOR" $src $version_tracking_module
set +e
cmake --build . --target demo
assert "$? -ne 0" $LINENO
