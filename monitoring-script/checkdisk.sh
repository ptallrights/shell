#!/bin/bash
root="864784581@qq.com"
use=`df -h |grep -v Use| awk {'print $5'}`
DATE=`date +%F" "%T`


for i in ${use}
do
        if [ `echo $i|awk -F % '{print $1}'` -lt 10 ]
        then
                disk=`df -h | grep "\<$i"  | awk {'print $1'}`
                        echo "${disk} is ok"

                        echo ">>>>>>>>>>>>>>>>>"

        else
                disk_error=`df -h |grep $i | awk {'print $1'}`
                message(){
                        echo "$HOSTNAME"
                        echo "send time is $DATE"
                        echo "recipients is ${root}"
                        echo "$disk_error have no avail space to use"
                        echo "$disk_error have already use $i "
                }

                message | mail -s 'Alert:Almost out of disk space' ${root}
        fi
done

