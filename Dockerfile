FROM mirror.gcr.io/library/php:8.2-apache

# System deps + PHP extensions phpservermon needs (pdo_mysql, intl, gd for graphs).
RUN apt-get update && apt-get install -y --no-install-recommends \
        zip unzip git libicu-dev libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" pdo pdo_mysql intl gd \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /var/lib/apt/lists/*

# Install phpservermon into a clean temp dir, then move it into the Apache docroot.
# (composer create-project refuses to populate an existing/non-empty docroot, and a
#  bare `COPY . /var/www/html` only copies repo metadata — both left the docroot
#  empty -> Apache 403 on / and 404 on index.php.)
RUN composer create-project phpservermon/phpservermon /opt/psm \
        --no-interaction --no-dev --prefer-dist \
    && rm -rf /var/www/html \
    && mv /opt/psm /var/www/html \
    && chown -R www-data:www-data /var/www/html

# Apache: serve index.php, allow .htaccess overrides, enable rewrite.
RUN a2enmod rewrite \
    && printf '<Directory /var/www/html>\n    Options -Indexes +FollowSymLinks\n    AllowOverride All\n    Require all granted\n    DirectoryIndex index.php index.html\n</Directory>\n' \
        > /etc/apache2/conf-available/psm.conf \
    && a2enconf psm

# Entrypoint generates config.php from env vars on first boot, then starts Apache.
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
