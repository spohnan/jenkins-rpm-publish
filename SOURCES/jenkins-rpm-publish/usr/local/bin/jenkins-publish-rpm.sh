#!/bin/bash
#
# jenkins-publish-rpm.sh - A script to publish rpms built by jenkins to a local rpm repo
#
# This script will perform the following tasks:
#  - Copy an rpm into a directory configured to host rpms
#  - Refresh the metadata of the yum repository into which a new rpm has been added
#  - Optionally, it will also optionally truncate the number of versions a single rpm kept in the repo

USAGE_ERROR_STR="Usage: jenkins-publish-rpm.sh REPO_DIR RPM_NAME [MAX_VERSIONS]"
ERROR_STR=

RPM_REPO_DIR="$1"
RPM_NAME="$2"
MAX_RPM_VERSIONS=$3


# Have to have at least the mandatory arguments present
if [ $# -lt 2 ] ; then
    ERROR_STR=$USAGE_ERROR_STR
    echo $USAGE_ERROR_STR
fi