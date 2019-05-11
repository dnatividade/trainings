#Libera acesso ICMP request e reply (ping e pong)
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT

#Libera acesso a porta 22/TCP para todos
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

#Libera acesso a porta 53/UDP somente para as subredes especificadas
iptables -A INPUT -p udp --dport 53 -s 172.16.0.0/16 -j ACCEPT

#Libera acesso a porta 80/TCP somente para IP, MAC e interface especificados
iptables -A INPUT -p tcp --dport 80 -s 172.16.20.200 -m mac --mac-source 00:12:34:0A:BC:DE -i enp0s3 -j ACCEPT
