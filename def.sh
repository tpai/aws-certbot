#!/bin/bash

source .env

ROUTE53_TARGET_DOMAIN=$(dig +noall +answer $CERTBOT_DOMAIN | grep CNAME | head -n1 | awk '{print $5;}')
if [ -z $ROUTE53_TARGET_DOMAIN ]; then
    echo "> Can not find any CNAME record. ($CERTBOT_DOMAIN)"
    exit 1
fi
ROUTE53_MAIN_DOMAIN=$(echo $ROUTE53_TARGET_DOMAIN | awk -F"." '{print $2"."$3;}')
ROUTE53_ZONE_ID=$(aws route53 list-hosted-zones | jq -r 'reduce .HostedZones[] as $i (""; if "'"$ROUTE53_TARGET_DOMAIN"'" | test($i.Name) then . = $i.Id else . end)' | awk -F"/" '{print $3;}')
if [ -z $ROUTE53_ZONE_ID ]; then
    echo "> Can not find host zone by domain. ($ROUTE53_TARGET_DOMAIN)"
    exit 1
fi
S3_BUCKET=$CERTBOT_DOMAIN
S3_KEY=.well-known/acme-challenge/"$CERTBOT_TOKEN"

echo "ROUTE53_TARGET_DOMAIN="$ROUTE53_TARGET_DOMAIN
echo "ROUTE53_MAIN_DOMAIN="$ROUTE53_MAIN_DOMAIN
echo "ROUTE53_ZONE_ID="$ROUTE53_ZONE_ID
echo "S3_BUCKET="$S3_BUCKET
echo "S3_KEY="$S3_KEY
