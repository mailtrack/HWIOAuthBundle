FROM ubuntu:14.04

# Prepares repositories 
RUN \
    apt-get update && \
    apt-get install -qy --force-yes acl ssh curl apt-transport-https vim git && \
    DISTRO="$(lsb_release -s -c)" && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
    echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu $DISTRO main" > /etc/apt/sources.list.d/ondrej-php.list && \
    apt-get update

# Install php and other dependencies
RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    locale-gen en_US.UTF-8 && \
    apt-get install -qy --force-yes unzip php5.6-cli php5.6-curl php5.6-mysql php5.6-apcu php5.6-sqlite php5.6-imap php5.6-intl php5.6-mcrypt php5.6-readline php5.6-dom php5.6-mbstring && \
    update-alternatives --set php /usr/bin/php5.6 && \
    apt-get autoremove -y && \
    apt-get purge -y libphp7.0-embed php-apcu-bc php7.0-cli php7.0-common php7.0-json php7.0-opcache php7.0-readline && \
    apt-get clean

# Install and configure composer
RUN \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer global require phpunit/phpunit

# Configure environment
ENV PATH=/root/.composer/vendor/bin:$PATH

RUN mkdir /src
ADD composer.json /src

WORKDIR /src
RUN composer install
ADD . /src
ENTRYPOINT ["phpunit"]
#CMD ["-c tests/"]