#!/bin/sh

PROIT_USER='proit'
PROIT_DIR="/home/$PROIT_USER"
PROIT_TMP_DIR="$PROIT_DIR/tmp"

SITE_BRANCH='master'
SITE_DIR="$PROIT_DIR/site"
SITE_URL="https://github.com/pro-it/site/archive/$SITE_BRANCH.tar.gz"

DEPLOY_BRANCH='master'
DEPLOY_URL="https://github.com/pro-it/deploy/archive/$DEPLOY_BRANCH.tar.gz"

#NGINX_APT_FILE='/etc/apt/sources.list.d/nginx.list'
NGINX_ETC_DIR='/etc/nginx'
NGINX_DIR="$PROIT_DIR/nginx"

LETSENCRYPT_DIR="$PROIT_DIR/letsencrypt"
LETSENCRYPT_BRANCH='master'
LETSENCRYPT_URL="https://github.com/letsencrypt/letsencrypt/archive/$LETSENCRYPT_BRANCH.tar.gz"

PROIT_DHPARAM_KEY_FILE="$LETSENCRYPT_DIR/dhparam.pem"
PROIT_SSL_BIT_KEY_SIZE=4096


structure_define()
{
    echo "Structure building..."

    mkdir -p "$PROIT_TMP_DIR"
    mkdir -p "$SITE_DIR"
    mkdir -p "$NGINX_DIR"
    mkdir -p "$LETSENCRYPT_DIR"
}

structure_remove()
{
    rm -rf "$PROIT_TMP_DIR"
    rm -rf "$SITE_DIR"
    rm -rf "$NGINX_DIR"
    rm -rf "$LETSENCRYPT_DIR"
}

deploy_download()
{
    echo "Deploy source downloading..."

    cd "$PROIT_TMP_DIR" && curl -SL "$DEPLOY_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "Some errors with deploy source downloading for '$DEPLOY_URL'"
        structure_remove

        exit 1
    fi
}

# DHParam
openssl_dhparam_define()
{
    openssl dhparam -out "$PROIT_DHPARAM_KEY_FILE" "$PROIT_SSL_BIT_KEY_SIZE"
}

nginx_define()
{
#    sudo rm -f "$NGINX_APT_FILE" && \
#    sudo touch "$NGINX_APT_FILE" && \
#    sudo echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> "$NGINX_APT_FILE" && \
#    sudo echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> "$NGINX_APT_FILE" && \
#    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \
#    sudo apt-get update -y && sudo apt-get install -y nginx && sudo apt-get autoclean -y

    for f in $(ls "$NGINX_DIR/"); do
        echo "$f"
        sudo ln -sf "$NGINX_DIR/$f" "$NGINX_ETC_DIR/conf.d"
    done

    openssl_dhparam_define
}

letsencrypt_define()
{
    echo "Let's Encrypt source downloading..."

    cd "$LETSENCRYPT_DIR" && curl -SL "$LETSENCRYPT_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "Some errors with deploy source downloading for '$DEPLOY_URL'"
        structure_remove

        exit 1
    fi

    mv "$LETSENCRYPT_DIR/certbot-$LETSENCRYPT_BRANCH" "$LETSENCRYPT_DIR/certbot"
}

deploy_define()
{
    local deploy_dir="$PROIT_TMP_DIR/deploy-$DEPLOY_BRANCH/"

    mv "$deploy_dir/letsencrypt" "$PROIT_DIR/"
    mv "$deploy_dir/nginx" "$PROIT_DIR/"
    rm -rf "$deploy_dir/"

    nginx_define
    letsencrypt_define
}

site_download()
{
    echo "Site source downloading..."

    cd "$PROIT_TMP_DIR" && curl -SL "$SITE_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "Some errors with deploy source downloading for '$DEPLOY_URL'"
        structure_remove

        exit 1
    fi
}

site_define()
{
    local site_dir="$PROIT_TMP_DIR/site-$SITE_BRANCH/"

    for f in $(ls "$site_dir/"); do
        mv "$site_dir/$f" "$SITE_DIR/"
    done

    rm -rf "$site_dir/"
}

deploy()
{
    structure_remove
    structure_define

    deploy_download
    deploy_define

    site_download
    site_define

    rm -rf "$PROIT_TMP_DIR"
}


deploy
