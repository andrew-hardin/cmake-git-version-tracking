#!/usr/bin/env bash

# Super simple - just run every script that starts with test_*.
# Print exit and success depending on the script exit code.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
for file in $DIR/test_*; do
    $file
    if [ $? -ne 0 ]; then
        echo "TEST: failed $file"
        exit 1
    else
        echo "TEST: success $file"
    fi
    echo
done
echo "All tests passed."
exit 0
