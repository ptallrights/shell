#!/bin/bash
TIME=`date +%Y-%m-%d`
mkdir /sql &>/dev/null
read -p "please input mysql password for root:" PASSWD
for i in $*
do
	mysqldump -uroot -p${PASSWD} --databases $i > /sql/$i-${TIME}.sql 2> /dev/null && echo "$i is backup into /sql/$i-${TIME}.sql" || (rm -fr /sql/$i-${TIME}.sql;echo "$i is not exist")
done
