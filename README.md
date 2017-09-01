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
