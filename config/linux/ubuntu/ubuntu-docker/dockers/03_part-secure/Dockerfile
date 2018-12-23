FROM danora/openemr-secure:emr

ARG DEBIAN_FRONTEND=noninteractive

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
