#!/usr/bin/env bash
#
# Purpose:
# Test how the demo performs when a new commit is made.

# Load utilities.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/util.sh

# Clean up the default unit test setup.
# We'll be testing the interface projects instead.
rm -rf $src
cp -r $interface_src $src

# Create git history
set -e
cd $src
git init
touch README.md
git add .
git commit -am "Initial commit."

function check_interface() {

    configure_flags=$1
    source_dir=$2

    # Build the project
    set -e
    cd $build
    rm -rf ./*
    cmake -G "$TEST_GENERATOR" $source_dir $version_tracking_module $configure_flags
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
}

check_interface "" $src/cxx98_cxx17
check_interface "-DCXX_STANDARD=17" $src/cxx98_cxx17
check_interface "" $src/c99
