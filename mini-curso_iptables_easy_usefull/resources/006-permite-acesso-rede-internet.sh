#Libera acesso ao ICMP request e reply (ping e pong) para a Internet
iptables -A FORWARD -o $IF_WAN -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -o $IF_WAN -p icmp --icmp-type 0 -j ACCEPT

#Libera acesso a porta 80/TCP e 443/TCP para a Internet
iptables -A FORWARD -o $IF_WAN -p tcp --dport 80  -j ACCEPT
iptables -A FORWARD -o $IF_WAN -p tcp --dport 80  -j ACCEPT
iptables -A FORWARD -o $IF_WAN -p tcp --dport 443 -j ACCEPT
iptables -A FORWARD -o $IF_WAN -p tcp --dport 443 -j ACCEPT
