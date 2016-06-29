#!/bin/bash
DATABASES=$1
read -p "please input password for root:" PASSWD
mkdir /sql &> /dev/null
if [ "$DATABASES" = "--all-databases" ]
then
	mysqldump -uroot -p${PASSWD} --all-databases > /sql/${DATABASES}-`date +%Y-%m-%d`.sql 2>/dev/null && echo "all-databases is backup into /sql/${DATABASES}-`date +%Y-%m-%d`.sql" || (rm -fr /sql/${DATABASES}-`date +%Y-%m-%d`.sql;echo "all-databases backup is failure")
else
	for i in $*
	do
		mysqldump -uroot -p${PASSWD} $i > /sql/${i}-`date +%Y-%m-%d`.sql 2> /dev/null && echo "$i is backup into /sql/${i}-`date +%Y-%m-%d`.sql" || (rm -fr /sql/${i}-`date +%Y-%m-%d`.sql;echo "$i is not exist")
	done
fi
