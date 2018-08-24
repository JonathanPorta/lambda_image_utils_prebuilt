TEMP_DIR=$(shell pwd)/tmp
HEROKU_CLI=$(shell which heroku)

# # Figure out which OS we are running.
# OS="linux"
# ifeq ("$(shell uname)", "Darwin")
# 	OS="darwin"
# endif
#
# heroku_install_cli:
# 	-rm -rf ${TEMP_DIR}/heroku*
# 	-mkdir -p ${TEMP_DIR}
# 	curl https://cli-assets.heroku.com/heroku-cli/channels/stable/heroku-cli-${OS}-x64.tar.gz -o /tmp/heroku.tar.gz
# 	tar -xf /tmp/heroku.tar.gz -C ${TEMP_DIR}/
# 	mv ${TEMP_DIR}/heroku-cli-* ${TEMP_DIR}/heroku-cli

heroku_check_deps:
ifeq ($(APP_NAME),)
	$(error "The env variable 'APP_NAME' is not defined. Normally this is defined in your root Makefile. Please do that or something else that will result in APP_NAME being set before you try this again.")
else ifeq ($(HEROKU_CLI),)
	$(error "The heroku cli is not available in the current PATH or something... Please install it/fix it/whatever... https://devcenter.heroku.com/articles/heroku-cli#download-and-install")
else ifeq ($(HEROKU_API_KEY),)
	$(error "The env variable 'HEROKU_API_KEY' is not defined. Please fix this.")
endif

heroku_setup_project: heroku_check_deps
	heroku auth:whoami ; if [ $$? -neq 0 ] ; then heroku login ; fi
	-heroku create $(APP_NAME)-staging
	-heroku create $(APP_NAME)-production
	-git remote add heroku-staging git@heroku.com:$(APP_NAME)-staging.git
	-git remote add heroku-production git@heroku.com:$(APP_NAME)-production.git

heroku_setup_environment:
	heroku config:set APP_SETTINGS=StagingConfig --remote heroku-staging
	heroku config:set APP_SETTINGS=ProductionConfig --remote heroku-production

heroku_setup_secrets:
	$(error "Please override the 'heroku_setup_secrets' target in your local Makefile..." && exit 1)

heroku_deploy_staging:
	git push heroku-staging master

heroku_deploy_production:
	git push heroku-production master

heroku_migrate_db: heroku_migrate_db_staging heroku_migrate_db_production

heroku_migrate_db_staging:
	heroku run rake db:migrate --remote heroku-staging

heroku_migrate_db_production:
	heroku run rake db:migrate --remote heroku-production
