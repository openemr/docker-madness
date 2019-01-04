FROM launcher.gcr.io/google/debian9:latest

ARG DEBIAN_FRONTEND=noninteractive

######
###### Install Prerequisites ######
######

RUN apt update && apt install -y apt-transport-https git ca-certificates software-properties-common wget sudo gnupg

RUN rm -f /etc/apt/sources.list \
  && echo "deb https://deb.debian.org/debian stretch main" > /etc/apt/sources.list \
  && echo "deb https://deb.debian.org/debian stretch-updates main" >> /etc/apt/sources.list \
  && echo "deb https://deb.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

RUN wget -q https://packages.sury.org/php/apt.gpg -O- |  apt-key add - \
  && echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list

RUN apt-get update && apt --no-install-recommends -y install \
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
    iputils-ping \
    net-tools \
    python-pip \
    python3 \
    libapache2-mod-security2 \
     php7.2 apache2-dev apache2  php7.2-bcmath \
     wget build-essential \
     libapache2-mod-evasive php7.2-bz2 php7.2-cli php7.2-common \
     php7.2-curl php7.2-dba php7.2-enchant php7.2-fpm php7.2-gd php7.2-gmp php7.2-imap \
     php7.2-interbase php7.2-intl php7.2-json php7.2-ldap php7.2-mbstring php7.2-mysql php7.2-odbc php7.2-opcache \
     php7.2-phpdbg php7.2-pspell php7.2-readline php7.2-recode php7.2-soap php7.2-tidy php7.2-xml php7.2-xsl php7.2-zip \
     php-redis php-igbinary php7.2-mysql golang-go perl tar curl nodejs mysql-client python python-pip imagemagick libapache2-mod-php7.2 git composer vim gcc \
     && apt-get upgrade -y \
     && apt autoremove \
     && apt-get autoclean \
     && rm -rf /var/lib/apt/lists/*


#####
###### Security ######
######

### Apache Mods
RUN a2enmod ssl rewrite evasive headers proxy allowmethods socache_dbm security2

### Clone Config Files
RUN cd /root \
  && git clone https://github.com/openemr/docker-madness

### Cron Jobs
#@todo download this all from a separate secure-server-general repo
RUN chmod 770 /root/docker-madness/helper-files/helper-scripts/cron-scripts/*.sh \
  && mv /root/docker-madness/helper-files/helper-scripts/cron-scripts/*.sh /etc/cron.daily \
    && cd /root \
    && rm -rf docker-madness

### Set up ModSecurity CRS OWASP Rules
# Download new rules
RUN mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf \
  && rm -rf /usr/share/modsecurity-crs \
  && git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/share/modsecurity-crs \
  && mv /usr/share/modsecurity-crs/crs-setup.conf.example /usr/share/modsecurity-crs/crs-setup.conf
# Edit module config file to include new rules
RUN sed -i '/load/ i   IncludeOptional /usr/share/modsecurity-crs/*.conf' /etc/apache2/mods-available/security2.conf \
  && sed -i '/load/ i   IncludeOptional /usr/share/modsecurity-crs/rules/*.conf' /etc/apache2/mods-available/security2.conf \
  && sed -i '/load/d' /etc/apache2/mods-available/security2.conf
# Edit paranoia level and begin blocking
RUN sed -i 's/setvar:tx.paranoia_level=1/setvar:tx.paranoia_level=2/g' /usr/share/modsecurity-crs/crs-setup.conf \
  && sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/g' /etc/modsecurity/modsecurity.conf

### ModEvasive

### IP Blacklisting
RUN wget https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt \
  && httxt2dbm -i ipsum.txt -o ipsum.dbm \
  && chmod 444 ipsum.dbm \
  && rm -f ipsum.txt
RUN rm -f /etc/apache/ipsum.dbm \
  && mv ipsum.dbm /etc/apache2/ipsum.dbm

### Postfix

###  DNS?

######
###### Install OpenEMR ######
######

RUN cd /root && git clone https://github.com/openemr/docker-madness
RUN chmod 770 /root/docker-madness/helper-files/helper-scripts/debian9.sh && ./root/docker-madness/helper-files/helper-scripts/debian9.sh

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80 443