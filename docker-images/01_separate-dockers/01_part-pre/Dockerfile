FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive

######
###### Install Prerequisites ######
######

RUN apt-get update && apt install apt-transport-https git software-properties-common -y
RUN add-apt-repository ppa:maxmind/ppa
RUN apt-get --no-install-recommends -y install \
    libtool \
    dh-autoreconf \
    pkgconf \
    libcurl4-gnutls-dev \
    libxml2 \
    libpcre++-dev \
    libxml2-dev \
    libgeoip-dev \
    libyajl-dev \
    liblmdb-dev \
    ssdeep \
    lua5.2-dev \
    ufw \
    iputils-ping \
    net-tools \
    python-pip \
    python3.6 \
    python2.7 \
     php7.2 npm apache2-dev apache2  php7.2-bcmath libmaxminddb0 \
     libmaxminddb-dev mmdb-bin wget geoipupdate build-essential \
     libapache2-mod-evasive php7.2-bz2 php7.2-cli php7.2-common \
     php7.2-curl php7.2-dba php7.2-enchant php7.2-fpm php7.2-gd php7.2-gmp php7.2-imap \
     php7.2-interbase php7.2-intl php7.2-json php7.2-ldap php7.2-mbstring php7.2-mysql php7.2-odbc php7.2-opcache \
     php7.2-phpdbg php7.2-pspell php7.2-readline php7.2-recode php7.2-soap php7.2-tidy php7.2-xml php7.2-xsl php7.2-zip \
     php-redis php-igbinary php7.2-mysql golang-go perl tar curl nodejs mysql-client python python-pip imagemagick libapache2-mod-php7.2 git composer vim gcc \
     && apt-get upgrade -y \
     && apt autoremove \
     && apt-get autoclean \
     && rm -rf /var/lib/apt/lists/*
