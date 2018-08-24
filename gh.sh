#!/bin/bash

echo_red() {
	printf "\033[0;31m%s\033[0m\n" "$@"
}

echo_green() {
	printf "\033[0;32m%s\033[0m\n" "$@"
}

echo_cyan() {
	printf "\033[0;36m%s\033[0m\n" "$@"
}

# Some helptext when things go awry.
usage() {
	case "$1" in
	'latest')
		echo_red "Usage: $0 latest Username/MyRepo --download-url"
	;;
	'create')
		echo_red "Usage: $0 create Username/MyRepo tag_name"
	;;
	'upload')
		echo_red "Usage: $0 upload Username/MyRepo tag_name artifact"
	;;
	'delete')
		echo_red "Usage: $0 delete Username/MyRepo tag_name"
	;;
	*)
		echo_red "Usage: $0 [latest|create|upload|delete] Username/MyRepo tag_name"
		exit 1
	;;
	esac
}

# Make sure we've passed what we need to do the job.
handle_args() {
	set -e

	REPO_SLUG=$2

	case "$1" in
	'latest')
		case "$#" in
		'2')
			get_latest_url
			download_asset
		;;
		'3') # Just return the url, don't download
			get_latest_url
			echo ${RELEASE_ASSET_URL}
		;;
		*)
			usage $@
			exit 1
		;;
		esac
	;;
	'create')
		[ $# -ne 3 ] && { usage $@; exit 1;} # 3 args for create command
		require_access_token
		RELEASE_TAG=$3
		create
	;;
	'upload')
	[ $# -ne 4 ] && { usage $@; exit 1;} # 4 args for upload command
		require_access_token
		RELEASE_TAG=$3
		RELEASE_ARTIFACT=$4
		RELEASE_ARTIFACT_NAME=$(basename "$RELEASE_ARTIFACT")
		get_by_tag
		upload
	;;
	'delete')
	[ $# -ne 3 ] && { usage $@; exit 1;} # 3 args for delete command
		require_access_token
		RELEASE_TAG=$3
		get_by_tag
		delete
	;;
	*)
		usage
		exit 1
	;;
	esac
}

require_access_token(){
	if [ -z "$GITHUB_ACCESS_TOKEN" ]; then
		echo_red "GITHUB_ACCESS_TOKEN is not set in the environment. This must be set in order for this scrip to run. Good Day!"
		exit 1
	fi
}

get_latest_url(){
	qs=""
	if [ "$GITHUB_ACCESS_TOKEN" ]; then
		qs="?access_token=${GITHUB_ACCESS_TOKEN}"
	fi

	RELEASE_ASSET_URL=$(curl "https://api.github.com/repos/${REPO_SLUG}/releases/latest${qs}" | jq -r .assets[0].browser_download_url)
}

download_asset(){
	echo_green 'Download latest release asset'
	if [ -z "${RELEASE_ASSET_URL}"// ] || [ ${RELEASE_ASSET_URL} == 'null' ]
	then
		echo_red "Unable to find latest release or could not find its asset."
		if [ -z "$GITHUB_ACCESS_TOKEN" ]; then
			echo_green "Is it a private repo? You may need to specify a GitHub access token using env variable 'GITHUB_ACCESS_TOKEN'..."
		fi
		exit 1
	fi

	echo_green "Found latest Release asset at '${RELEASE_ASSET_URL}'."
	echo_green "Downloading '${RELEASE_ASSET_URL}'..."
	curl -LO ${RELEASE_ASSET_URL}
	echo_green "Done."
}

get_by_tag(){
	echo_green 'Get by tag'
	RELEASE_ID=$(curl "https://api.github.com/repos/${REPO_SLUG}/releases/tags/$RELEASE_TAG?access_token=${GITHUB_ACCESS_TOKEN}" | jq -r .id)
	echo_cyan "Found Release Id of '${RELEASE_ID}' for tag '${RELEASE_TAG}'."
}

get_upload_url_by_id(){
	echo_green 'Get by id'
	RELEASE_UPLOAD_URL=$(curl "https://api.github.com/repos/${REPO_SLUG}/releases/$RELEASE_ID?access_token=${GITHUB_ACCESS_TOKEN}" | jq -r .upload_url)
	echo_cyan "Found upload_url of '${RELEASE_UPLOAD_URL}' for id '${RELEASE_ID}'."
}

create(){
	echo_green 'Create'
	RELEASE_ID=$(curl --header 'Content-Type: application/json' \
		-X POST \
		-d '{"tag_name":"'${RELEASE_TAG}'"}' \
		"https://api.github.com/repos/${REPO_SLUG}/releases?access_token=${GITHUB_ACCESS_TOKEN}" | jq -r .id)
	if [ -z "${RELEASE_ID}"// ] || [ ${RELEASE_ID} == 'null' ]
	then
		echo_red "Looks like there was an error creating a release under the tag ${RELEASE_TAG}. Got ${RELEASE_ID}"
		exit 1
	fi
	echo_green "Created a new release with and id of '${RELEASE_ID}'"
}

upload(){
	if [ -z "${RELEASE_ID}"// ] || [ ${RELEASE_ID} == 'null' ]
	then
		echo_green "Looks like there is no release under the tag ${RELEASE_TAG}, creating one..."
		create
	fi
	echo_green "Grabbing the upload url..."
	get_upload_url_by_id

	if [ -z "${RELEASE_UPLOAD_URL}"// ] || [ ${RELEASE_UPLOAD_URL} == 'null' ]
	then
		echo_green "Looks like there was an error trying to get the upload_url"
		exit 1
	fi

	echo_cyan "We have an upload_url of '${RELEASE_UPLOAD_URL}'"
	echo_cyan "Unfucking the template crap..."
	RELEASE_UPLOAD_URL=${RELEASE_UPLOAD_URL%\{*}
	echo_cyan "Now we have an upload_url of '${RELEASE_UPLOAD_URL}'"

	echo_green 'Upload'
	RESPONSE=$(curl \
		--upload-file ${RELEASE_ARTIFACT} \
		-G \
		--data-urlencode "name=${RELEASE_ARTIFACT_NAME}" \
		--header 'Content-Type: application/x-rpm' \
		--header 'Connection: keep-alive' \
		--header 'Accept: application/json' \
		-X POST \
		"${RELEASE_UPLOAD_URL}?access_token=${GITHUB_ACCESS_TOKEN}")

	ARTIFACT_URL=$(echo $RESPONSE | jq -r .browser_download_url)

	if [ -z	"${ARTIFACT_URL}"// ] || [ ${ARTIFACT_URL} == 'null' ]
	then
		echo_red "================================================"
		echo_red " FAIL                  FAIL                 FAIL"
		echo_red "================================================"
		echo_red "It looks bad... The upload is probably borked."
		echo_red "================================================"
		echo_red "$(echo $RESPONSE | jq -r .)"
		echo_red "================================================"
		exit 1
	else
		echo_green "================================================"
		echo_green " WINNER               WINNER              WINNER"
		echo_green "================================================"
		echo_green "The artifact '${RELEASE_ARTIFACT}' has been uploaded as '$(echo $RESPONSE | jq -r .name)' and is available for download from '$(echo $RESPONSE | jq -r .browser_download_url)'"
		echo_green "================================================"
		echo_cyan "$(echo $RESPONSE | jq -r .)"
		echo_green "================================================"
		exit 0
	fi
}

delete(){
	echo_green 'Delete'
	RESPONSE=$(curl -sw '%{http_code}' -X DELETE "https://api.github.com/repos/${REPO_SLUG}/releases/${RELEASE_ID}?access_token=${GITHUB_ACCESS_TOKEN}")
	if [[ $RESPONSE == *"204"* ]]; then
		echo_green "The release '${RELEASE_ID}' has been deleted."
		exit 0
	elif [[ $RESPONSE == *"404"* ]]; then
		echo_red "The release with an id of '${RELEASE_ID}' was not found - maybe it has been deleted."
		exit 1
	else
		echo_red "There was a problem deleteing the release '${RELEASE_ID}'."
		echo_red "================================================"
		echo_red "${RESPONSE}"
		echo_red "================================================"
		exit 1
	fi
}

# Script entrypoint
main() {
	handle_args $@
}

main "$@"
