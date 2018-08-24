CI_CONFIG=.circleci/config.yml
CI_CONFIG_TEMPLATE=./ops/templates/ci-config

ci_enable_ci:
ifeq ($(CIRCLECI_TOKEN),)
	@echo "The env variable 'CIRCLECI_TOKEN' is not defined."
else ifeq ($(REPO),)
	@echo "The env variable 'REPO' is not defined."
else
	@echo "Make sure this repo has been created on GitHub and that a commit has been pushed. Hint: use 'hub create'"
	@echo ''
	curl -X POST https://circleci.com/api/v1.1/project/github/${REPO}/follow?circle-token=${CIRCLECI_TOKEN}
endif

ci_generate_ci_config:
ifeq ($(wildcard ${CI_CONFIG}),)
	@echo "${CI_CONFIG} does not exist. Creating..."
	mkdir -p $(shell dirname ${CI_CONFIG})
	cp ${CI_CONFIG_TEMPLATE} ${CI_CONFIG}
else
	@echo "${CI_CONFIG} already exists. Not going to mess with it."
endif

ci_push_secrets:
ifeq ($(CIRCLECI_TOKEN),)
	@echo "The env variable 'CIRCLECI_TOKEN' is not defined."
else ifeq ($(REPO),)
	@echo "The env variable 'REPO' is not defined."
else
	./ops/env-json.sh name-value-tuple-stream ./.env | xargs -i{} ./ops/circle.sh set env ${REPO} {}
endif
