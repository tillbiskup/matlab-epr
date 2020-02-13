#!/bin/bash
#
# Increment version number (last part of version string)
# read from a Contents.m file containing the version numberi
# in its second line.
#
# Assuming a version number scheme following SemVer
# consisting of
#
#	MAJOR.MINOR.PATCH
#
# in which case "PATCH" is incremented,
# or alternatively
#
#	MAJOR.MINOR.PATCH.dev#
#
# where the number following "dev" is incremented.
#
# If the internal variable CHECKGIT is set to "true", the file
# containing the version string will be checked for manual changes
# and if there are any, the script will exit immediately.
#
# Copyright (c) 2017-20, Till Biskup
# 2020-01-08

# Some configuration
VERSIONFILE="Contents.m"
CHECKGIT=true # set to "true" to check for changes via git diff

# Internal functions
function join_by { local IFS="$1"; shift; echo "$*"; }

if [[ ${CHECKGIT} == true && `git diff --name-only ${VERSIONFILE}` ]]
then
    echo "File $VERSIONFILE has been changed already..."
    exit
fi


# Read version from file
read oldVersionString <<< `tail -1 ${VERSIONFILE} |cut -d ' ' -f3`

# Read date from file
read oldDateString <<< `tail -1 ${VERSIONFILE} |cut -d ' ' -f4`

# Split version string
IFS='.' read -r -a versionArray <<< "$oldVersionString"

lastPart=${versionArray[${#versionArray[@]}-1]}

# Check whether we need to increment a development version
# Otherwise just increment $lastPart
if [[ ${lastPart} =~ .*dev.* ]]
then
    IFS='dev' read -r -a splitLastPart <<< "$lastPart"
    revision=${splitLastPart[${#splitLastPart[@]}-1]}
    ((revision++))
    lastPart=dev${revision}
else
    ((lastPart++))
fi

# Reassign last part of versionArray
versionArray[${#versionArray[@]}-1]=${lastPart}

# Concatenate new version string
newVersionString=`join_by . ${versionArray[@]}`

# Create new date string
newDateString=`date "+%d-%b-%Y"`

# Write new version string to file
sed -i '' -e "s/${oldVersionString}/${newVersionString}/g" ${VERSIONFILE}
sed -i '' -e "s/${oldDateString}/${newDateString}/g" ${VERSIONFILE}

if [[ ${CHECKGIT} == true ]]
then
    git add ${VERSIONFILE}
    echo "Version in version file upped"
fi
