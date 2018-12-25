#@IgnoreInspection BashAddShebang

## IP Blacklist for Apache - 24
# consider switch to a map file
wget https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt \
  && httxt2dbm -i ipsum.txt -o ipsum.dbm \
  && chmod 444 ipsum.dbm
  && rm -f ipsum.txt
rm -f /etc/apache/ipsum.dbm \
  && mv ipsum.dbm /etc/apache2/ipsum.txt

## IP Blacklist for IPTables - 24
# --cap-add=NET_ADMIN in Docker Run
# consider using https://github.com/trick77/ipset-blacklist
ipset -q flush ipsum
ipset -q create ipsum hash:net
for ip in $(curl --compressed https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt 2>/dev/null | grep -v "#" | grep -v -E "\s[1-2]$" | cut -f 1); do ipset add ipsum $ip; done
iptables -I INPUT -m set --match-set ipsum src -j DROP

# GeoIPUpdate
RUN wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz \
  && tar -xvf GeoLite2-Country* \
  && rm -f /usr/local/share/GeoIP/GeoLite2-Country.mmdb \
  && mv GeoLite2-Country*/GeoLite2-Country.mmdb /usr/local/share/GeoIP \

# Apt-Get Upgrade
apt update && apt upgrade -y