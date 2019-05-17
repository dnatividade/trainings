#!/bin/bash

#################################################################
# Description:	script that downloads all parts of the
# 				VM and join them.
# 
# Created:		2019-05-12	dnatividade
# Updated:		2019-05-15	alexandredias3d
#
#################################################################

ROOT_URL=https://github.com/dnatividade/trainings/raw/master/mini-curso_iptables_easy_usefull/resources/VM/
FILE_NAME=mini-curso-iptables.tar

mkdir minicurso
cd minicurso/

# Download first part (from a to f there are a to z elements)
for i in {a..f}
do
    for j in {a..z}
    do
        URL="${ROOT_URL}${FILE_NAME}${i}${j}"
        ret=$(wget --no-check-certificate "${URL}")
        while [ $ret -ne 0 ]
        do
            ret=$(wget --no-check-certificate "${URL}")
        done
    done
done

# Download second part (g has elements from a to g)
for i in {a..g}
do
    URL="${ROOT_URL}${FILE_NAME}g${i}"
    ret=$(wget --no-check-certificate "${URL}")
    while [ $ret -ne 0 ]
    do
        ret=$(wget --no-check-certificate "${URL}")
    done
done


# Joins the parts
cat mini-curso-iptables.tar.* > mini-curso-iptables.tar
# Extract .ova file
tar xvf mini-curso-iptables.tar


exit 0
