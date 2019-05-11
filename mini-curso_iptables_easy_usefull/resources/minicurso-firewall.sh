#!/bin/sh

### BEGIN INIT INFO
# Provides:          f2.sh
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      
# Short-Description: Start firewall at boot time
# Description:       Enable service provided by f2.sh.
### END INIT INFO

# Serial: 2019050301 ## Mini-curso ##


####################################################
#Autor:     Diego Natividade #dn@at
#E-mail:    diego@connectivaredes.com
#Github:    /dnatividade
#
#Desc.:     Script de firewall usado no mini-curso
####################################################

#1 ##################################################
#VARIAVEIS
#Interface de Internet
IF_WAN="enp0s3"
#Interface da "Rede Local 1" (192.168.1.0/24)
IF_LAN1="enp0s8"
#Interface da "Rede Local 2" (172.16.0.0/12)
IF_LAN2="enp0s9"

#Limpa regras (-F), 
#exclui cadeias customizadas (-X),
#zera contadores (-Z)
for TABLE in filter nat mangle raw security
do
    iptables -t $TABLE -F
    iptables -t $TABLE -X
    iptables -t $TABLE -Z
done
####################################################

#2 #################################################
#Politica padrao: DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
####################################################

#3 #################################################
#Libera acesso na interface de localhost (lo)
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
#libera acesso as conexoes ja estabelecidas e relatadas
iptables -A INPUT   -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT  -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
####################################################

#4 #################################################
#Libera acesso ICMP request e reply (ping e pong)
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
#Libera acesso a porta 22/TCP para todos
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
#Libera acesso a porta 53/UDP somente para as subredes especificadas
iptables -A INPUT -p udp --dport 53 -s 172.16.0.0/12 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -s 192.168.1.0/24 -j ACCEPT
#Libera acesso a porta 80/TCP somente para IP, MAC e interface especificados
iptables -A INPUT -p tcp --dport 80 -s 172.16.20.200 -m mac --mac-source 00:12:34:0A:BC:DE -i enp0s3 -j ACCEPT
####################################################

#5 #################################################
#Habilita o encaminhamento de pacotes no Kernel do Linux
echo 1 > /proc/sys/net/ipv4/ip_forward
#Faz o NAT com mascaramento para rede local
iptables -t nat -A POSTROUTING -o $IF_WAN -j MASQUERADE
####################################################

#6 #################################################
#Libera acesso ao ICMP request e reply (ping e pong) para a Internet
iptables -A FORWARD -o $IF_WAN -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -o $IF_WAN -p icmp --icmp-type 0 -j ACCEPT
#Libera acesso a porta 80/TCP e 443/TCP para a Internet
iptables -A FORWARD -o $IF_WAN -p tcp --dport 80  -j ACCEPT
iptables -A FORWARD -o $IF_WAN -p tcp --dport 80  -j ACCEPT
iptables -A FORWARD -o $IF_WAN -p tcp --dport 443 -j ACCEPT
iptables -A FORWARD -o $IF_WAN -p tcp --dport 443 -j ACCEPT
####################################################

#7 #################################################
#Libera acesso ICMP request e reply (ping e pong) entre as subredes
iptables -A FORWARD -i $IF_LAN1 -o $IF_LAN2 -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -i $IF_LAN1 -o $IF_LAN2 -p icmp --icmp-type 0 -j ACCEPT
iptables -A FORWARD -i $IF_LAN2 -o $IF_LAN1 -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -i $IF_LAN2 -o $IF_LAN1 -p icmp --icmp-type 0 -j ACCEPT
#Libera acesso a porta 1111/TCP para a rede local
iptables -A FORWARD -i $IF_LAN2 -o $IF_LAN1 -d 192.168.1.100 -p tcp --dport 1111 -j ACCEPT
#Libera acesso a porta 80/TCP para um IP da rede local
iptables -A FORWARD -i $IF_LAN2 -o $IF_LAN1 -s 172.16.20.200 -d 192.168.1.100 -p tcp --dport 80 -j ACCEPT
####################################################

#8 #################################################
#Faz DNAT para um IP da rede local
iptables -t nat -A PREROUTING -i $IF_WAN  -p tcp --dport 8888 -j DNAT --to 192.168.1.100:7777
iptables -t nat -A PREROUTING -i $IF_LAN2 -p tcp --dport 8888 -j DNAT --to 192.168.1.100:7777
#Libera acesso a porta 7777/TCP para o IP da regra acima
iptables -A FORWARD -d 192.168.1.100 -p tcp --dport 7777 -j ACCEPT
####################################################


#dn@at

