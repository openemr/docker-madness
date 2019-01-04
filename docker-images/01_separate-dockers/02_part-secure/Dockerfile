FROM local/gcp/openemr-secure/base

ARG DEBIAN_FRONTEND=noninteractive

#####
###### Security ######
######


### Apache Mods
RUN a2enmod ssl rewrite evasive headers proxy allowmethods socache_dbm security2

### Clone Config Files
RUN cd /root \
  && git clone https://github.com/openemr/docker-madness \
#@todo config files for apache later should be adjusted here

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

#@todo turn off this rule 920350
### IP Blacklisting
RUN wget https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt \
  && httxt2dbm -i ipsum.txt -o ipsum.dbm \
  && chmod 444 ipsum.dbm \
  && rm -f ipsum.txt
RUN rm -f /etc/apache/ipsum.dbm \
  && mv ipsum.dbm /etc/apache2/ipsum.dbm

### ModEvasive

### Postfix Dovecot and SASL

### DNS?

### Start Server
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80 443
