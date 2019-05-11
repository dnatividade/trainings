#Libera acesso ICMP request e reply (ping e pong) entre as subredes
iptables -A FORWARD -i $IF_LAN1 -o $IF_LAN2 -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -i $IF_LAN1 -o $IF_LAN2 -p icmp --icmp-type 0 -j ACCEPT
iptables -A FORWARD -i $IF_LAN2 -o $IF_LAN1 -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -i $IF_LAN2 -o $IF_LAN1 -p icmp --icmp-type 0 -j ACCEPT

#Libera acesso a porta 1111/TCP para a rede local
iptables -A FORWARD -i $IF_LAN2 -o $IF_LAN1 -d 192.168.1.100 -p tcp --dport 1111 -j ACCEPT

#Libera acesso a porta 80/TCP para um IP da rede local
iptables -A FORWARD -i $IF_LAN2 -o $IF_LAN1 -s 172.16.20.200 -d 192.168.1.100 -p tcp --dport 80 -j ACCEPT
