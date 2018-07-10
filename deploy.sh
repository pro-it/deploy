#!/bin/sh

DOMAIN_NAMES="${DOMAIN_NAMES:=proit prgit}"

PROIT_USER='proit'
PROIT_DIR="/home/$PROIT_USER"
PROIT_TMP_DIR="$PROIT_DIR/tmp"

SITE_BRANCH='master'
SITE_DIR="$PROIT_DIR/site"
SITE_URL="https://codeload.github.com/pro-it/site/tar.gz/$SITE_BRANCH"

DEPLOY_BRANCH='master'
DEPLOY_URL="https://codeload.github.com/pro-it/deploy/tar.gz/$DEPLOY_BRANCH"

FEE_DIR="$PROIT_DIR/fee"
FEE_BRANCH='master'
FEE_URL="https://codeload.github.com/pro-it/fee/tar.gz/$FEE_BRANCH"

#NGINX_APT_FILE='/etc/apt/sources.list.d/nginx.list'
NGINX_ETC_DIR='/etc/nginx'
NGINX_DIR="$PROIT_DIR/nginx"
NGINX_LOGS_DIR="$NGINX_DIR/logs"
NGINX_CONFIGS_DIR="$NGINX_DIR/configs"

LETSENCRYPT_DIR="$PROIT_DIR/letsencrypt"
LETSENCRYPT_BRANCH='master'
LETSENCRYPT_URL="https://codeload.github.com/certbot/certbot/tar.gz/$LETSENCRYPT_BRANCH"

SSL_DIR="$PROIT_DIR/ssl"
SSL_TICKET_KEY_DIR="$SSL_DIR/ticket"
SSL_TICKET_KEY_FILE_EXT=".key"
SSL_TICKET_KEY_BIT_SIZE=80
SSL_DHPARAM_DIR="$SSL_DIR/dhparam"
SSL_DHPARAM_FILE_EXT=".pem"
SSL_DHPARAM_BIT_SIZE=4096


#
structure_define()
{
    echo "Structure building..." && \

    mkdir -p "$PROIT_TMP_DIR" && \
    mkdir -p "$SITE_DIR" && \
    mkdir -p "$SSL_DIR" && \
    mkdir -p "$NGINX_DIR" && \
    mkdir -p "$LETSENCRYPT_DIR"
}

#
structure_remove()
{
    rm -rf "$PROIT_TMP_DIR" && \
    rm -rf "$FEE_DIR" && \
    rm -rf "$SITE_DIR" && \
    rm -rf "$SSL_DIR" && \
    rm -rf "$NGINX_DIR" && \
    rm -rf "$LETSENCRYPT_DIR"
}

#
deploy_download()
{
    echo "Deploy source downloading..."

    cd "$PROIT_TMP_DIR" && curl -SL "$DEPLOY_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "Some errors with deploy source downloading for '$DEPLOY_URL'" && \
        structure_remove

        exit 1
    fi
}

# DHParam
openssl_dhparam_define()
{
    mkdir -p "$SSL_DHPARAM_DIR" && \
    (for d in $DOMAIN_NAMES; do
        openssl dhparam -out "$SSL_TICKET_KEY_DIR/$d$SSL_DHPARAM_FILE_EXT" "$SSL_DHPARAM_BIT_SIZE"
    done)
}

# SSL Ticket key generate
openssl_ticket_key_define()
{
    mkdir -p "$SSL_TICKET_KEY_DIR" && \
    (for d in $DOMAIN_NAMES; do
        openssl rand "$SSL_TICKET_KEY_BIT_SIZE" > "$SSL_TICKET_KEY_DIR/$d$SSL_TICKET_KEY_FILE_EXT"
    done)
}

# SSL
ssl_define()
{
    openssl_ticket_key_define && \
    openssl_dhparam_define
}

#
nginx_define()
{
    local b_name=''
#    sudo rm -f "$NGINX_APT_FILE" && \
#    sudo touch "$NGINX_APT_FILE" && \
#    sudo echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> "$NGINX_APT_FILE" && \
#    sudo echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> "$NGINX_APT_FILE" && \
#    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \
#    sudo apt-get update -y && sudo apt-get install -y nginx && sudo apt-get autoclean -y

    for f in $(ls "$NGINX_CONFIGS_DIR/"); do
        echo "$f" && \

        sudo ln -sf "$NGINX_CONFIGS_DIR/$f" "$NGINX_ETC_DIR/conf.d" && \

        b_name="$(basename "$f" .conf)"

        if [ "$b_name" != "$f" ]; then
            mkdir -p "$NGINX_LOGS_DIR/$b_name"
        fi
    done
}

#
letsencrypt_define()
{
    echo "Let's Encrypt source downloading..."

    cd "$LETSENCRYPT_DIR" && curl -SL "$LETSENCRYPT_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "Some errors with deploy source downloading for '$DEPLOY_URL'" && \
        structure_remove

        exit 1
    fi

    mv "$LETSENCRYPT_DIR/certbot-$LETSENCRYPT_BRANCH" "$LETSENCRYPT_DIR/certbot"
}

#
deploy_define()
{
    local deploy_dir="$PROIT_TMP_DIR/deploy-$DEPLOY_BRANCH/"

    mv "$deploy_dir/letsencrypt" "$PROIT_DIR/" && \
    mv "$deploy_dir/nginx" "$PROIT_DIR/" && \
    rm -rf "$deploy_dir/" && \

    ssl_define && \
    nginx_define && \
    letsencrypt_define
}

#
fee_download()
{
    echo "Fee source downloading..."

    cd "$PROIT_TMP_DIR" && curl -SL "$FEE_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "Some errors with fee source downloading for '$FEE_URL'" && \
        structure_remove

        exit 1
    fi
}

#
fee_define()
{
    mv "$PROIT_TMP_DIR/fee-$FEE_BRANCH" "$FEE_DIR/"

    sudo apt-get install -y libxml2-dev libxslt1-dev python3-pip && \
    pip3 install $(cat $FEE_DIR/requires.txt)
}

#
site_download()
{
    echo "Site source downloading..."

    cd "$PROIT_TMP_DIR" && curl -SL "$SITE_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "Some errors with deploy source downloading for '$DEPLOY_URL'" && \
        structure_remove

        exit 1
    fi
}

#
site_define()
{
    local site_dir="$PROIT_TMP_DIR/site-$SITE_BRANCH/"

    for f in $(ls "$site_dir/"); do
        mv "$site_dir/$f" "$SITE_DIR/"
    done

    rm -rf "$site_dir/"
}

#
deploy()
{
    structure_remove && \
    structure_define && \

    fee_download && \
    fee_define && \

    deploy_download && \
    deploy_define && \

    site_download && \
    site_define && \

    rm -rf "$PROIT_TMP_DIR"
}


# Run
deploy
