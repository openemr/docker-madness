#--cap-add=NET_ADMIN

wget https://raw.githubusercontent.com/stamparm/ipsum/master/levels/3.txt
wget https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset
pip install netaddr && chmod +x python-cidr.py && chmod +x ./iptables-blacklist-update.sh
python2.7 python-cidr.py firehol_level1.netset > personal-blacklist-custom.txt
cat 3.txt >> personal-blacklist-custom.txt
./iptables-blacklist-update.sh


