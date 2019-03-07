output "s3_bucket_name" {
  value = "${aws_s3_bucket.bucket.bucket_domain_name}"
}

output "s3_bucket_log_dir" {
    value = "${var.s3_bucket_log_dir}"
}

output "admin_phone_number" {
  value = "${aws_sns_topic_subscription.sns_sub_admin.endpoint}"
}

output "log_created_lambda_arn" {
  value = "${aws_lambda_function.lambda_log.arn}"
}
