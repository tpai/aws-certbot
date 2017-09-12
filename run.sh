#!/bin/bash

source .env
source func.sh

DOMAINS=(${1//,/ })
LENGTH=$(echo ${#DOMAINS[@]}-1 | bc)
for ((i=$LENGTH; i>=0; i--)); do
    if [ $i -eq 0 ]; then
        FIRST_DOMAIN=${DOMAINS[$i]}
    fi
    TARGETS="-d ${DOMAINS[$i]} $TARGETS"
done

sudo certbot certonly --manual \
    --preferred-challenges http \
    --email $EMAIL \
    --agree-tos \
    --manual-public-ip-logging-ok \
    --manual-auth-hook ./auth.sh \
    --manual-cleanup-hook ./cleanup.sh \
    --renew-by-default \
    --expand \
    --debug \
    --staging \
    $TARGETS || exit 1

sudo cp -r /etc/letsencrypt/live/$FIRST_DOMAIN cert

IFS=',' read -a FILE <<< "privkey.pem,fullchain.pem,chain.pem,cert.pem"
for i in "${FILE[@]}"; do
    put_object $CERT_S3_BUCKET "$FIRST_DOMAIN/$i" "./cert/$i"
done

sudo rm -rf cert
