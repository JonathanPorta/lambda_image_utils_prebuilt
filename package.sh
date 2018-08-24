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
  echo_red "Usage: $0 path-to-package.json"
  echo_cyan "package.json must contain the following keys defined:"
  echo_cyan "{project, version, url, vendor, description, repository, files}"
}

parse_package_json(){
  missing_key(){
    PACKAGE_JSON_VALID=true
    echo_red "The key '$1' was not found in '${PACKAGE_JSON_PATH}'. $2"
  }

  PACKAGE_JSON_VALID=false

  project=$(cat ${PACKAGE_JSON_PATH} | jq -er .name) || missing_key 'name'
  version=$(cat ${PACKAGE_JSON_PATH} | jq -er .version) || missing_key 'version'
  url=$(cat ${PACKAGE_JSON_PATH} | jq -er .homepage) || missing_key 'homepage'
  vendor=$(cat ${PACKAGE_JSON_PATH} | jq -er .author) || missing_key 'author'
  description=$(cat ${PACKAGE_JSON_PATH} | jq -er .description) || missing_key 'description'
  install_prefix="/opt/$(cat ${PACKAGE_JSON_PATH} | jq -er .repository)" || missing_key 'repository' "Please format as the shortcut syntax username/reponame as described in https://docs.npmjs.com/files/package.json#repository This value will be used as the install prefix. Example: install_prefix=/opt/username/repo/"
  files=$(cat ./${PACKAGE_JSON_PATH} | jq -er '.files | join(" ")') || missing_key 'files' 'Files should be an array of the files and directories, relative to the current working directory, that will be included in the RPM.'

  if [ "$PACKAGE_JSON_VALID" = true ]; then
    echo_red "Please fix the missing keys in '${PACKAGE_JSON_PATH}' before you ever think about trying to run this script again."
    usage
    exit 1
  fi
}

check_env(){
  if [ -z "$BUILD_NUM" ]; then
    echo_red 'BUILD_NUM is not set in the environment. If this is being ran in CI, you might try something like `BUILD_NUM="$CIRCLE_BUILD_NUM" '$0'`'
    exit 1
  fi

	BEFORE_REMOVE_SCRIPT_PATH="before_remove.sh"
  AFTER_INSTALL_SCRIPT_PATH="after_install.sh"
  AFTER_REMOVE_SCRIPT_PATH="after_remove.sh"
	AFTER_UPGRADE_SCRIPT_PATH="after_upgrade.sh"

	if [ ! -f $BEFORE_REMOVE_SCRIPT_PATH ]; then
    echo_cyan "There doesn't appear to be an 'before_remove' script at "$BEFORE_REMOVE_SCRIPT_PATH". Creating a noop placeholder..."
    cp ./ops/templates/rpm/$BEFORE_REMOVE_SCRIPT_PATH $BEFORE_REMOVE_SCRIPT_PATH
    echo_cyan "Done."
  fi

  if [ ! -f $AFTER_INSTALL_SCRIPT_PATH ]; then
    echo_cyan "There doesn't appear to be an 'after_install' script at '$AFTER_INSTALL_SCRIPT_PATH'. Creating a noop placeholder..."
    cp ./ops/templates/rpm/$AFTER_INSTALL_SCRIPT_PATH $AFTER_INSTALL_SCRIPT_PATH
    echo_cyan "Done."
  fi

  if [ ! -f $AFTER_REMOVE_SCRIPT_PATH ]; then
    echo_cyan "There doesn't appear to be an 'after_remove' script at "$AFTER_REMOVE_SCRIPT_PATH". Creating a noop placeholder..."
    cp ./ops/templates/rpm/$AFTER_REMOVE_SCRIPT_PATH $AFTER_REMOVE_SCRIPT_PATH
    echo_cyan "Done."
  fi

	if [ ! -f $AFTER_UPGRADE_SCRIPT_PATH ]; then
    echo_cyan "There doesn't appear to be an 'after_upgrade' script at "$AFTER_UPGRADE_SCRIPT_PATH". Creating a noop placeholder..."
    cp ./ops/templates/rpm/$AFTER_UPGRADE_SCRIPT_PATH $AFTER_UPGRADE_SCRIPT_PATH
    echo_cyan "Done."
  fi

	chmod +x $BEFORE_REMOVE_SCRIPT_PATH
  chmod +x $AFTER_INSTALL_SCRIPT_PATH
  chmod +x $AFTER_REMOVE_SCRIPT_PATH
	chmod +x $AFTER_UPGRADE_SCRIPT_PATH
}

# Make sure we've passed what we need to do the job.
handle_args() {
	set -e

  [ $# -ne 1 ] && { usage $@; exit 1;} # only takes the path to a package.json-esque file.
  PACKAGE_JSON_PATH=$1
  if [ ! -f ${PACKAGE_JSON_PATH} ]; then
    echo_red "Unable to find file '${PACKAGE_JSON_PATH}'. Please make sure this points to a real file with JSON inside."
    usage
    exit 1
  fi

  check_env
  parse_package_json
  iteration="$BUILD_NUM.git$(git rev-parse --short HEAD)"
  architecture='x86_64'
}

package_it(){
  echo_green 'Building RPM...'

cat << EOF
  Project: $project
  Version: $version
  Iteration: $iteration
  Architecture: $architecture
  Project URL: $url
  Vendor: $vendor
  Description: $description
  Install Prefix: $install_prefix
  Files to Include: $files
EOF

  fpm -s dir -t rpm \
    --name "${project}" \
    --version "${version}" \
    --iteration "${iteration}" \
    --architecture "${architecture}" \
    --url "${url}" \
    --vendor "${vendor}" \
    --description "${description}" \
    --prefix "${install_prefix}" \
    --after-install $AFTER_INSTALL_SCRIPT_PATH \
    --after-remove $AFTER_REMOVE_SCRIPT_PATH \
    --after-upgrade $AFTER_UPGRADE_SCRIPT_PATH \
    --before-remove $BEFORE_REMOVE_SCRIPT_PATH \
    ${files}

    echo_green 'Done.'
}

# Script entrypoint
main() {
	handle_args $@
  package_it
}

main "$@"
