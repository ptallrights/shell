#!/bin/bash

e_mail=18191104459@163.com
Day=$(date +%d)
hour=$(date '+H')
log=/var/log/hd.log
DATE=$(date '+%Y-%m-%d %H:%I:%S')
Host=`hostname`
echo “====================${Host}${DATE}===================” > $log
hd_info=`df -h|grep -v "File" |sed 's/%//g'| awk '{if ($5 > 80) print $0}'`
if [ -n "$hd_info" ]
then
	df -h|grep -v "File" |sed 's/%//g'| awk '{if ($5 > 80) print $0}' >> $log
	mail -s "$Host Disk warning"  $e_mail < $log
else
	echo “Disk space is ok” >>$log
	if [ $Day -eq 1 && $hour -eq 9 ]
	then
		df -h|grep -v “File” |sed 's/%//g'| awk ‘{ print $0}’ >>$log
		mail -s “$Host Dis Information”  < $log
	fi
fi
