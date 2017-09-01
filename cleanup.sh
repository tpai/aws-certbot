#!/bin/bash

source .env
source func.sh

check_if_aws_exist
configure_aws_cli
check_if_jq_exist

source def.sh

delete_bucket $S3_BUCKET
change_record $ROUTE53_ZONE_ID \
    DELETE $ROUTE53_TARGET_DOMAIN $S3_BUCKET $AWS_DEFAULT_REGION

check_if_bucket_exists $CERT_S3_BUCKET
