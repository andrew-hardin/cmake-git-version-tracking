#!/usr/bin/env bash
#
# PURPOSE
#  Build and run the example applications.
#  The goal is to avoid shipping a broken example.
#  That wouldn't make a good first impression...
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/../hello-world
mkdir build
cd build
cmake ..
make
./demo

cd $DIR/../better-example
mkdir build
cd build
cmake ..
make
./demo