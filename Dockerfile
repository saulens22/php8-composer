FROM php:8.0-alpine

ARG MSSQL_VERSION=17.7.1.1-1
ENV MSSQL_VERSION=${MSSQL_VERSION}
ENV ACCEPT_EULA=Y

WORKDIR /tmp

RUN apk add --no-cache gnupg curl openssl-dev ca-certificates zip unzip git \
        gcc make g++ unixodbc-dev \
       	zlib-dev imap-dev krb5-dev libpng-dev libzip-dev libxml2-dev icu-dev openldap-dev imagemagick-dev autoconf --virtual .build-dependencies -- \
    && docker-php-source extract \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install gd imap zip bcmath soap intl ldap \
    && curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_${MSSQL_VERSION}_amd64.apk \
    && curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_${MSSQL_VERSION}_amd64.apk \
    && apk add --allow-untrusted msodbcsql17_${MSSQL_VERSION}_amd64.apk \
    && apk add --allow-untrusted mssql-tools_${MSSQL_VERSION}_amd64.apk \
    && pecl channel-update pecl.php.net \
    # install imagick
    # use github version for now until release from https://pecl.php.net/get/imagick is ready for PHP 8
    && mkdir -p /usr/src/php/ext/imagick \
    && curl -fsSL https://github.com/Imagick/imagick/archive/06116aa24b76edaf6b1693198f79e6c295eda8a9.tar.gz | tar xvz -C "/usr/src/php/ext/imagick" --strip 1 \
    && docker-php-ext-install imagick \
    && pecl install msgpack \
    && pecl install igbinary \
    && pecl install redis \
    && pecl install sqlsrv-5.9.0 \
    && pecl install pdo_sqlsrv-5.9.0 \
    && docker-php-ext-enable msgpack igbinary redis sqlsrv pdo_sqlsrv \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && docker-php-source delete \
    && apk del gcc make g++ unixodbc-dev \
       zlib-dev imap-dev krb5-dev libpng-dev libzip-dev libxml2-dev icu-dev openldap-dev imagemagick-dev autoconf .build-dependencies \
    && rm -rf /tmp/* /var/tmp/*