FROM php:7.2.26-apache

MAINTAINER Antonio Sanna <atsanna@tiscali.it>

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install --fix-missing -y libpq-dev
RUN apt-get install --no-install-recommends -y libpq-dev
RUN apt-get install -y libxml2-dev libbz2-dev zlib1g-dev
RUN apt-get -y install libsqlite3-dev libsqlite3-0 mariadb-client curl exif ftp
RUN docker-php-ext-install intl
RUN apt-get -y install --fix-missing zip unzip

# Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer
RUN composer self-update

ADD conf/apache.conf /etc/apache2/sites-available/000-default.conf

ADD startScript.sh /startScript.sh
RUN chmod +x /startScript.sh

RUN cd /var/www/html

RUN composer create-project codeigniter4/appstarter codeigniter4 v4.0.2
RUN chmod -R 0777 /var/www/html/codeigniter4/writable

RUN mv /var/www/html/codeigniter4 /var/tmp/ 

RUN apt-get clean \
    && rm -r /var/lib/apt/lists/*
    
EXPOSE 80
VOLUME ["/var/www/html", "/var/log/apache2", "/etc/apache2"]

CMD ["bash", "/startScript.sh"]

