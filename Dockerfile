FROM mirror.gcr.io/library/php:7.4-apache

# phpservermon 3.5.x targets symfony ~3.4 (PHP 7.x). PHP 7.4 is the last release that
# runs that dependency tree cleanly — on PHP 8.x composer create-project fails (exit 2).
RUN apt-get update && apt-get install -y --no-install-recommends \
        zip unzip git libicu-dev libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" pdo pdo_mysql intl gd xml \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /var/lib/apt/lists/*

# Install phpservermon into a clean temp dir, then move it into the Apache docroot.
RUN composer create-project phpservermon/phpservermon /opt/psm "3.5.*" \
        --no-interaction --no-dev --prefer-dist --ignore-platform-reqs \
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