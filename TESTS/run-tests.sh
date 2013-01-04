#!/bin/bash

# These are all present as globals in , here just to silence
# local IDE "errors"
USAGE_ERROR_STR=
RPM_REPO_DIR_ERROR_STR=
MAX_RPM_VERSION_ERROR_STR=
TEST_RUN=
ERROR_STR=
NO_ERRORS=""


# max number of rpm version truncation tests
# ----------------------------------------------------------------------
testMaxVersionTruncation() {
    local MY_RPM_NAME="cool-stuff"
    local MAX_NUM_VERSIONS=2

    # Set up new files, instruct to keep only the two latest
    makeTenRpmFiles $MY_RPM_NAME
    truncateNumVersions $TEST_TMPDIR $MY_RPM_NAME $MAX_NUM_VERSIONS

    local NUM_FILES_REMAINING=$(ls -1 $TEST_TMPDIR | wc -l |  tr -d ' ')
    assertEquals "Should be $MAX_NUM_VERSIONS files left out of the $NUM_TEST_RPM_FILES test files" \
        $MAX_NUM_VERSIONS $NUM_FILES_REMAINING
}

testMaxVersionTruncationWithBadNumberArg() {
    local MY_RPM_NAME="cool-stuff"
    local MAX_NUM_VERSIONS=foo

    # Set up new files, instruct to keep only the two latest
    makeTenRpmFiles $MY_RPM_NAME
    truncateNumVersions $TEST_TMPDIR $MY_RPM_NAME $MAX_NUM_VERSIONS

    local NUM_FILES_REMAINING=$(ls -1 $TEST_TMPDIR | wc -l |  tr -d ' ')
    assertEquals "Should be all $NUM_TEST_RPM_FILES files left as we gave a bad numeric argument" \
        $NUM_TEST_RPM_FILES $NUM_FILES_REMAINING
}

testMaxVersionTruncationWithSeveralRpms() {
    local RPM_ONE_NAME="cool-stuff"
    local RPM_TWO_NAME="cool-stuff2"
    local MAX_NUM_VERSIONS=4

    # Set up both sets of files but only truncate one of them
    makeTenRpmFiles $RPM_ONE_NAME
    makeTenRpmFiles $RPM_TWO_NAME
    truncateNumVersions $TEST_TMPDIR $RPM_ONE_NAME $MAX_NUM_VERSIONS

    # Count up the number of each type of file remaining
    local NUM_RPM_ONE_FILES_REMAINING=$(ls -1 $TEST_TMPDIR/$RPM_ONE_NAME-*.rpm | wc -l |  tr -d ' ')
    local NUM_RPM_TWO_FILES_REMAINING=$(ls -1 $TEST_TMPDIR/$RPM_TWO_NAME-*.rpm | wc -l |  tr -d ' ')

    # Check to ensure we only deleted only one type of rpm
    assertEquals "Should be $MAX_NUM_VERSIONS files left after calling truncate" \
            $MAX_NUM_VERSIONS $NUM_RPM_ONE_FILES_REMAINING

    assertEquals "Should be all $NUM_RPM_TWO_FILES_REMAINING files left as we did not call truncate" \
        $NUM_TEST_RPM_FILES $NUM_RPM_TWO_FILES_REMAINING
}


# utility routine tests
# ----------------------------------------------------------------------

testBigIntegerValue() {
    assertTrue "A single number should return true" "isPositiveIntegerValue 123409871023432"
}

testSingleIntegerValue() {
    assertTrue "A single number should return true" "isPositiveIntegerValue 9"
}

testZeroIntegerValue() {
    assertFalse "A zero is not a positive integer" "isPositiveIntegerValue 0"
}

testNegativeIntegerValue() {
    assertFalse "A negative integer should return false" "isPositiveIntegerValue -1"
}

testAlphaNumericValue() {
    assertFalse "Letters are not numeric" "isPositiveIntegerValue A"
}

testBlankValue() {
    assertFalse "An empty value should not be considered numeric" "isPositiveIntegerValue "
}

testEmptyStringValue() {
    assertFalse "Empty string should return false" "isStringValPresent "
}

testStringValue() {
    assertTrue "Empty string should return false" "isStringValPresent foo"
}

# argument parsing tests
# ----------------------------------------------------------------------

testNonExistentDirectoryArg() {
    . $SCRIPT_TO_BE_TESTED /tmp/ab.1231232.i.do.not.exist foo2 5 >/dev/null 2>&1
    assertEquals "Rpm directory arg must refer to an actual directory" \
        "$RPM_REPO_DIR_ERROR_STR" "$ERROR_STR"
}

testNonNumericMaxNumRpmsArg() {
    . $SCRIPT_TO_BE_TESTED /tmp foo2 foo3 >/dev/null 2>&1
    assertEquals "Third argument should be numeric if present" \
        "$MAX_RPM_VERSION_ERROR_STR" "$ERROR_STR"
}

testTooFewArgs() {
    . $SCRIPT_TO_BE_TESTED foo1 >/dev/null 2>&1
    assertEquals "Required args missing should result in usage error str" \
        "$USAGE_ERROR_STR" "$ERROR_STR"
}

testTooManyArgs() {
    . $SCRIPT_TO_BE_TESTED foo1 foo2 foo3 foo4 >/dev/null 2>&1
    assertEquals "Too many args should result in usage error str" \
        "$USAGE_ERROR_STR" "$ERROR_STR"
}

testMissingAllArgs() {
    . $SCRIPT_TO_BE_TESTED >/dev/null 2>&1
    assertEquals "Required args missing should result in usage error str" \
        "$USAGE_ERROR_STR" "$ERROR_STR"
}

testOnlyRequiredArgs() {
    . $SCRIPT_TO_BE_TESTED /tmp $TEST_RUN >/dev/null 2>&1
    assertEquals "Third argument is optional" "$NO_ERRORS" "$ERROR_STR"
}

# file system dependent tests setup, tear down and utility methods
# ----------------------------------------------------------------------
TEST_TMPDIR=
oneTimeSetUp() {
    TEST_TMPDIR=$(mktemp -d /tmp/jenkins-rpm-publish-tests.XXXXXX)
}

oneTimeTearDown() {
    rm -fr $TEST_TMPDIR
}

tearDown() {
    rm -fr $TEST_TMPDIR/*
}

# Given a base name for our fake rpm files create 10 of them in the tmp dir
NUM_TEST_RPM_FILES=10
makeTenRpmFiles() {
    for i in {0..9}; do
        touch -t "201301010${i}00" $TEST_TMPDIR/$1-$i.rpm
    done
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