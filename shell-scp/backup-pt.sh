#!/bin/bash
if [ -z "$1" ]
then
	echo "please input database information after the command"
else
	read -s -p  "please input password for root:" PASSWD
	echo "	"
	mkdir /sql &> /dev/null
	case "$1" in
		--all-databases)
		mysql -uroot -p${PASSWD} -e "SHOW DATABASES;" -N -E |grep -v row > /sql/databases-name
		MAX=`wc -l /sql/databases-name |cut -d " " -f 1`
		for i in $( seq 1 $MAX )
		do
		NAME=`sed -n ${i}p /sql/databases-name`
		mysqldump -uroot -p${PASSWD} --all-databases > /sql/${NAME}-`date +%Y-%m-%d`.sql 2>/dev/null && echo "$NAME is backup into /sql/${NAME}-`date +%Y-%m-%d`.sql" || (rm -fr /sql/${NAME}-`date +%Y-%m-%d`.sql;echo "$NAME backup is failure")
		done
		;;
		*)
		for j in $*
	        do
			mysqldump -uroot -p${PASSWD} $j > /sql/${j}-`date +%Y-%m-%d`.sql 2> /dev/null && echo "$j is backup into /sql/${j}-`date +%Y-%m-%d`.sql" || (rm -fr /sql/${j}-`date +%Y-%m-%d`.sql;echo "$j is not exist")
	        done
	esac
	rm -fr /sql/databases-name &> /dev/null
fi



#if [ "$1" = "--all-databases" ]
#then
#	mysql -uroot -p${PASSWD} -e "SHOW DATABASES;" -N -E |grep -v row > /sql/databases-name
#	MAX=`wc -l /sql/databases-name |cut -d " " -f 1`
#	for j in $( seq 1 $MAX )
#	do
#	NAME=`sed -n ${j}p /sql/databases-name`
#	mysqldump -uroot -p${PASSWD} --all-databases > /sql/${NAME}-`date +%Y-%m-%d`.sql 2>/dev/null && echo "${NAME} is backup into /sql/${NAME}-`date +%Y-%m-%d`.sql" || (rm -fr /sql/${NAME}-`date +%Y-%m-%d`.sql;echo "${NAME} backup is failure")
#	done
#	rm -fr /sql/databases-name &> /dev/null
#else
#        for i in $*
#        do
#                mysqldump -uroot -p${PASSWD} $i > /sql/${i}-`date +%Y-%m-%d`.sql 2> /dev/null && echo "$i is backup into /sql/${i}-`date +%Y-%m-%d`.sql" || (rm -fr /sql/${i}-`date +%Y-%m-%d`.sql;echo "$i is not exist")
#        done
#fi



