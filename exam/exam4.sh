#!/bin/bash
# RHCSA exam 
#1
echo "1"
#echo ""
echo "examwestos" | passwd --stdin root >> /dev/null
if [ $? -eq 0 ];then
echo "Finish"
else echo "Error"
fi
#2
echo "2"
#echo ""
hostnamectl set-hostname station.domain8.example.com
if [ $? -eq 0 ];then
echo "Finish"
else echo "Error"
fi
#3
echo "3"
#echo ""
fdisk /dev/vdb << EOF &>> /dev/null
n
p
1

+800M
t
8e
w
EOF
if [ $? -gt 0 ];then
echo "fdisk Error"
fi
partprobe
pvcreate /dev/vdb1 &>> /dev/null || echo "pv Error"
vgcreate vg0 /dev/vdb1 &>> /dev/null || echo "vg Error"
lvcreate -L 300M -n lv0 vg0 &>> /dev/null || echo "lv Error"
mkfs.xfs /dev/vg0/lv0 &>> /dev/null || echo "mkfs.xfs Error"
mkdir /test &>> /dev/null || echo "mkdir Error"
mount /dev/vg0/lv0 /test &>> /dev/null || echo "mount Error"
cp -p -r /home/* /test/ &>> /dev/null || echo "cp Error"
umount /test &>> /dev/null || echo "umount Error"
echo "/dev/vg0/lv0 /home xfs defaults 0 0" >> /etc/fstab
mount -a  &>> /dev/null
lvextend -L 512M /dev/vg0/lv0 &>> /dev/null || echo "lvextend Error"
xfs_growfs /dev/vg0/lv0 &>> /dev/null || echo "xfs_growfs Error"
echo "Finish"
#4 
echo "4"
#echo ""
fdisk /dev/vdb << EOF &>> /dev/null
n
p
2

+500M
t
2
8e
w
EOF
#if [ $? -gt 0 ];then
#echo "fdisk Error"
#fi
partprobe
pvcreate /dev/vdb2 &>> /dev/null || echo "pv Error"
vgcreate -s 8M datastore /dev/vdb2 &>> /dev/null || echo "vg Error"
lvcreate -L 400M -n database datastore &>> /dev/null || echo "lv Error"
mkfs.ext3 /dev/datastore/database &>> /dev/null || echo "mkfs.ext3 Error"
mkdir /mnt/database &>> /dev/null || echo "mkdir Error"
echo "/dev/datastore/database /mnt/database ext3 defaults 0 0" >> /etc/fstab
mount -a &>> /dev/null || echo "mount Error"
echo "Finish"
#5
echo "5"
#echo ""
fdisk /dev/vdb << EOF &>> /dev/null
n
p
3

+512M
t
3
82
w
EOF
#if [ $? -gt 0 ];then
#echo "fdisk Error"
#fi
partprobe
mkswap /dev/vdb3 &>> /dev/null || echo "mkswap Error"
swapon -a /dev/vdb3 &>> /dev/null || echo "swapon Error"
echo "/dev/vdb3 swap swap defaults 0 0" >> /etc/fstab
mount -a &>> /dev/null || echo "mount Error"
echo "Finish"
#6
echo "6"
#echo ""
setenforce 1 &>> /dev/null || echo "setenforce Error"
echo "Finish"
#7
echo "7"
#echo ""
groupadd -g 600 sysadms &>> /dev/null ||  echo "groupadd Error"
echo "Finish"
#8
echo "8"
#echo ""
useradd -u 2013 tommy &>> /dev/null && echo "redhat" | passwd --stdin tommy >> /dev/null && echo "Finish" || echo "Error"
#9
echo "9"
#echo ""
useradd -s /sbin/nologin jimmy &>> /dev/null && echo "redhat" | passwd --stdin jimmy >> /dev/null && echo "Finish" || echo "Error"
#10 
echo "10"
#echo ""
useradd -G sysadms natasha &>> /dev/null || echo "useradd natasha Error"
useradd -G sysadms harry &>> /dev/null || echo "useradd harry Error"
echo "redhat" | passwd --stdin natasha >> /dev/null || echo "passwd natasha Error"
echo "redhat" | passwd --stdin harry >> /dev/null || echo "passwd harry Error"
echo "Finish"
#11
echo "11"
#echo ""
mkdir /home/materials &>> /dev/null || echo "mkdir Error"
chgrp sysadms /home/materials &>> /dev/null || echo "chgrp Error"
chmod g+rw /home/materials &>> /dev/null || echo "chmod Error"
chmod g+s /home/materials &>> /dev/null || echo "chmod Error"
echo "Finish"
#12
echo "12"
#echo ""
cp /etc/fstab /var/tmp/ &>> /dev/null || echo "cp Error"
cd /var/tmp
setfacl -m d:o::rwx /var/tmp
setfacl -m u:harry:--- fstab &>> /dev/null || echo "setfacl Error"
setfacl -m u:natasha:rwx fstab &>> /dev/null || echo "setfacl Error"
chown root:root fstab &>> /dev/null || echo "chown Error"
chmod +r fstab &>> /dev/null || echo  "chmod Error"
chmod -x fstab &>> /dev/null || echo "chmod Error"
cd - >> /dev/null
echo "Finish"
#13
echo "13"
#echo ""
echo "23 14 * * * natasha /bin/echo "hiya"" >> /etc/crontab
systemctl restart crond &>> /dev/null || echo "service crond Error"
echo "Finish"
#14
echo "14"
#echo ""
echo "server 172.25.254.254 iburst" >> /etc/chrony.conf
systemctl restart chronyd &>> /dev/null || echo "service chronyd Error"
echo "Finish"
#15
echo "15"
#echo ""
mkdir /root/findresults &>> /dev/null || echo "mkdir Error"
find / -group mail &>> /dev/null -exec cp -a {} /root/findresults \; >> /dev/null
echo "Finish"
#16
echo "16"
#echo ""
grep "ich" /usr/share/mime/packages/freedesktop.org.xml > /root/lines || echo "grep Error"
sed -i "s/^\ *//g" /root/lines || echo "sed Error"
echo "Finish"
#17
echo "17"
#echo "" 
yum install vsftpd -y &>> /dev/null || echo "yum Error"
chmod o+w /var/ftp/pub &>> /dev/null || echo "chmod Error"
systemctl start vsftpd &>> /dev/null || echo "service vsftpd1 Error"
systemctl enable vsftpd &>> /dev/null || echo "service vsftpd2 Error"
systemctl stop firewalld 
systemctl disable firewalld &>> /dev/null
setsebool -P ftpd_full_access 1 #selinux允许ftp服务
echo "anon_upload_enable=YES" >> /etc/vsftpd/vsftpd.conf #允许匿名用户上传
systemctl restart vsftpd &>> /dev/null || echo "service vsftpd3 Error"
echo "Finish"
#18
echo "18"
yum install sssd krb5-workstation autofs -y &>> /dev/null || echo "yum Error"
authconfig --enableldap --enablekrb5 --enableldaptls --ldaploadcacert=http://172.25.254.8/example-ca.crt --ldapserver=classroom.example.com --ldapbasedn="dc=example,dc=com" --krb5kdc=classroom.example.com --krb5adminserver=classroom.example.com --krb5realm=EXAMPLE.COM --updateall
echo "Finish"
#19
echo "19"
mkdir /home/guests &>> /dev/null || echo "mkdir Error"
chmod o+w /home/guests &>> /dev/null || echo "chmod Error"
echo "/home/guests /etc/ps" >> /etc/auto.master
cat > /etc/ps << end
ldapuser1 172.25.254.254:/home/guests/ldapuser1
ldapuser2 172.25.254.254:/home/guests/ldapuser2
ldapuser3 172.25.254.254:/home/guests/ldapuser3
ldapuser4 172.25.254.254:/home/guests/ldapuser4
end
systemctl restart autofs &>> /dev/null || echo "service autofs Error"
echo "Finish"
