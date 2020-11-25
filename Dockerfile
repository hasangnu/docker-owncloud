FROM php:7.4-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
		bzip2 \
		gnupg dirmngr \
		libcurl4-openssl-dev \
		libfreetype6-dev \
		libicu-dev \
		libjpeg-dev \
		libldap2-dev \
		libmemcached-dev \
		libpng-dev \
		libpq-dev \
		libxml2-dev \
        libzip-dev \
		unzip \
	&& rm -rf /var/lib/apt/lists/*

# https://doc.owncloud.org/server/8.1/admin_manual/installation/source_installation.html#prerequisites
RUN set -ex; \
	docker-php-ext-configure gd --with-jpeg=/usr; \
	debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
	docker-php-ext-configure ldap --with-libdir="lib/$debMultiarch"; \
	docker-php-ext-install -j "$(nproc)" \
		exif \
		gd \
		intl \
		ldap \
		opcache \
		pcntl \
		pdo_mysql \
		pdo_pgsql \
		pgsql \
		zip

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
RUN a2enmod rewrite

# PECL extensions
RUN set -ex; \
	pecl install apcu; \
	pecl install memcached; \
	pecl install redis; \
	docker-php-ext-enable \
		apcu \
		memcached \
		redis

ENV OWNCLOUD_VERSION 10.5.0
VOLUME /var/www/html

RUN set -eux; \
	curl -fL -o owncloud.tar.bz2 "https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2"; \
	tar -xjf owncloud.tar.bz2 -C /usr/src/; \
	rm owncloud.tar.bz2

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
