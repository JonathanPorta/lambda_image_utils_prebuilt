load ${BATS_LIBS}/bats-support/load.bash
load ${BATS_LIBS}/bats-assert/load.bash

setup() {
  echo 'setup'
}

teardown() {
  echo 'teardown'
}

testee='env-json.sh'

@test "${testee} => Should output a top-level usage message when no arguments are given" {
  run bash -c "./env-json.sh"

  assert_failure
  assert_output --partial "[parse|name-value|name-value-tuple-stream] .envpath"
}
