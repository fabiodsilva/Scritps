#!/bin/bash
# Openstack
# Script para balancear instancias entre computes

# Autenticação do openstaack
source /var/instanceBalance/keystonerc_admin-v3

LOG="/var/instanceBalance/logs/"

## Limpando arquivos temporarios
> /tmp/lista111
> /tmp/ordenada111

echo "Start Balance - `date +%Y%m%d-%H:%M:%S`" >> $LOG/instancias_migradas.log
> $LOG/check_migradas.log

## Gerando lista de computes habilitados com load average
nova service-list | grep nova-compute | grep enabled | grep up | awk '{print $6}' | while read i
do
        echo "$(nova hypervisor-uptime $i | grep "load average" | awk -F 'average:' '{print $2}' | xargs) $i $(nova hypervisor-servers $i | grep instance | wc -l)" >> /tmp/lista111
done

## Ordenando computes com maior load
sort -r -n /tmp/lista111 > /tmp/ordenada111

#cat ./ordenada111


## Definindo direcao da migracao
origem=$(head -n4 /tmp/ordenada111 | awk '{print $5}')
destino=$(tail -n4 /tmp/ordenada111 | awk '{print $5}')

#echo "Compute Origem $origem"
#echo "Compute Destino $destino"

load_origem=$(head -n1 /tmp/ordenada111 | awk -F "." '{print $1}')
load_destino=$(tail -n1 /tmp/ordenada111 | awk -F "." '{print $1}')

#echo "Load Origem  $load_origem"
#echo "Load Destino  $load_destino"

#################################
        if [ $(echo "$load_origem  -gt 30")  ] ; then #executa migracao apenas se load for maior que 30.
     #      echo " Load do compute $load_origem está maior que 30 "


           for a in $(echo $origem); #origem de onde irá sair as vms.
           do

                x=1   #migra 1 vms
                while [ $x -le 1 ]
                do

                        for b in $(echo $destino); #lista dos novas de destino.
                        do


                                ## Migrando instancia ligada que esteja nos flavors de 4 a 8 GB
                                nova hypervisor-servers $a | grep " | " | grep -v ' ID ' |awk '{print $2}' | while read i
                                do


                                    nova show $i | grep status | grep ACTIVE && \
                                                nova show $i | grep flavor | egrep 'micro|small|medium|large.8GB|large.16GB' && \
                                                echo "migrando $i para $destino" && \
                                                echo "$a $i $b - `date +%Y%m%d-%H:%M:%S`" >> $LOG/instancias_migradas.log && \
                                                echo "$a $i $b - `date +%Y%m%d-%H:%M:%S`" >> $LOG/check_migradas.log && \
                                                nova live-migration $i $b && \
                                                sleep 30 && \
                                                break
                                 done

                                 echo "sleep 30"  #intervalo de migracao das vms

                        done

                        x=$(( $x + 1 ))
                done

            done

        else
        echo "Fim do Balanceado" >> $LOG/instancias_migradas.log

        fi

        echo "End Balance - `date +%Y%m%d-%H:%M:%S`" >> $LOG/instancias_migradas.log
        echo "------------------------------" >> $LOG/instancias_migradas.log
