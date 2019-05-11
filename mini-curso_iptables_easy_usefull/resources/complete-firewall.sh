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
#Desc.:     Script de firewall completo para estudos
####################################################

### Variaveis ################
#interfaces de rede
IF_WAN=eth0
IF_LAN=eth1
IF_DMZ=eth2

#redes
REDE_LAN=192.168.0.0/24
#REDE_DMZ=10.10.10.0/24

#IPs de servidores
SERVER=192.168.0.11
DVR=192.168.0.21
CONTABIL=192.168.0.22
###

LOGDATA=`date +%d/%m/%Y' '%T`
##############################

### Mensagem de inicialização do Firewall ###
echo "Ativando Regras do Firewall -- #dnatividade"

### Carregando modulos ###
modprobe ip_nat_ftp
modprobe ip_conntrack
modprobe ip_conntrack_ftp
#
modprobe ip_nat_pptp
modprobe pptp


for TABLE in filter nat mangle raw security
do
      iptables -t $TABLE -F #Exclui todas as regras
      iptables -t $TABLE -X #Exclui cadeias customizadas
      iptables -t $TABLE -Z #Zera os contadores das cadeias
done
####################################################

### Define a política padrão do firewall
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
####################################################

#
##
###
### Regras PREROUTING -- Redirecionamento de portas ###
iptables -t nat -A PREROUTING -i $IF_WAN -p tcp --dport 5541 -j DNAT --to $SERVER
iptables -t nat -A PREROUTING -i $IF_WAN -p tcp --dport 9000 -j DNAT --to $DVR

#
##
###
### Regras INPUT ###
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT

#
##
###
### Regras FORWARD ###
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

#da interface "IF_LAN" para "IF_WAN"
iptables -A FORWARD -i $IF_LAN -p icmp --icmp-type 0 -j ACCEPT #Ping
iptables -A FORWARD -i $IF_LAN -p icmp --icmp-type 8 -j ACCEPT #Ping
###
iptables -A FORWARD -i $IF_LAN -m mac --mac-source 01:23:45:AA:BB:CC -p tcp --dport 80  -j ACCEPT #libera MAC para acessar porta 80/TCP
iptables -A FORWARD -i $IF_LAN -m mac --mac-source 01:23:45:AA:BB:CC -p tcp --dport 443 -j ACCEPT #libera MAC para acessar porta 443/TCP
###
iptables -A FORWARD -i $IF_LAN -s $SERVER -p tcp --dport 80   -j ACCEPT #Libera IP do servidor para acessar porta 80/TCP
iptables -A FORWARD -i $IF_LAN -s $SERVER -p tcp --dport 443  -j ACCEPT #Libera IP do servidor para acessar porta 443/TCP
iptables -A FORWARD -i $IF_LAN -s $SERVER -p udp --dport 5000 -j ACCEPT #ACCEPT #Libera IP do servidor para acessar porta 5000/UDP
###
iptables -A FORWARD -i $IF_LAN -p tcp --dport 22 -j ACCEPT #Libera todos da rede para acessar porta 22/TCP
iptables -A FORWARD -i $IF_LAN -p tcp --dport 21 -j ACCEPT #Libera todos da rede para acessar porta 21/TCP
iptables -A FORWARD -i $IF_LAN -p tcp --dport 20 -j ACCEPT #Libera todos da rede para acessar porta 20/TCP
###
iptables -A FORWARD -i $IF_LAN -s $CONTABIL -d 1.2.3.4 -p tcp --dport 80  -j ACCEPT #Permite um IP interno acessar um IP externo na porta 80
iptables -A FORWARD -i $IF_LAN -s $DVR -d 1.2.3.0/24 -j ACCEPT #Permite um IP interno acessar um bloco de IPs /24 externo, em qualquer porta/protocolo
###
iptables -A FORWARD -i $IF_LAN -i $IF_WAN -s $CONTABIL --sport 8817 -d 1.2.3.5 --dport 1393 -p udp -j ACCEPT #Permite um IP/porta interno acessar um IP/porta externo

#da interface "IF_WAN" para "IF_LAN"
iptables -A FORWARD -i $IF_WAN -o $IF_LAN -d $SERVER -p tcp --dport 5541 -j ACCEPT
iptables -A FORWARD -i $IF_WAN -o $IF_LAN -d $DVR    -p tcp --dport 9000 -j ACCEPT

#da interface "IF_LAN" para "IF_DMZ"
#iptables -A FORWARD -i $IF_LAN -o $DMZ -p icmp --icmp-type 0 -j ACCEPT
#iptables -A FORWARD -i $IF_LAN -o $DMZ -p icmp --icmp-type 8 -j ACCEPT
#iptables -A FORWARD -i $IF_LAN -o $DMZ -p tcp --dport 3389 -j ACCEPT
#iptables -A FORWARD -i $IF_LAN -o $DMZ -p tcp --dport 139 -j ACCEPT

#da interface "IF_DMZ" para "IF_LAN"
#iptables -A FORWARD -i $IF_DMZ -o $IF_LAN -p icmp --icmp-type 0 -j ACCEPT
#iptables -A FORWARD -i $IF_DMZ -o $IF_LAN -p icmp --icmp-type 8 -j ACCEPT
#iptables -A FORWARD -i $IF_DMZ -o $IF_LAN -p tcp --dport 3389 -j ACCEPT
#iptables -A FORWARD -i $IF_DMZ -o $IF_LAN -p tcp --dport 139 -j ACCEPT

#
##
###
### Regras OUTPUT ###
iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

#
##
###
### Regras POSTROUTING ###
echo 1 > /proc/sys/net/ipv4/ip_forward

#Configurando NAT
iptables -t nat -A POSTROUTING -s $REDE_IF_LAN -o $IF_WAN -j MASQUERADE #NAT: mascaramento (compartilhar Internet)
#iptables -t nat -A POSTROUTING -o $IF_WAN -j MASQUERADE #NAT: mascaramento (compartilhar Internet)

#dn@at

