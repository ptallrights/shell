#!/bin/bash
id luck &>/dev/null
if [ $? -eq 0 ];then
	S=`cat /etc/passwd |grep luck |cut -d : -f 7`
	OK='/bin/bash'
	if [ "$S" == "$OK" ];then
		echo "user ok"
	else
		echo "user exist"
	fi
else
	useradd luck && echo "useradd ok"
fi
