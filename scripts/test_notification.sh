#!/usr/bin/env bash

if [ -z "$1" ]; then exit "need a bucket name!"; fi

bucket_name="$1"
bucket_key="test-logs/"
bucket_path="$bucket_name/$bucket_key"
aws_profile="default"

if [ ! -z "$2" ]; then aws_profile="$2"; fi

project_root_dir="$PWD"
log_test_dir="$PWD/tmp/test-logs"

rm -rf $log_test_dir
mkdir -p $log_test_dir
cd $log_test_dir

echo -e "{\n\t\"testKey\": \"testValue\"\n}" >> test.json && echo "test log entry" >> test.log
aws --profile $aws_profile s3 sync --exclude="*" --include="test.*" . s3://$bucket_path

cd $project_root_dir
