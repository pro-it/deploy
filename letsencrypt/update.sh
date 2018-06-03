#!/bin/sh

/home/proit/letsencrypt/certbot/certbot-auto certonly --standalone --email info@hackerspace.by --renew-by-default --rsa-key-size 4096 -d xn--h1alcem.xn--90ais -d www.xn--h1alcem.xn--90ais -d xn--80ae7bed.xn--h1alcem.xn--90ais -d xn--d1aifp.xn--h1alcem.xn--90ais -d xn--80a0bn.xn--h1alcem.xn--90ais -d xn--c1ad6a.xn--h1alcem.xn--90ais -d xn--b1aksep.xn--h1alcem.xn--90ais -d xn--b1aksep4d.xn--h1alcem.xn--90ais --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx"
