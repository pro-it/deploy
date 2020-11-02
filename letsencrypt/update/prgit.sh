#!/bin/sh

/usr/bin/certbot certonly \
    --standalone \
    --email info@prgit.by \
    --renew-by-default \
    --rsa-key-size 4096 \
    -d demo.prgit.by \
    --pre-hook 'systemctl stop nginx' \
    --post-hook 'systemctl start nginx'
