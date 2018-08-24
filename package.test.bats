load ${BATS_LIBS}/bats-support/load.bash
load ${BATS_LIBS}/bats-assert/load.bash

setup() {
  echo 'setup'
}

teardown() {
  echo 'teardown'
}

testee='package.sh'

@test "${testee} => Should output a top-level usage message when no arguments are given" {
  run bash -c "./package.sh"

  assert_failure
  assert_output --partial "path-to-package.json"
}

@test "${testee} => Should fail if bad path given for package.json" {
  badfilepath='/fake/path/that/doesnt/exist.json'
  run bash -c "./package.sh /fake/path/that/doesnt/exist.json"

  assert_failure
  assert_output --partial "Unable to find file '${badfilepath}'"
}

@test "${testee} => Should fail if BUILD_NUM is not set in the environment" {
  run bash -c "./package.sh ./fixtures/valid-package.json"

  assert_failure
  assert_output --partial "BUILD_NUM is not set in the environment"
}

@test "${testee} => Should fail if package.json is missing the 'name' key" {
  run bash -c "BUILD_NUM='testing' ./package.sh ./fixtures/invalid-package-missing-name.json"

  assert_failure
  assert_output --partial "The key 'name' was not found in './fixtures/invalid-package-missing-name.json'"
}

@test "${testee} => Should fail if package.json is missing the 'version' key" {
  run bash -c "BUILD_NUM='testing' ./package.sh ./fixtures/invalid-package-missing-version.json"

  assert_failure
  assert_output --partial "The key 'version' was not found in './fixtures/invalid-package-missing-version.json'"
}

@test "${testee} => Should fail if package.json is missing the 'homepage' key" {
  run bash -c "BUILD_NUM='testing' ./package.sh ./fixtures/invalid-package-missing-homepage.json"

  assert_failure
  assert_output --partial "The key 'homepage' was not found in './fixtures/invalid-package-missing-homepage.json'"
}

@test "${testee} => Should fail if package.json is missing the 'author' key" {
  run bash -c "BUILD_NUM='testing' ./package.sh ./fixtures/invalid-package-missing-author.json"

  assert_failure
  assert_output --partial "The key 'author' was not found in './fixtures/invalid-package-missing-author.json'"
}

@test "${testee} => Should fail if package.json is missing the 'description' key" {
  run bash -c "BUILD_NUM='testing' ./package.sh ./fixtures/invalid-package-missing-description.json"

  assert_failure
  assert_output --partial "The key 'description' was not found in './fixtures/invalid-package-missing-description.json'"
}

@test "${testee} => Should fail if package.json is missing the 'repository' key" {
  run bash -c "BUILD_NUM='testing' ./package.sh ./fixtures/invalid-package-missing-repository.json"

  assert_failure
  assert_output --partial "The key 'repository' was not found in './fixtures/invalid-package-missing-repository.json'"
}

@test "${testee} => Should fail if package.json is missing the 'files' key" {
  run bash -c "BUILD_NUM='testing' ./package.sh ./fixtures/invalid-package-missing-files.json"

  assert_failure
  assert_output --partial "The key 'files' was not found in './fixtures/invalid-package-missing-files.json'"
}
