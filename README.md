# Common Operations Code - ci pipeline, artifacts, and more! (eventually) [![CircleCI](https://circleci.com/gh/jonathanporta/ops/tree/master.svg?style=svg)](https://circleci.com/gh/jonathanporta/ops/tree/master)
Collection of ops-related code for use across projects

# Use in project

## First time adding
We'll use a git subtree because I heard it's a good idea.

`$ git remote add ops git@github.com:jonathanporta/ops.git --no-tags`

`$ git subtree add --prefix ops/ ops master --squash`

## Pull in updates
When this repo changes you will need to update the contents in any repos relying on this code.

`$ git subtree pull --prefix ops/ ops master --squash`

# Development
## Testing
This repo uses bats tests to ensure that the scripts run as expected.

You can run the tests: `make test`

### Bats Resources
- http://blog.spike.cx/post/60548255435/testing-bash-scripts-with-bats
- https://github.com/ztombol/bats-docs
- https://medium.com/@pimterry/testing-your-shell-scripts-with-bats-abfca9bdc5b9

# Upcoming
- Move stuff in gists over to here
- Improve testing of scripts - mock files, etc.
- Build default set of Makefiles that can be extended
- Build new project pipeline utility - setups a new repo with these tools, configures CI, integrates Slack, brews coffee.
