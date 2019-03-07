# Terraform poc - S3 notifications

Download and install [Terraform](https://www.terraform.io/downloads.html)

### Dev

```
$ terraform init
```

#### Make a plan
```
$ terraform plan -out ./dist/terraform-plan
```
or
```
$ terraform plan -var 'admin_phone_number=+46YOUR-PHONE-NUMBER' -var 's3_bucket_name=bucket-name' -var 'aws_profile=your-aws-profile' -out ./dist/terraform-plan
```

#### Deploy plan
```
$ terraform apply -auto-approve ./dist/terraform-plan
```

#### Test it!
Test file upload
```
$ ./scripts/test_notification.sh bucket-name your-aws-profile
```

If you upload a .json or a .log file to the S3 bucket and you should be notified.

If you choose to upload a .json file, the `lambda` function will run or if you upload a .log file you get the full event through `SNS` as a text message.

This is controlled by filter_suffix property in S3 bucket notification which is set to ".log" and ".json".
