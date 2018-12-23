#!/usr/bin/env bash

_input='personal-blacklist-custom.txt'
IPT=iptables
$IPT -N droplist
while IFS= read -r ip
do
        $IPT -A droplist -i eth1 -s $ip -j LOG --log-prefix " myBad IP BlockList  "
        $IPT -A droplist -i eth1 -s $ip -j DROP
done < "$_input"
# Drop it
$IPT -I INPUT -j droplist
$IPT -I OUTPUT -j droplist
$IPT -I FORWARD -j droplist
