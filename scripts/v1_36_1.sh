#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# MediaWiki installation script 
#   - To be used with a Dockerfile
#   - Written on 2021-06-26
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
set -u # Error on unset variable
set -e # Error on non-zero code
set -o pipefail # Error when pipe failed


# Variables --------------------------------------------------------------------
MEDIAWIKI_MAJOR_VERSION="1.36"
MEDIAWIKI_VERSION="1.36.1"


# Base installation ------------------------------------------------------------
install_base() {
  printf "  [INFO] Running base installation\n"
  apt --yes update > /dev/null 2>&1
  apt --yes upgrade > /dev/null 2>&1
  apt install --yes \
    nginx supervisor curl unzip imagemagick mcrypt \
    php php-common php7.3-fpm php-apcu php-intl php-mbstring php-xml php-pgsql php-zip \
    php-curl php-gd php-memcached php-xml php-json php-dompdf \
    php-phar-io-manifest php-tokenizer > /dev/null 2>&1
  
  printf "  [INFO] Running cleanup\n"
  apt --yes clean > /dev/null 2>&1
  rm -rf /var/lib/apt/lists/*
}


# Prepare for installation; create directories ---------------------------------
create_dirs() {
  printf "  [INFO] Creating important directories\n"
  mkdir -p /etc/nginx
  mkdir -p /var/www/
  mkdir -p /run/nginx
  mkdir -p /var/log/supervisor
  mkdir -p /var/run/php
}


# Installing Mediawiki from tarball --------------------------------------------
install_mediawiki() {
  printf "  [INFO] Installing mediawiki from tarball\n"
  curl -fSL "https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_VERSION}.tar.gz" -o mediawiki.tar.gz && \
    tar -xzf mediawiki.tar.gz && \
    mv mediawiki-${MEDIAWIKI_VERSION} /var/www/mediawiki && \
    rm mediawiki.tar.gz
}


# Main program -----------------------------------------------------------------
install_base
create_dirs
install_mediawiki
