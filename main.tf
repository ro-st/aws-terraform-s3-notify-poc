provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

data "aws_caller_identity" "current" {}

resource "null_resource" "bootstrap" {
  provisioner "local-exec" {
    command     = "mkdir -p ./dist/"
    interpreter = ["sh", "-c"]
  }
}

data "archive_file" "log_lambda" {
  type        = "zip"
  source_dir  = "src/log-created"
  output_path = "${var.log_lambda_output}"
}

data "aws_iam_policy_document" "lambda_log_assume_role_policy" {
  statement {
      effect = "Allow"
      actions = ["sts:AssumeRole"]
      principals = {
          type = "Service"
          identifiers = ["lambda.amazonaws.com"]
      }
  }
}

data "aws_iam_policy_document" "lambda_log_policy_document" {
  statement {
      effect = "Allow"
      actions = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "sns:*"
      ]
      resources = ["*"]
  }
}

resource "aws_iam_role" "lambda_log_role" {
  name = "role_for_log_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_log_assume_role_policy.json}"
}

resource "aws_iam_role_policy" "lambda_log_role_policy" {
  name = "${var.log_lambda_name}_role_policy"
  role = "${aws_iam_role.lambda_log_role.id}"
  policy = "${data.aws_iam_policy_document.lambda_log_policy_document.json}"
}


resource "aws_lambda_function" "lambda_log" {
  filename = "${var.log_lambda_output}"
  function_name = "${var.log_lambda_name}"
  source_code_hash = "${data.archive_file.log_lambda.output_base64sha256}"
  role = "${aws_iam_role.lambda_log_role.arn}"
  handler = "lambda.handler"
  runtime = "nodejs8.10"
  environment {
      variables = {
          AWS_ADMIN_PHONE_NUMBER="${var.admin_phone_number}"
      }
  }
}


resource "aws_lambda_permission" "allow_log_bucket_exec" {
  statement_id = "AllowExecutionFromS3LogBucket"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_log.arn}"
  principal = "s3.amazonaws.com"
  source_arn = "${aws_s3_bucket.bucket.arn}"
}

resource "aws_sns_topic" "topic" {
  name = "${var.sns_topic_name}"
  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {"AWS":"*"},
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"arn:aws:s3:*:*:${aws_s3_bucket.bucket.id}"}
        }
    }]
}
POLICY
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.s3_bucket_name}"
  force_destroy = true
}

resource "aws_s3_bucket_notification" "bucket_log_created" {
  bucket = "${aws_s3_bucket.bucket.id}"

  topic {
    topic_arn     = "${aws_sns_topic.topic.arn}"
    events        = ["s3:ObjectCreated:*"]
    # filter_prefix = "${var.s3_bucket_log_dir}"
    filter_suffix = ".log"
  }

  lambda_function {
      lambda_function_arn = "${aws_lambda_function.lambda_log.arn}"
      events = ["s3:ObjectCreated:*"]
    #   filter_prefix = "${var.s3_bucket_log_dir}"
      filter_suffix = ".json"
  }
}

resource "aws_sns_topic_subscription" "sns_sub_admin" {
  topic_arn = "${aws_sns_topic.topic.arn}"
  protocol  = "sms"
  endpoint  = "${var.admin_phone_number}"
}
