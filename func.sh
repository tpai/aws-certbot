#!/bin/bash

function check_if_aws_exist
{
    if ! which aws &> /dev/null; then
        curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
        unzip awscli-bundle.zip
        sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    fi
}

function configure_aws_cli
{
    echo "> Login to AWS..."
    printf "${AWS_ACCESS_KEY_ID}\n${AWS_SECRET_ACCESS_KEY}\n${AWS_DEFAULT_REGION}\n${AWS_OUTPUT_FORMAT}\n" | aws configure --profile ${AWS_PROFILE_NAME}
    aws ecr get-login --no-include-email --profile ${AWS_PROFILE_NAME} | $(sed 's/\-e none //g') || exit 1
    echo "> Login success"
}

function check_if_jq_exist
{
    if ! which jq &> /dev/null; then
        echo "> Installing jq..."
        if [ "$(uname)" == "Darwin" ]; then
            brew install jq
        elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
            wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
            chmod +x ./jq
            cp jq /usr/local/bin
        fi
        echo "> jq installed"
    fi
}

function check_if_bucket_exists
{
    aws s3api head-bucket --bucket $1
    if [ $? -ne 0 ]; then
        create_bucket $1
    fi
}

function create_bucket
{
    echo "> Create S3 $1 bucket..."
    aws s3api create-bucket --acl public-read --bucket $1 --create-bucket-configuration "LocationConstraint=ap-southeast-1"
    echo "> Bucket created"
}

function delete_bucket
{
    echo "> Delete S3 $1 bucket..."
    aws s3 rb s3://$1 --force
    echo "> Bucket deleted"
}

function enable_website_host
{
    echo "> Enable website host..."
    aws s3 website s3://"$1"/ --index-document index.html
    echo "> Setting enabled"
}

function put_object
{
    echo "> Put validation object to bucket..."
    aws s3api put-object --acl public-read --bucket $1 --key $2 --body $3
    echo "> Object created"
}

function change_record
{
    aws route53 change-resource-record-sets --hosted-zone-id $1 --change-batch $(jq -c -n "{
        \"Changes\": [{
            \"Action\": \"$2\",
            \"ResourceRecordSet\": {
                \"Name\": \"$3\",
                \"Type\": \"CNAME\",
                \"TTL\": 60,
                \"ResourceRecords\": [{
                    \"Value\": \"$4.s3-website-$5.amazonaws.com\"
                }]
            }
        }]
    }")
}
