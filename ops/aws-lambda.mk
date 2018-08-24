aws_lambda_package::
	zip -r9 ${APP_NAME}.zip .

deps:: common_terraform_binary common_jq_binary common_aws_cli

aws_lambda_deploy::
	-${TEMP_DIR}/terraform import aws_iam_role.app_role ${APP_NAME}_role
	-${TEMP_DIR}/terraform import aws_lambda_function.app_function ${APP_NAME}_function
	${TEMP_DIR}/terraform init
	${TEMP_DIR}/terraform apply

aws_lambda_clean::
	-rm -f ${APP_NAME}.zip
	-rm -rf ${TEMP_DIR}
