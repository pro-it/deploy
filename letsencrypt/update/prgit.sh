#!/bin/sh

/usr/bin/certbot certonly \
    --standalone \
    --email info@prgit.by \
    --renew-by-default \
    --rsa-key-size 4096 \
    -d prgit.by \
    -d charter.prgit.by \
    -d chat.prgit.by \
    -d docs.prgit.by \
    -d fee.prgit.by \
    -d info.prgit.by \
    -d join.prgit.by \
    -d logo.prgit.by \
    -d ppo.prgit.by \
    -d size.fee.prgit.by \
    -d v1.charter.prgit.by \
    -d www.prgit.by \
    --pre-hook 'systemctl stop nginx' \
    --post-hook 'systemctl start nginx'
