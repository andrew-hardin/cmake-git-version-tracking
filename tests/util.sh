#!/usr/bin/env bash
# Purpose: load scripts and variables that are common between tests.
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/assert.sh

# Making a temporary directory is tricky depending on the platform.
# Solution pulled from here:
#  https://unix.stackexchange.com/questions/30091/fix-or-alternative-for-mktemp-in-os-x
create_temp_directory=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
demo_src=$DIR/hello-world
interface_src=$DIR/interfaces
version_tracking_module="-DVERSION_TRACKING_MODULE_PATH=$DIR/.."
git_watcher=$DIR/../git_watcher.cmake

# Create a root directory and copy the demo code to there.
root=$create_temp_directory
src=$root/source
build=$root/build
mkdir -p $build
cp -r $demo_src $src
cp $git_watcher $src/..

# Make sure we don't carry along a preconfigured git.h header.
if [ -f src/git.h ]; then
    rm $src/git.h
fi

# Set the default generator if it hasn't been set already.
if [ ! -n "$TEST_GENERATOR" ]; then
  TEST_GENERATOR="Ninja"
fi

function cleanup () {
  if [ -d "$root" ]; then
    echo "TEST: removing test root directory..."
    rm -rf "$root"
  fi
}
trap cleanup EXIT

echo "========================="
echo "Running test in \"$root\""
echo "-------------------------"
cd $root