#!/bin/bash

mail_add="ptallrights@163.com"
#use=`df -h|grep -v "File"|awk {'print $5'}|sed 's/%//g'`
use=`df -h|grep -v "File"|awk {'print $6'}`

Host=`hostname`
Date=`date '+%Y-%m-%d %H:%I:%S'`
Title="##########Information from ${Host} at ${Date}##########"
Log=/var/log/checkdisk.log

for i in $use
do
        if [ `df -h|grep "${i}$"|awk {'print $5'}|sed 's/%//g'` -lt 80 ]
        then
                disk_name=`df -h|grep "${i}$"|awk {'print $1'}`
                echo "${disk_name} is ok"
                echo "**************"
        else
                disk_error=`df -h |grep "${i}$"|awk {'print $1'}`
                disk_used=`df -h |grep "${i}$"|awk {'print $5'}`
                cat > /var/log/test.log << end
"${Title}"
"From ${Host}"
"Send time is ${Date}"
"recipient is ${mail_add}"
"$disk_error have no avial space to use"
"$disk_error have already use $disk_used"
end
                cat /var/log/test.log >> $Log
                mail -s "Alert:Almost out of disk space" ${mail_add} < /var/log/test.log
                rm -fr /var/log/test.log
        fi
done


