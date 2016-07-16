#!/bin/bash
##ssh connectivity
if [ -z $1 ];then
	echo 'please input an ip'
else
	nc -z -w 10 $1 22 &> /dev/null
	if [ $? -eq 0 ];then
		echo 'ssh is normal'
	else
		echo 'ssh is abnormal,please cheak up'
	fi
fi
