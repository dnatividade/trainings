#Libera acesso na interface de localhost (lo)
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#libera acesso as conexoes ja estabelecidas e relatadas
iptables -A INPUT   -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT  -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
