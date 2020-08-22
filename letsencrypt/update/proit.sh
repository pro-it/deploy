#!/bin/sh

/usr/bin/certbot certonly \
    --standalone \
    --email info@xn--h1alcem.xn--90ais \
    --renew-by-default \
    --rsa-key-size 4096 \
    -d xn--h1alcem.xn--90ais \
    -d www.xn--h1alcem.xn--90ais \
    -d xn--1-ctb.xn--80ae7bed.xn--h1alcem.xn--90ais \
    -d xn--b1aksep.xn--h1alcem.xn--90ais \
    -d xn--h1akdx.xn--h1alcem.xn--90ais \
    -d xn--d1aifp.xn--h1alcem.xn--90ais \
    -d xn--c1apjb.xn--h1alcem.xn--90ais \
    -d xn--n1aba.xn--h1alcem.xn--90ais \
    -d xn--80akfure.xn--b1aksep.xn--h1alcem.xn--90ais \
    -d xn--c1ax.xn--h1alcem.xn--90ais \
    -d xn--e1alh1b.xn--h1alcem.xn--90ais \
    -d xn--80ae7bed.xn--h1alcem.xn--90ais \
    -d xn--80a0bn.xn--h1alcem.xn--90ais \
    --pre-hook 'systemctl stop nginx' \
    --post-hook 'systemctl start nginx'
