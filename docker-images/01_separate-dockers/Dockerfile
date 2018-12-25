FROM 3986668bc623

ARG DEBIAN_FRONTEND=noninteractive

#####
###### Security ######
######



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



#— no-install-recommends
RUN service apache2 start
EXPOSE 80 443
