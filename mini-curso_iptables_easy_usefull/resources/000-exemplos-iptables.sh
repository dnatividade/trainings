#Allow 22/TCP port to local firewall: 
iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT

#Allow 3389/TCP/UDP port to server into the network:
iptables -A FORWARD --dport 3389 -j ACCEPT

#Allow "ping" from network to Internet
iptables -A FORWARD -p icmp --icmp-type 0 -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type 8 -j ACCEPT

#Deny 1000-3000/TCP port to a specific network
iptables -A FORWARD -d 10.0.0.0/8 -m multiport --dport 1000:3000 -j DROP

