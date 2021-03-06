# AWS Certbot

Shell script for requesting SSL certificate based on Certbot, AWS S3 and Route 53.

## Features

* Reqeust certificate without complex steps.
* Support multiple domain.

## Prerequisites

1. Create one user which has `AmazonS3FullAccess` and `AmazonRoute53FullAccess` policy in IAM.
2. Make sure custom domain CNAME to the target domain which be contained by host zone in Route 53.
3. Fill up fields in `.env`.
4. Comment `--staging` option in `run.sh` for production.

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

1. Find out which domain be `CNAME` by custom domain `CERTBOT_DOMAIN`, and assign to `ROUTE53_TARGET_DOMAIN`.
2. Retrieve host zone id by dns name `ROUTE53_TARGET_DOMAIN`.
3. Assign `CERTBOT_DOMAIN` to `S3_BUCKET`.
4. Define `S3_KEY` to be `.well-known/acme-challenge/$CERTBOT_TOKEN`.

### Prehook: auth.sh

1. Create `S3_BUCKET` and put validation file.
2. CNAME `ROUTE53_TARGET_DOMAIN` to s3 bucket endpoint.

### Posthook: cleanup.sh

1. Delete `S3_BUCKET` instantly.
2. Delete CNAME record which created at `auth.sh`.

## Reference

* [Certbot - Pre and Post Validation Hooks](https://certbot.eff.org/docs/using.html#pre-and-post-validation-hooks)
* [AWS - Hosting a Static Website on Amazon S3](http://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html)
* [CLI to add DNS Records in Route53](https://gist.github.com/justinclayton/0a4df1c85e4aaf6dde52)
* [Hyperpolyglot - JSON Tools: jq](http://hyperpolyglot.org/json)
* [jq - Print strings without quotes](https://github.com/stedolan/jq/issues/250#issuecomment-31070768)
* [Bash for loop examples](https://www.cyberciti.biz/faq/bash-for-loop/)
