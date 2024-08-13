# Use an official PHP-Apache image as a parent image
FROM php:7.4-apache

# Install required PHP extensions
RUN docker-php-ext-install mysqli

# Copy the HTML and PHP files to the Apache server directory
COPY index.html /var/www/html/index.html
COPY manage.php /var/www/html/manage.php
COPY submit-data.php /var/www/html/submit-data.php

# Set proper ownership and permissions for the files
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80 to the outside world
EXPOSE 80

# Start Apache server in the foreground
CMD ["apache2-foreground"]

