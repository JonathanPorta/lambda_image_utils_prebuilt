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
  echo_red "Usage: $0 [set] options"
}

set_usage() {
  echo_red "Usage: $0 set [env] repo json"
}

handle_args(){
  REPO=${3}

  case "$1" in
  'set')
    case "$2" in
    'env')
      # Handle wrong number of  args being passed.
      [ $# -ne 4 ] && { set_usage $@; exit 1;}
      set_env $4
    ;;
    *)
      set_usage
      exit 1
    ;;
    esac
  ;;
  *)
    usage
    exit 1
  ;;
  esac
}

set_env(){
  json=$(echo ${1} | jq -c .)
  curl -X POST \
    --header "Content-Type: application/json" \
    -d $json \
    https://circleci.com/api/v1.1/project/github/${REPO}/envvar?circle-token=${CIRCLECI_TOKEN}
}

# Script entrypoint
main() {
  handle_args $@
}

main "$@"
