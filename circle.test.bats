load ${BATS_LIBS}/bats-support/load.bash
load ${BATS_LIBS}/bats-assert/load.bash

setup() {
  echo 'setup'
}

teardown() {
  echo 'teardown'
}

testee='circle.sh'

@test "${testee} => Should output a top-level usage message when no arguments are given" {
  run bash -c "./circle.sh"

  assert_failure
  assert_output --partial "[set] options"
}

@test "${testee} => Should output a subfunction-specific usage message when a function is specified but no arguments are given" {
  run bash -c "./circle.sh set"

  assert_failure
  assert_output --partial "set [env] repo json"
}
