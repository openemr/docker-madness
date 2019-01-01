FROM local/gcp/openemr-secure/base

ARG DEBIAN_FRONTEND=noninteractive

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

### MAXMIND
# Edit apache.conf to allow maxmind and set <if> block
RUN wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz \
  && tar -xvf GeoLite2-Country* && mkdir /usr/local/share/GeoIP \
  && mv GeoLite2-Country*/GeoLite2-Country.mmdb /usr/local/share/GeoIP \
  && wget https://github.com/maxmind/mod_maxminddb/releases/download/1.1.0/mod_maxminddb-1.1.0.tar.gz \
  && tar -xvf mod_maxminddb-1.1.0.tar.gz \
  && cd mod_maxminddb-1.1.0 \
  && ./configure \
  && make -i install

### ModEvasive
#1. uncomment
#    DOSPageCount 2
#    DOSSiteCount 50
#    DOSPageInterval 1
#    DOSSiteInterval 1
#    DOSBlockingPeriod 60

### IP Blacklisting
RUN wget https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt \
  && httxt2dbm -i ipsum.txt -o ipsum.dbm \
  && chmod 444 ipsum.dbm \
  && rm -f ipsum.txt
RUN rm -f /etc/apache/ipsum.dbm \
  && mv ipsum.dbm /etc/apache2/ipsum.dbm

### Start Server
RUN service apache2 start
EXPOSE 80 443
