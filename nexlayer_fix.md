# Nexlayer deployment fix — phpservermon (PINNED, authoritative)

## Root cause

phpservermon ships no application source in this repo (only Dockerfile, nexlayer.yaml,
docker-entrypoint.sh). A generated `COPY . /var/www/html/` Dockerfile therefore copies
only repo metadata, leaving the Apache docroot empty — Apache returns **403 on `/`** and
**404 on `index.php`**. The app source must be fetched with `composer create-project`,
which will not populate a non-empty docroot, so it installs into a temp dir that is then
moved into `/var/www/html`. config.php is generated at container start by
docker-entrypoint.sh from the PSM_DB_* environment variables.

This fix is authoritative — do not regenerate the Dockerfile or nexlayer.yaml.

## Fixed Dockerfile

```
FROM mirror.gcr.io/library/php:8.2-apache

# System deps + PHP extensions phpservermon needs (pdo_mysql, intl, gd for graphs).
RUN apt-get update && apt-get install -y --no-install-recommends \
        zip unzip git libicu-dev libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" pdo pdo_mysql intl gd \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /var/lib/apt/lists/*

# Install phpservermon into a clean temp dir, then move it into the Apache docroot.
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
```

## Fixed nexlayer.yaml

```
application:
  name: phpservermon
  pods:
  - name: app
    image: phpservermon-app:latest
    path: /
    servicePorts:
    - 80
    vars:
      PSM_DB_HOST: "mysql.pod"
      PSM_DB_PORT: "3306"
      PSM_DB_NAME: phpservermon
      PSM_DB_USER: phpservermon
      PSM_DB_PASS: phpservermon
  - name: mysql
    image: mysql:8.0
    servicePorts:
    - 3306
    vars:
      MYSQL_DATABASE: phpservermon
      MYSQL_USER: phpservermon
      MYSQL_PASSWORD: phpservermon
      MYSQL_ROOT_PASSWORD: rootpassword
    volumes:
    - name: psm-db
      mountPath: /var/lib/mysql
      size: 5Gi
```
