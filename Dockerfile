# Use the official PHP image as a base
FROM php:7.4-apache

# Install MySQLi extension
RUN docker-php-ext-install mysqli

# Copy application source code to Apache document root
COPY ./html /var/www/html/

# Provide write access to Apache web server
RUN chown -R www-data:www-data /var/www/html

EXPOSE 3000
