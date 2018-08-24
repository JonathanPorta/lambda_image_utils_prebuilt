include ops/common.mk
include ./ops/pip.mk

deps:: common_jq_binary
	pyvenv-3.6 env
	./env/bin/pip install -r requirements.txt --no-cache-dir

build: clean deps build_container
	docker cp build-container:/var/task/ ./build
	cd ./build && zip -r9 ../deps.zip *

build_container: clean_container
	docker build -t jonathanporta/lambda_image_utils_prebuilt .
	docker run --name build-container jonathanporta/lambda_image_utils_prebuilt:latest

clean: clean_container
	@-rm -rf ./dist ./env ./*.egg-info ./tmp ./build
	@-rm -f ./deps.zip

clean_container:
	@-docker rm build-container

shell: build_container
	@-docker rm build-container
	docker run --rm -it jonathanporta/lambda_image_utils_prebuilt:latest bash

package: pip_package

release: aws_lambda_deploy pip_release
