#Faz DNAT para um IP da rede local
iptables -t nat -A PREROUTING -i $IF_WAN  -p tcp --dport 8888 -j DNAT --to 192.168.1.100:7777
iptables -t nat -A PREROUTING -i $IF_LAN2 -p tcp --dport 8888 -j DNAT --to 192.168.1.100:7777

#Libera acesso a porta 7777/TCP para o IP da regra acima
iptables -A FORWARD -d 192.168.1.100 -p tcp --dport 7777 -j ACCEPT

