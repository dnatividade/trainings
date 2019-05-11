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
#Desc.:     Script de firewall pessoal - DROP ALL
####################################################


### Variaveis ################
IF_INT="eth0" 		# Colocar aqui o nome da placa de rede interna

### Mensagem de inicialização do Firewall ###
echo "Ativando Regras do Personal Firewall -- #dnatividade"
####################################################

for TABLE in filter nat mangle raw security
do
      iptables -t $TABLE -F
      iptables -t $TABLE -X
      iptables -t $TABLE -Z
done
####################################################

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
####################################################

iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT  -i $IF_INT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -o $IF_INT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
####################################################

