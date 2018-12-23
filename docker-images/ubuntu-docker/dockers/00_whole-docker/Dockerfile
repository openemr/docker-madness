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
     && rm -rf /var/lib/apt/lists/*


######
###### Build OpenEMR ######
######
RUN git clone https://github.com/danehrlich1/openemr.git
WORKDIR /openemr/config/linux/ubuntu/ubuntu-docker
RUN chmod 770 ./ubuntu1804.sh && ./ubuntu1804.sh


#####
###### Security ######
######

### ModSecurity

### Get Modsecurity V3 and Build
RUN cd /opt && \
    git clone -b v3/master https://github.com/SpiderLabs/ModSecurity
RUN cd /opt/ModSecurity && \
    sh build.sh && \
    git submodule init && \
    git submodule update && \
    ./configure && \
    make && \
    make install
RUN ln -s /usr/sbin/apache2 /usr/sbin/httpd

### Get Apache Connector
RUN cd /opt && \
    git clone https://github.com/SpiderLabs/ModSecurity-apache
RUN cd /opt/ModSecurity-apache/ && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

### Load Module
RUN mkdir -p /etc/apache2/modsecurity.d/ && \
    echo "LoadModule security3_module \"$(find /opt/ModSecurity-apache/ -name mod_security3.so)\"" > /etc/apache2/mods-enabled/security.conf && \
    echo "modsecurity_rules 'SecRuleEngine On'" >> /etc/apache2/mods-enabled/security.conf && \
    echo "modsecurity_rules_file '/etc/apache2/modsecurity.d/include.conf'" >> /etc/apache2/mods-enabled/security.conf

### Get OWASP Rules
RUN cd /etc/apache2/modsecurity.d/ \
    && mv /opt/ModSecurity/modsecurity.conf-recommended /etc/apache2/modsecurity.d/modsecurity.conf \
    && echo include modsecurity.conf >> /etc/apache2/modsecurity.d/include.conf \
    && git clone https://github.com/SpiderLabs/owasp-modsecurity-crs owasp-crs \
    && mv /etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf.example /etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf \
    && echo include owasp-crs/crs-setup.conf >> /etc/apache2/modsecurity.d/include.conf \
    && echo include owasp-crs/rules/\*.conf >> /etc/apache2/modsecurity.d/include.conf \
    && cp /opt/ModSecurity/unicode.mapping /etc/apache2/modsecurity.d/

### MAXMIND
# Edit apache.conf to allow maxmind and set <if> block
RUN wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz \
  && tar -xvf GeoLite2-Country* && mkdir /usr/local/share/GeoIP \
  && mv GeoLite2-Country*/GeoLite2-Country.mmdb /usr/local/share/GeoIP \
  && wget https://github.com/maxmind/mod_maxminddb/releases/download/1.1.0/mod_maxminddb-1.1.0.tar.gz \
  && tar -xvf mod_maxminddb-1.1.0.tar.gz \
  && cd mod_maxminddb-1.1.0 \
  && ./configure \
  && make install

### Final Edits
RUN sed -ie 's/setvar:tx.paranoia_level=1/setvar:tx.paranoia_level=2/g' /etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf && \
  sed -ie 's/SecRuleEngine DetectionOnly/SecRuleEngine On/g' /etc/apache2/modsecurity.d/modsecurity.conf

### ModEvasive

### IP Blacklisting

#— no-install-recommends
RUN service apache2 start
EXPOSE 80 443


