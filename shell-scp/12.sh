#!/bin/bash
NAME=$1
id $NAME &> /dev/null
if [ $? = 0 ]
then
	USERID=`id -u $NAME`
	if [ $USERID -eq 0 ]
	then
		echo "$NAME is Adminstor"
	else
		echo "$NAME is common user"
	fi
else
	echo "$NAME not exist"
fi
