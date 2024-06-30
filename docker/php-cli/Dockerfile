# https://chris-vermeulen.comdocker build . --target composer_base/laravel-in-kubernetes-part-2/
# https://www.cloudsigma.com/deploy-a-php-application-on-a-kubernetes-cluster-with-ubuntu-18-04/
# https://medium.com/@agungdarmanto/how-to-run-a-laravel-application-into-kubernetes-a6d0111dc98d
# https://www.xelon.ch/en/knowledge-base/deploy-laravel-app-using-kubernetes
# https://madewithlove.com/blog/software-engineering/the-easiest-production-ready-image-to-run-your-laravel-application/
# Create args for PHP extensions and PECL packages we need to install.
# This makes it easier if we want to install packages,
# as we have to install them in multiple places.
# This helps keep ou Dockerfiles DRY -> https://bit.ly/dry-code
# You can see a list of required extensions for Laravel here: https://laravel.com/docs/8.x/deployment#server-requirements
ARG PHP_EXTS="bcmath ctype fileinfo mbstring pdo mysqli pdo_mysql  dom pcntl exif opcache bz2 intl zip pgsql  pdo_pgsql"
ARG PHP_PECL_EXTS="redis"
ARG PHPIZE_DEPS="libpq-dev icu-dev zlib-dev  postgresql-dev  libzip-dev freetype-dev libwebp-dev  libjpeg-turbo-dev  libpng-dev libmcrypt-dev libxml2-dev ca-certificates postgresql-dev oniguruma-dev libzip-dev libxpm-dev bzip2-dev "

ARG PHP_VER
# ----------------------------------------------------------------------------------------------------------------------
# Target Composer Base
# ----------------------------------------------------------------------------------------------------------------------

# We need to build the Composer base to reuse packages we've installed
FROM php:${PHP_VER} as cli


# We need to declare that we want to use the args in this build step
ARG PHP_EXTS
ARG PHP_PECL_EXTS
ARG PHPIZE_DEPS

# First, create the application directory, and some auxilary directories for scripts and such
RUN mkdir -p /opt/application /opt/bin


# Next, set our working directory
WORKDIR /opt/application


RUN apk update  \
    && apk add --no-cache  ${PHPIZE_DEPS} \
    && apk add --no-cache --virtual build-dependencies \
            procps  \
            shadow  \
            libzip \
            libpng \
            libjpeg-turbo  \
            libwebp \
            freetype  \
            icu  \
            libtool  \
            gd  \
            icu-libs  \
            g++  \
            make \
            openssl \
            automake  \
            autoconf \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install   ${PHP_EXTS} \
    && pecl install ${PHP_PECL_EXTS} \
    && docker-php-ext-enable ${PHP_PECL_EXTS} \
    && apk del build-dependencies \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \