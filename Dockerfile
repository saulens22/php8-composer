FROM php:8.0-alpine

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions gd imap zip bcmath soap intl ldap imagick msgpack igbinary \
    redis sqlsrv pdo_sqlsrv pdo_mysql exif calendar @composer