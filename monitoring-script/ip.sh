#!/bin/bash

IP=`ifconfig  |grep "inet addr" |awk -F'[ :]+' '{print $4}'` 
HW=`ifconfig | grep 'Link encap' |awk -F'[ :]+' '{print $1}'`
NUM=`ifconfig | grep 'Link encap' |awk -F'[ :]+' '{print $1}' |wc`
#printf "$IP\n"
#printf "$HW\n"
#echo $IP >> testone

printf "$NUM\n"
printf "$IP\n"
printf "$HW\n"
#hash=([$HW]=$IP)
#printf hash
#declare -A hash
#for i in $(seq 1 $NUM)
#	do
#	echo "$i : hash"
#	done
