# AWS Certbot

Shell script for requesting SSL certificate based on Certbot, AWS S3 and Route 53.

## Features

* Reqeust certificate from multiple custom domain which already CNAME to your sub-domain.

## Prerequisites

1. Install [aws-cli](http://docs.aws.amazon.com/cli/latest/userguide/awscli-install-bundle.html#install-bundle-other) and [jq](https://stedolan.github.io/jq/download/)
2. Check the custom domain that must CNAME to your sub-domain.

## Usage

Request certificate from `domain1`, `domain2` and `domain3` are additional names.

```
sh run.sh [domain1],[domain2],[domain3]
```

Delete certificate

```
sh delete.sh [domain1]
```

## Validation Details

Create temporary S3 bucket and DNS record for validation, then clean up after certificates created, upload pem files and private key to specific S3 for storage.

### Variable definiton: def.sh

1. Find out which domain be `CNAME` by custom domain `CERTBOT_DOMAIN`, and assign it to `ROUTE53_TARGET_DOMAIN`.
* Retrieve host zone id by dns name `ROUTE53_TARGET_DOMAIN`.
* Assign `CERTBOT_DOMAIN` to `S3_BUCKET`.
* Define `S3_KEY` to be `.well-known/acme-challenge/$CERTBOT_TOKEN`.

### Prehook: auth.sh

1. Create `S3_BUCKET` and put validation file.
* CNAME `ROUTE53_TARGET_DOMAIN` to s3 bucket endpoint.

### Posthook: cleanup.sh

1. Delete `S3_BUCKET` instantly.
* Delete CNAME record which created at `auth.sh`.
