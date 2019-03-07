variable "aws_region" {
  type = "string"
  default = "eu-west-1"
}

variable "aws_profile" {
  type = "string"
  default = "default"
}

variable "s3_bucket_name" {
  type = "string"
}

variable "s3_bucket_log_dir" {
  type = "string"
  default = "logs"
}

variable "sns_topic_name" {
  type = "string"
  default = "s3-event-notification-topic"
}

variable "admin_phone_number" {
  type = "string"
}

variable "log_lambda_output" {
  type = "string"
  default = "dist/lambda-log-created.zip"
}

variable "log_lambda_name" {
  type = "string"
  default = "log-created"
}

