#!/bin/bash
#
# jenkins-publish-rpm.sh - A script to publish rpms built by jenkins to a local rpm repo
#
# This script will perform the following tasks:
#  - Copy an rpm into a directory configured to host rpms
#  - Refresh the metadata of the yum repository into which a new rpm has been added
#  - Optionally, it will also optionally truncate the number of versions a single rpm kept in the repo

USAGE_ERROR_STR="Usage: jenkins-publish-rpm.sh REPO_DIR RPM_NAME [MAX_VERSIONS]"
RPM_REPO_DIR_ERROR_STR="Could not locate or access rpm repo directory argument"
MAX_RPM_VERSION_ERROR_STR="The max number of rpm versions to keep argument must be a positive integer"
ERROR_STR=

# A special value used for the RPM name that will allow for testing and not actually publish
TEST_RUN="THIS_IS_ONLY_A_TEST"

RPM_REPO_DIR="$1"
RPM_NAME="$2"
MAX_RPM_VERSIONS=$3
NUM_ARGUMENTS=$#

# This is the main purpose of this script
publishRpm() {

    # Copy the file to the right place
    cp -f $RPM_NAME $RPM_REPO_DIR

    # If the optional max versions argument was passed
    if ( isPositiveIntegerValue "$MAX_RPM_VERSIONS" ) ; then
        truncateNumVersions $RPM_REPO_DIR $RPM_NAME $MAX_RPM_VERSIONS
    fi

    # Update the RPM repo (use sqlite db and only update changes if possible)
    createrepo --database --update $RPM_REPO_DIR
}

# truncateNumVersions PATH, RPM_NAME, NUM_VERSIONS_TO_KEEP
#   Used to get rid of older versions of the same RPM
truncateNumVersions() {
    # Sanity check the arguments a bit
    if [ -d $1 ] && isPositiveIntegerValue $3 ; then
        # List in time sequence with newest on top, use tail to figure out how many
        # of the oldest files we want to chop from the bottom of the list and pipe
        # to the remove command
        ls -t $1/$2-*.rpm | tail -n +$(($3+1)) | xargs rm -f
    fi
}

isPositiveIntegerValue() {
    # Is it a numeric integer
    if [[ "$1" =~ ^[0-9]+$ ]] ; then
        # Is it greater than or equal to 1
        [[ "$1" -ge 1 ]] && return 0 || return 1
    else
        # Nope
        return 1
    fi
}

# Some reading online about edge cases with empty string comparisons led me to encapsulate
# the "add an extra char" recommended solution in this method
isStringValPresent() {
    [ "x$1" != "x" ] && return 0 || return 1
}

# If the name of the RPM is a specific value then this is being run by the test suite
isTestRun() {
    [ "$RPM_NAME" = "$TEST_RUN" ] && return 0 || return 1
}

# Check the number of arguments
if [[ $NUM_ARGUMENTS -ge 2 && $NUM_ARGUMENTS -le 3 ]] ; then

    # Check that the repo dir given actually exists
    if [ ! -d $RPM_REPO_DIR ] ; then
        ERROR_STR=$RPM_REPO_DIR_ERROR_STR
    fi

    # Check using the numeric comparison to check against itself, will error if not a number
    if ( isStringValPresent "$MAX_RPM_VERSIONS" && ! isPositiveIntegerValue "$MAX_RPM_VERSIONS" ) ; then
        ERROR_STR=$MAX_RPM_VERSION_ERROR_STR
    fi

    if ( ! isStringValPresent "$ERROR_STR" &&  ! isTestRun ) ; then
        # Good to go ... run the main method of the script
        publishRpm

    else
        # Something wrong, return error string
        echo $ERROR_STR
    fi

else
    ERROR_STR=$USAGE_ERROR_STR
    echo $USAGE_ERROR_STR
fi