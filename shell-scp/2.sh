#!/bin/bash

MAX=`wc -l /mnt/username | cut -d  " " -f 1`
for NUM in $( seq  1 $MAX )
do 
	USERNAME=`sed -n ${NUM}p /mnt/username`
	PASSWORD=`sed -n ${NUM}p /mnt/password`
	TEST=`getent passwd $UAERNAME`
#	useradd $USERNAME
#	[ -z "$TEST" ] && echo $PASSWORD | passwd --stdin $USERNAME	
	while [ -z TEST ]
	do 
	useradd $USERNAME && echo $PASSWORD | passwd --stdin $USERNAME
	done
done
