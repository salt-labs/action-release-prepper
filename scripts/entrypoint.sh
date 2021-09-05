#!/usr/bin/env bash

##################################################
# Name: entrypoint.sh
# Description: GitHub Action to prepare for shipping time
##################################################

#########################
# Variables
#########################

# Reference: https://i.stack.imgur.com/T2Fp8.png

# Common
export SCRIPT=${0##*/}
export LOGLEVEL="${INPUT_LOGLEVEL:=INFO}"

# Git inputs
export TAG_ENABLE="${INPUT_TAG_ENABLE:=FALSE}"
export TAG_FORCE="${INPUT_TAG_FORCE:=FALSE}"

# Changelog
export CHANGELOG_ENABLE="${INPUT_CHANGELOG_ENABLE:=FALSE}"
export GIT_PRETTY_FORMAT="${INPUT_GIT_PRETTY_FORMAT:="* %G? %h %aN %s"}"

# Calendar Versioning
export CALVER_ENABLE="${INPUT_CALVER_ENABLE:=FALSE}"
export CALVER_SCHEME="${INPUT_CALVER_SCHEME:=YYYY.0M.0D.GEN}"
export CALVER_SPLIT="${INPUT_CALVER_SPLIT:=.}"
export CALVER_SPLIT_MOD="${INPUT_CALVER_SPLIT_MOD:=$CALVER_SPLIT}"
export TZ="${INPUT_CALVER_TIMEZONE:=UTC-0}"

# Semantic Versioning
export SEMVER_ENABLE="${INPUT_SEMVER_ENABLE:=FALSE}"
export SEMVER_TYPE="${INPUT_SEMVER_TYPE:=PATCH}"
export SEMVER_PREFIX="${INPUT_SEMVER_PREFIX}"
export SEMVER_SUFFIX="${INPUT_SEMVER_SUFFIX}"

# Defaults
export GIT_DIR="${GITHUB_WORKSPACE:+$GITHUB_WORKSPACE/.git/}"
export GIT_TAG_CURRENT="HEAD"
export GIT_TAG_PREVIOUS=""
export CALVER=""
export SEMVER=""

#########################
# Declarations
#########################

# All the required external binaries for this script to work.
declare -r REQ_BINS=(
	echo
	date
	git
	gpg
	printf
)

#########################
# Pre-reqs
#########################

# Import the required functions
# shellcheck source=functions.sh
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

checkLogLevel "${LOGLEVEL}" || { writeLog "ERROR" "Failed to check the log level" ; exit 1 ; }

checkReqs || { writeLog "ERROR" "Failed to check all requirements" ; exit 1 ; }

# Used if the CI is running a simple test
case "${1,,}" in

	*help | *usage )
		usage
		exit 0
	;;

esac

#########################
# Debug
#########################

if [ "${ACTION:-FALSE}" == "TRUE" ];
then

	writeLog "INFO" "Running in GitHub Actions"

fi

if [ "${LOGLEVEL}" == "DEBUG" ];
then

	writeLog "DEBUG" "Dumping diagnostic information for shell ${SHELL} ${BASH_VERSION}"

	writeLog "DEBUG" "########## Environment ##########"
	env

	writeLog "DEBUG" "########## Exported Variables ##########"
	export

	writeLog "DEBUG" "########## Exported Function Names ##########"
  	declare -x -F

	writeLog "DEBUG" "########## Exported Function Contents ##########"
  	export -f

fi

#########################
# Main
#########################

# Configure Git with a default user
gitConfig || { writeLog "ERROR" "Failed to configure the git user" ; exit 1 ; }

# Fetch all the tags that are required for this Action to work
gitFetchAll || { writeLog "ERROR" "Failed to fetch all the Git tags!" ; exit 1 ; }

# Check the TimeZone is available if it was modified by an input
if [ "${TZ}" != "UTC-0" ];
then
	if ( grep -qr "${TZ}" "/usr/share/zoneinfo/" );
	then
		writeLog "INFO" "Time Zone info for ${TZ} is available"
	else
		writeLog "ERROR" "No Time Zone info is available for ${TZ}. Defaulting to UTC-0"
		export TZ="UTC-0"
	fi
fi

# Get the current Calendar Version into $CALVER if enabled
if [ "${CALVER_ENABLE^^}" == "TRUE" ];
then

	writeLog "INFO" "Determining Calendar Version"

	getCalVer "${CALVER_SCHEME}" "${CALVER_SPLIT}" "${CALVER_SPLIT_MOD}" || { writeLog "ERROR" "Failed to get the current Calendar Version" ; exit 1 ; }

    # Append any prefix and suffix if provided
    CALVER="${CALVER_PREFIX}${CALVER}${CALVER_SUFFIX}"

	writeLog "INFO" "Calendar Version: ${CALVER} Timezone: ${TZ}"
	echo "::set-output name=calver::${CALVER}"

fi

# Determine the current Semantic Version into $SEMVER if enabled
if [ "${SEMVER_ENABLE^^}" == "TRUE" ];
then

	getSemVer "${SEMVER_TYPE}" "${SEMVER_PREFIX}" || { writeLog "ERROR" "Failed to get the current Semantic Version" ; exit 1 ; }

	writeLog "INFO" "Semantic Version: ${SEMVER}"
	echo "::set-output name=semver::${SEMVER}"

fi

# Output a current changelog if enabled
if [ "${CHANGELOG_ENABLE^^}" == "TRUE" ] ;
then

	gitChangelog || { writeLog "ERROR" "Failed to generate change log" ; exit 1 ; }

	writeLog "INFO" "Branch changelog"

	cat <<- EOF
	$CHANGELOG
	EOF

	# Multi-line strings don't work in GitHub Actions without escaping.
	CHANGELOG="${CHANGELOG//'%'/'%25'}"
	CHANGELOG="${CHANGELOG//$'\n'/'%0A'}"
	CHANGELOG="${CHANGELOG//$'\r'/'%0D'}"

	echo "::set-output name=changelog::${CHANGELOG}"

fi

# Apply a tag if enabled.
if [ "${TAG_ENABLE^^}" == "TRUE" ] ;
then

	if [ "${CALVER_ENABLE^^}" == "TRUE" ];
	then
		gitTag "${CALVER}" "${TAG_FORCE^^}" || { writeLog "ERROR" "Failed to apply the tag ${CALVER}" ; exit 1 ; }
	fi

	if [ "${SEMVER_ENABLE^^}" == "TRUE" ];
	then
		gitTag "${SEMVER}" "${TAG_FORCE^^}" || { writeLog "ERROR" "Failed to apply the tag ${SEMVER}" ; exit 1 ; }
	fi

fi

# Split the GitHub repository into Owner & Repository
REPO_OWNER="${GITHUB_REPOSITORY%/*}"
REPO_NAME="${GITHUB_REPOSITORY#*/}"

writeLog "INFO" "Setting Output 'repo_owner' to ${REPO_OWNER}"
echo "::set-output name=repo_owner::$REPO_OWNER"
#echo "::set-env name=REPO_OWNER::$REPO_OWNER"

writeLog "INFO" "Setting Output 'repo_name' to ${REPO_NAME}"
echo "::set-output name=repo_name::$REPO_NAME"
#echo "::set-env name=REPO_NAME::$REPO_NAME"

exit 0
