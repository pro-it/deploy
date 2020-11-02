#!/bin/sh

/usr/bin/certbot certonly \
    --standalone \
    --email info@xn--h1alcem.xn--90ais \
    --renew-by-default \
    --rsa-key-size 4096 \
    -d xn--d1acvi.xn--h1alcem.xn--90ais \
    --pre-hook 'systemctl stop nginx' \
    --post-hook 'systemctl start nginx'
