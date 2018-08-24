provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# IAM Role for Lambda function
resource "aws_iam_role" "app_role" {
  name = "${var.app_name}_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "sts:AssumeRole"
      ],
      "Sid": "",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "app_role_policy" {
  name = "${var.app_name}_role_policy"
  role = "${aws_iam_role.app_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

# AWS Lambda function
resource "aws_lambda_function" "app_function" {
  filename         = "${var.app_name}.zip"
  function_name    = "${var.app_name}_function"
  role             = "${aws_iam_role.app_role.arn}"
  handler          = "${var.function_handler}"
  runtime          = "${var.function_runtime}"
  timeout          = 300
  source_code_hash = "${base64sha256(file("${var.app_name}.zip"))}"

  # environment {
  #   variables = {}
  # }
}

#
# Configuration for triggering a function to run on a schedule.
#
# # Setup an event to trigger the lambafunction
# resource "aws_cloudwatch_event_rule" "app_event_rule" {
#   name                = "${var.app_name}_event_rule"
#   description         = "Invoke ${aws_lambda_function.app_function.arn} every 5 mins"
#   schedule_expression = "rate(5 minutes)"
# }
#
# # Set the lambda's ARN as the target of the event
# resource "aws_cloudwatch_event_target" "app_target" {
#   rule = "${aws_cloudwatch_event_rule.app_event_rule.id}"
#   arn  = "${aws_lambda_function.app_function.arn}"
# }
#
# resource "aws_lambda_permission" "app_function_allow_cloud_watch" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = "${aws_lambda_function.app_function.function_name}"
#   principal     = "events.amazonaws.com"
#   source_arn    = "${aws_cloudwatch_event_rule.app_event_rule.arn}"
# }

