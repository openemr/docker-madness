######
###### Begin ######
######

### Repos 
#add-apt-repository ppa:ondrej/php


update && apt-get install apt-transport-https software-properties-common -y
add-apt-repository ppa:maxmind/ppa
apt-get -y install \
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
    lua5.2-dev
apt-get install php7.2 npm apache2-dev apache2  php7.2-bcmath libmaxminddb0 libmaxminddb-dev mmdb-bin wget geoipupdate build-essential libapache2-mod-evasive php7.2-bz2 php7.2-cgi php7.2-cli php7.2-common php7.2-curl php7.2-dba php7.2-enchant php7.2-fpm php7.2-gd php7.2-gmp php7.2-imap php7.2-interbase php7.2-intl php7.2-json php7.2-ldap php7.2-mbstring php7.2-mysql php7.2-odbc php7.2-opcache php7.2-phpdbg php7.2-pspell php7.2-readline php7.2-recode php7.2-snmp php7.2-soap php7.2-tidy php7.2-xml php7.2-xsl php7.2-zip php-redis php-igbinary php7.2-mysql perl tar curl nodejs mysql-client python python-pip imagemagick libapache2-mod-php7.2 git composer vim gcc -y 

### Composer and NPM Install
git clone https://github.com/danehrlich1/openemr.git
rm -rf openemr/.git
cd openemr 
composer install 
npm install --unsafe-perm 
npm run build 
composer global require phing/phing 
composer global require phing/phing 
#/root/.composer/vendor/bin/phing vendor-clean \
#/root/.composer/vendor/bin/phing assets-clean \
composer global remove phing/phing 
composer dump-autoload -o 
composer clearcache 
npm cache clear --force 
rm -fr node_modules 
cd ../ 
mv openemr /var/www/ 
chown -R www-data /var/www/openemr/
chmod 666 /var/www/openemr/sites/default/sqlconf.php
chmod 666 /var/www/openemr/interface/modules/zend_modules/config/application.config.php

### SSL
#git clone https://github.com/letsencrypt/letsencrypt /opt/certbot 
#pip install -e /opt/certbot/acme -e /opt/certbot 
openssl req -x509 -newkey rsa:4096 \
-keyout /etc/ssl/private/selfsigned.key.pem \
-out /etc/ssl/certs/selfsigned.cert.pem \
-days 1065 -nodes \
-subj "/C=xx/ST=x/L=x/O=x/OU=x/CN=localhost"

### Apache Config Files
rm -rf /var/www/html
rm -f /etc/apache2/apache2.conf
rm -f /etc/apache2/conf-enabled/security.conf
rm -f /etc/apache2/sites-enabled/000-default.conf
cp /var/www/openemr/config/linux/ubuntu/apache/apache2.conf /etc/apache2/
cp /var/www/openemr/config/linux/ubuntu/apache/openemr.conf /etc/apache2/sites-enabled
cp /var/www/openemr/config/linux/ubuntu/apache/security.conf /etc/apache2/conf-enabled

### Load Apache Modules
#ln -s /etc/apache2/mods-available/socache_smcb.load /etc/apache2/mods-avaibled/socache_smcb.load 
#ln -s /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/ssl.conf
#ln -s ssl.load /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/ssl.load
#ln -s /etc/apache2/mods-available/rewrite.conf /etc/apache2/mods-enabled/rewrite.conf
a2enmod rewrite ssl socache_smcb evasive headers proxy allowmethods

### More File Permissions
echo "Default file permissions and ownership set, allowing writing to specific directories"
cd /var/www/openemr
chmod 600 interface/modules/zend_modules/config/application.config.php
find sites/default/documents -type d -print0 | xargs -0 chmod 700
find sites/default/edi -type d -print0 | xargs -0 chmod 700
find sites/default/era -type d -print0 | xargs -0 chmod 700
find sites/default/letter_templates -type d -print0 | xargs -0 chmod 700
find interface/main/calendar/modules/PostCalendar/pntemplates/cache -type d -print0 | xargs -0 chmod 700
find interface/main/calendar/modules/PostCalendar/pntemplates/compiled -type d -print0 | xargs -0 chmod 700
find gacl/admin/templates_c -type d -print0 | xargs -0 chmod 700

### Script Removal
#echo "Removing remaining setup scripts"
#remove all setup scripts
#rm -f admin.php
#rm -f acl_setup.php
#rm -f acl_upgrade.php
#rm -f setup.php
#rm -f sql_patch.php
#rm -f sql_upgrade.php
#rm -f ippf_upgrade.php
#rm -f gacl/setup.php
#echo "Setup scripts removed, we should be ready to go now!"
rm -rf /var/www/config/linux

######
###### Security ######
######

### ModSecurity

### Get ModSecurity Prerequisites


### Get Modsecurity V3 and Build
cd /opt && \
    git clone -b v3/master https://github.com/SpiderLabs/ModSecurity
cd /opt/ModSecurity && \
    sh build.sh && \
    git submodule init && \
    git submodule update && \
    ./configure && \
    make && \
    make install
ln -s /usr/sbin/apache2 /usr/sbin/httpd
 
### Get Apache Connector    
cd /opt && \
    git clone https://github.com/SpiderLabs/ModSecurity-apache
cd /opt/ModSecurity-apache/ && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

### Load Module
mkdir -p /etc/apache2/modsecurity.d/ && \
    echo "LoadModule security3_module \"$(find /opt/ModSecurity-apache/ -name mod_security3.so)\"" > /etc/apache2/mods-enabled/security.conf && \
    echo "modsecurity_rules 'SecRuleEngine On'" >> /etc/apache2/mods-enabled/security.conf && \
    echo "modsecurity_rules_file '/etc/apache2/modsecurity.d/include.conf'" >> /etc/apache2/mods-enabled/security.conf

### Get OWASP Rules
cd /etc/apache2/modsecurity.d/  && \
    mv /opt/ModSecurity/modsecurity.conf-recommended /etc/apache2/modsecurity.d/modsecurity.conf && \
    echo include modsecurity.conf >> /etc/apache2/modsecurity.d/include.conf && \
    git clone https://github.com/SpiderLabs/owasp-modsecurity-crs owasp-crs && \
    mv /etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf.example /etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf && \
    echo include owasp-crs/crs-setup.conf >> /etc/apache2/modsecurity.d/include.conf && \
    echo include owasp-crs/rules/\*.conf >> /etc/apache2/modsecurity.d/include.conf
    cp /opt/ModSecurity/unicode.mapping /etc/apache2/modsecurity.d/


### MAXMIND
# Program to update database
# Edit apache.conf to allow maxmind and set <if> block
wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz
tar -xvf GeoLite2-Country*
mkdir /usr/local/share/GeoIP
mv GeoLite2-Country*/GeoLite2-Country.mmdb /usr/local/share/GeoIP

wget https://github.com/maxmind/mod_maxminddb/releases/download/1.1.0/mod_maxminddb-1.1.0.tar.gz
tar -xvf mod_maxminddb-1.1.0.tar.gz
cd mod_maxminddb-1.1.0
./configure
make install
# Configure GeoIP update https://dev.maxmind.com/geoip/geoipupdate/


### Final Edits
source /etc/apache2/envvars
httpd -t
sed -ie 's/setvar:tx.paranoia_level=1/setvar:tx.paranoia_level=2/g' /etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf
# remove additional hash signs for paranoia level
sed -ie 's/SecRuleEngine DetectionOnly/SecRuleEngine On/g' /etc/apache2/modsecurity.d/modsecurity.conf
source /etc/apache2/envvars
#apache2ctl -k start

### ModEvasive

### Fail2Ban

### UFW

#sudo ufw allow ‘Apache Full’
#sudo ufw allow ssh
#sudo ufw limit ssh
#— no-install-recommends && rm -rf /var/lib/apt/lists/*
### SSH Config
