# Use the official PHP image with Apache
FROM php:7.4-apache

# Update package list and install necessary packages
RUN apt-get update && \
    apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev libzip-dev zip unzip && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd && \
    docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache mod_rewrite (if needed)
RUN a2enmod rewrite

# Copy the PHP application code into the container
COPY . /var/www/html/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Expose port 80 for HTTP
EXPOSE 80

