FROM php:8.0-alpine

ENV DEBIAN_FRONTEND noninteractive
ENV ACCEPT_EULA=Y

RUN apt-get update \
    && apt-get install -y gnupg gosu curl ca-certificates zip unzip git \
       zlib1g-dev libpng-dev libc-client-dev libkrb5-dev libzip-dev libxml2-dev libldb-dev libldap2-dev libmagickwand-dev \
    && mkdir -p ~/.gnupg \
    && chmod 600 ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && docker-php-source extract \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install gd imap zip bcmath soap intl ldap \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && apt-get install -y msodbcsql17 unixodbc-dev mssql-tools \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc \
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
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && apt purge -y zlib1g-dev libpng-dev libc-client-dev libkrb5-dev libzip-dev libxml2-dev libldb-dev libldap2-dev libmagickwand-dev \
    && apt-get -y autoremove \
    && apt-get clean \
    && docker-php-source delete \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-enable sqlsrv pdo_sqlsrv
