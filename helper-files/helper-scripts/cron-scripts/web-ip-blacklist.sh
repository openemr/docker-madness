wget https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt \
  && httxt2dbm -i ipsum.txt -o ipsum.dbm \
  && chmod 444 ipsum.dbm
  && rm -f ipsum.txt
rm -f /etc/apache/ipsum.dbm \
  && mv ipsum.dbm /etc/apache2/ipsum.txt