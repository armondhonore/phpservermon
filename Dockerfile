FROM php:8.2-apache
RUN apt-get update && apt-get install -y zip unzip git \
    && docker-php-ext-install pdo pdo_mysql \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer create-project phpservermon/phpservermon /var/www/html --no-interaction \
    && chown -R www-data:www-data /var/www/html
EXPOSE 80
