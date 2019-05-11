#!/bin/bash

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
