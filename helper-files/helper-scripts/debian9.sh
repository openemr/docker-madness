#!/bin/sh
######
###### Begin ######
######

### Composer and NPM Install
git clone https://github.com/openemr/openemr
cd /openemr
composer install
npm install --unsafe-perm
npm run build
#@todo don't run compose as superuser
composer global require phing/phing
composer global require phing/phing 
#/root/.composer/vendor/bin/phing vendor-clean \
#/root/.composer/vendor/bin/phing assets-clean \
composer global remove phing/phing 
composer dump-autoload -o 
composer clearcache 
npm cache clear --force 
rm -fr node_modules 
cd / 
mv openemr /var/www/ 
chown -R www-data /var/www/openemr/
chmod 666 /var/www/openemr/sites/default/sqlconf.php
chmod 666 /var/www/openemr/interface/modules/zend_modules/config/application.config.php

### SSL
#git clone https://github.com/letsencrypt/letsencrypt /opt/certbot 
#pip install -e /opt/certbot/acme -e /opt/certbot
#@todo consider taking care of in main-docker
openssl req -x509 -newkey rsa:4096 \
-keyout /etc/ssl/private/selfsigned.key.pem \
-out /etc/ssl/certs/selfsigned.cert.pem \
-days 1065 -nodes \
-subj "/C=xx/ST=x/L=x/O=x/OU=x/CN=localhost"

### Apache Config Files
#@todo take care of this in the secure-docker file since these apply to more than just OpenEMR
rm -rf /var/www/html
rm -rf /etc/apache2/mods-available/evasive.conf
rm -f /etc/apache2/apache2.conf
rm -f /etc/apache2/conf-enabled/security.conf
rm -f /etc/apache2/sites-enabled/000-default.conf

cp /root/docker-madness/helper-files/config-files/apache/evasive.conf /etc/apache2/mods-available/evasive.conf
cp /root/docker-madness/helper-files/config-files/apache/apache2.conf /etc/apache2/
cp /root/docker-madness/helper-files/config-files/apache/openemr.conf /etc/apache2/sites-enabled
#@todo probably eliminate security.conf and just put in main apache2.conf???
cp /root/docker-madness/helper-files/config-files/apache/security.conf /etc/apache2/conf-enabled
cp /root/docker-madness/helper-files/config-files/GeoIP.conf /usr/local/etc/

### Load Apache Modules
#ln -s /etc/apache2/mods-available/socache_smcb.load /etc/apache2/mods-available/socache_smcb.load
#ln -s /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/ssl.conf
#ln -s ssl.load /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/ssl.load
#ln -s /etc/apache2/mods-available/rewrite.conf /etc/apache2/mods-enabled/rewrite.conf

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
echo "Removing remaining setup scripts"
#remove all setup scripts
rm -f admin.php
rm -f acl_setup.php
rm -f acl_upgrade.php
rm -f setup.php
rm -f sql_patch.php
rm -f sql_upgrade.php
rm -f ippf_upgrade.php
rm -f gacl/setup.php
echo "Setup scripts removed, we should be ready to go now!"