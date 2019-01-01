RUN wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz \
  && tar -xvf GeoLite2-Country* \
  && rm -f /usr/local/share/GeoIP/GeoLite2-Country.mmdb \
  && mv GeoLite2-Country*/GeoLite2-Country.mmdb /usr/local/share/GeoIP