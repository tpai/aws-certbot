#!/bin/bash

source .env
source func.sh

check_if_aws_exist
configure_aws_cli
check_if_jq_exist

source def.sh

create_bucket $S3_BUCKET
enable_website_host $S3_BUCKET

echo $CERTBOT_VALIDATION > VALIDATION
put_object $S3_BUCKET $S3_KEY VALIDATION
rm -f VALIDATION

change_record $ROUTE53_ZONE_ID \
    CREATE $ROUTE53_TARGET_DOMAIN $S3_BUCKET $AWS_DEFAULT_REGION

sleep 60
