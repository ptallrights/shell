#!/bin/bash
[ -n "$1" -a -n "$2" -a -f "$1" -a -f "$2" ] && (
	MAX=`wc -l $1 | cut -d " " -f 1`
	for NUM in $( seq 1 $MAX )
	do
		USERNAME=`sed -n ${NUM}p $1`
		PASSWORD=`sed -n ${NUM}p $2`
		useradd $USERNAME
		echo $PASSWORD | passwd --stdin $USERNAME
	done 
)
[ -z "$1" ] &&  echo "please input user file and passwd file after the command" ||( [  -n "$1" -a -z "$2" ] &&  echo "please input passwd file after the command" ) || ( (!([ -f "$1" -a -f "$2" ])) && echo "input username file or passwd file is error" )
