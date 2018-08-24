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
  echo_red "Usage: $0 [parse|name-value|name-value-tuple-stream] .envpath"
}

handle_args(){
  # Handle wrong number of  args being passed.
  [ $# -ne 2 ] && { usage $@; exit 1;}

  env_file=${2}

  case "$1" in
  'parse')
    env_json=$(parse_env)
    export_json
  ;;
  'name-value')
    env_key_value_json=$(parse_env_key_value)
    export_key_value_json
  ;;
  'name-value-tuple-stream')
    parse_env_key_value_stream
  ;;
  *)
    usage
    exit 1
  ;;
  esac
}

parse_env(){
  source ${env_file}
  env_json="{}"

  while read l; do
    name=$(echo $l | grep -Po '(?<=export ).+(?=\=)')
    if [ $name ]; then
      value=$(eval echo \$${name})
      env_json=$(echo $env_json | jq ".+={\"${name}\":\"${value}\"}")
    fi
  done <${env_file}

  echo $env_json
}

parse_env_key_value(){
  source ${env_file}
  env_key_value_json="[]"

  while read l; do
    name=$(echo $l | grep -Po '(?<=export ).+(?=\=)')
    if [ $name ]; then
      value=$(eval echo \$${name})
      env_key_value_json=$(echo $env_key_value_json | jq ".+=[{\"name\":\"${name}\", \"value\":\"${value}\"}]")
    fi
  done <${env_file}

  echo $env_key_value_json
}

parse_env_key_value_stream(){
  source ${env_file}

  while read l; do
    name=$(echo $l | grep -Po '(?<=export ).+(?=\=)')
    if [ $name ]; then
      value=$(eval echo \$${name})
      output=$(echo "{\"name\":\"${name}\", \"value\":\"${value}\"}" | tr -d '[:space:]')
      echo "'${output}'"
    fi
  done <${env_file}
}

export_json(){
  echo $env_json | jq -c .
}

export_key_value_json(){
  echo $env_key_value_json | jq -c .
}

# Script entrypoint
main() {
  handle_args $@
}

main "$@"
