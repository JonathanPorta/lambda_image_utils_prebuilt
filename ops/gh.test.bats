load ${BATS_LIBS}/bats-support/load.bash
load ${BATS_LIBS}/bats-assert/load.bash

setup() {
  echo 'setup'
}

teardown() {
  echo 'teardown'
}

testee='gh.sh'

@test "${testee} => Should output a top-level usage message when no arguments are given" {
  run bash -c "./gh.sh"

  assert_failure
  assert_output --partial "[latest|create|upload|delete] Username/MyRepo tag_name"
}

@test "${testee} => Should output a latest usage message when no arguments given" {
  run bash -c "./gh.sh latest"

  assert_failure
  assert_output --partial "latest Username/MyRepo"
}

@test "${testee} => Should output a usage message scoped to the 'create' command" {
  run bash -c "./gh.sh create"

  assert_failure
  assert_output --partial "create Username/MyRepo tag_name"
}

@test "${testee} => Should output a usage message scoped to the 'upload' command" {
  run bash -c "./gh.sh upload"

  assert_failure
  assert_output --partial "upload Username/MyRepo tag_name artifact"
}

@test "${testee} => Should output a usage message scoped to the 'delete' command" {
  run bash -c "./gh.sh delete"

  assert_failure
  assert_output --partial "delete Username/MyRepo tag_name"
}
