#Faz o NAT com mascaramento para rede local
iptables -t nat -A POSTROUTING -o $IF_WAN -j MASQUERADE
