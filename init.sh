#!/bin/bash

# tail -f /dev/null

ip rule add fwmark 1 lookup 100
ip route add local 0.0.0.0/0 dev lo table 100

iptables -t mangle -N DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT

iptables -t mangle -N GOST
iptables -t mangle -A GOST -p tcp -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A GOST -p tcp -d 10.112.0.0/16 -j RETURN
iptables -t mangle -A GOST -p tcp -m mark --mark 100 -j RETURN 
iptables -t mangle -A GOST -p tcp -j TPROXY --tproxy-mark 0x1/0x1 --on-ip 127.0.0.1 --on-port 12345 
iptables -t mangle -A PREROUTING -p tcp -j GOST

iptables -t mangle -N GOST_LOCAL
iptables -t mangle -A GOST_LOCAL -p tcp -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A GOST_LOCAL -p tcp -d 255.255.255.255/32 -j RETURN
iptables -t mangle -A GOST_LOCAL -p tcp -d 10.112.0.0/16 -j RETURN
iptables -t mangle -A GOST_LOCAL -p tcp -m mark --mark 100 -j RETURN 
iptables -t mangle -A GOST_LOCAL -p tcp -j MARK --set-mark 1
iptables -t mangle -A OUTPUT -p tcp -j GOST_LOCAL

/root/gost/cmd/gost/gost -L "red://:12345?sniffing=true&tproxy=true" -F "http://gateway-service:1080?so_mark=100"
