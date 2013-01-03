#!/bin/bash

# These are all present as globals in , here just to silence
# local IDE "errors"
USAGE_ERROR_STR=
ERROR_STR=

testMissingAllArgs() {
    . $SCRIPT_TO_BE_TESTED >/dev/null 2>&1
    assertEquals "Required args missing should result in usage error str" \
        "$USAGE_ERROR_STR" "$ERROR_STR"
}

# test suite setup and execution
# ----------------------------------------------------------------------

# Base directory of this project is one directory up from this script
BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

SCRIPT_TO_BE_TESTED="$BASE_DIR/SOURCES/jenkins-rpm-publish/usr/local/bin/jenkins-publish-rpm.sh"

# load code under test
. $SCRIPT_TO_BE_TESTED >/dev/null 2>&1

# Run the tests
. $BASE_DIR/TESTS/shunit2/src/shunit2