FROM php:7.4-apache

# Copy source code to /var/www/html
COPY ./html /var/www/html

# Necessary for Laravel or Symfony
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Ensure permissions are correctly set
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

EXPOSE 80

