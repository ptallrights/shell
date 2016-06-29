#!/bin/bash
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<end
DEVICE=eth0
BOOTPROTO=static
ONBOOT=yes
IPADDR=172.25.254.109
NETMASK=255.255.255.0
NAME=eth0
GATEWAY=172.25.254.250
DNS1=172.25.254.250
end
systemctl restart network

cat > /etc/yum.repos.d/rhel.repo <<end
[rhel]
name=localsoftware
baseurl=http://172.25.254.9/source
enabled=1
gpgcheck=0
end
yum clean all &>/dev/null
#1
echo "******1******"
echo "examwestos" | passwd --stdin root &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#2
echo "******2******"
X=`ifconfig eth0 |grep inet |grep -v inet6 |awk '{ printf $2 "\n"}'|cut -d . -f 4`
if [ $? -eq 0 ];then
	hostname station.domain${X}.example.com &>/dev/null
	echo "OK"
else
	echo "Error"
fi
#3
echo "******3******"
fdisk /dev/vdb << end &>> /dev/null
n
p
1

+600M
t
8e
wq
end
partprobe
pvcreate /dev/vdb1 &>/dev/null
vgcreate vg0 /dev/vdb1 &>/dev/null
lvcreate -L 200M -n lv0 vg0 &>/dev/null
mkfs.ext2 /dev/vg0/lv0 &>/dev/null
mkdir /exam &>> /dev/null
mount /dev/vg0/lv0 /exam &>> /dev/null
cp -p -r /home/* /exam/ &>> /dev/null
umount /exam &>> /dev/null
echo "/dev/vg0/lv0 /home xfs defaults 0 0" >> /etc/fstab
mount -a  &>> /dev/null
lvextend -L 512M /dev/vg0/lv0 &>> /dev/null
xfs_growfs /dev/vg0/lv0 &>> /dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#4
echo "******4******"
fdisk /dev/vdb << end &>> /dev/null
n
p
2

+600M
t
2
8e
wq
end
partprobe
pvcreate /dev/vdb2 &>/dev/null
vgcreate -s 8M datastore /dev/vdb2 &>/dev/null
lvcreate -L 400M -n database datastore &>/dev/null
mkfs.ext3 /dev/datastore/database &>/dev/null
mkdir /mnt/database &>/dev/null
echo "/dev/datastore/database  /mnt/database ext3 defaults 0 0" >> /etc/fstab
mount -a &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#5
echo "******5******"
fdisk /dev/vdb << end &>> /dev/null
n
p
3

+512M
t
3
82
wq
end
partprobe
mkswap /dev/vdb3 &>/dev/null
echo "/dev/vdb3 swap swap defaults 0 0" >> /etc/fstab
swapon -a &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#6
echo "******6******"
setenforce 1 &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#7
echo "******7******"
groupadd -g 600 sysadms &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#8
echo "******8******"
useradd -u 2013 tommy &>/dev/null && echo redhat | passwd --stdin tommy &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#9
echo "******9******"
useradd -s /sbin/nologin jimmy &>/dev/null && echo redhat | passwd --stdin jimmy &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#10
echo "******10******"
useradd -G sysadms natasha &>/dev/null && echo redhat | passwd --stdin natasha &>/dev/null
useradd -G sysadms harry &>/dev/null && echo redhat | passwd --stdin harry &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#11
echo "******11******"
mkdir /home/materials &>/dev/null
chgrp sysadms /home/materials &>/dev/null
chmod 2777 /home/materials &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#12
echo "******12******"
cp -p /etc/fstab /var/tmp &>/dev/null
setfacl -m u:harry:--- /var/tmp/fstab &>/dev/null
setfacl -m u:natasha:rwx /var/tmp/fstab &>/dev/null
chown root /var/tmp/fstab &>/dev/null
chgrp root /var/tmp/fstab &>/dev/null
setfacl -m o::r-- /var/tmp/fstab &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#13
echo "******13******"
echo "23 14 * * * natasha /bin/echo "hiya"" >> /etc/crontab
systemctl restart crond &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#14
echo "******14******"
sed -i "s/server/#server/g" /etc/chrony.conf
echo "server 172.25.254.254 iburst" >> /etc/chrony.conf
systemctl restart chronyd.service &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#15
echo "******15******"
mkdir /root/findresults
find / -group mail 2>/dev/null -exec cp -p {} /root/findresults/ \;
#16
echo "******16******"
cat /usr/share/mime/packages/freedesktop.org.xml |grep ich > /root/lines
sed -i "s/^\ *//g" /root/lines &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#17
echo "******17******"
yum install vsftpd -y &>/dev/null
chmod o+w /var/ftp/pub &>/dev/null
systemctl start vsftpd 
systemctl stop firewalld 
systemctl enable vsftpd &>/dev/null
setsebool -P ftpd_full_access &>/dev/null
echo "anon_upload_enable=YES" >> /etc/vsftpd/vsftpd.conf 
systemctl restart vsftpd &>/dev/null
#18
echo "******18*******"
yum install sssd -y &>/dev/null
yum install krb5-workstation -y &>/dev/null
yum install autofs -y &>/dev/null
authconfig --enableldap --enableldaptls --enablekrb5 --ldaploadcacert=http://172.25.254.9/example-ca.crt --ldapserver=classroom.example.com --ldapbasedn="dc=example,dc=com" --krb5kdc=classroom.example.com --krb5adminserver=classroom.example.com --krb5realm=EXAMPLE.COM --updateall 
getent passwd ldapuser1 &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
#19
echo "******19******"
mkdir /home/guests &>/dev/null 
chmod o+w /home/guests &>/dev/null
echo "/home/guests /etc/ptallrights" >> /etc/auto.master
cat > /etc/ptallrights <<end
ldapuser1 172.25.254.254:/home/guests/ldapuaer1
ldapuser2 172.25.254.254:/home/guests/ldapuaer2
ldapuser3 172.25.254.254:/home/guests/ldapuaer3
ldapuser4 172.25.254.254:/home/guests/ldapuaer4
ldapuser5 172.25.254.254:/home/guests/ldapuaer5
end
systemctl restart autofs &>/dev/null
if [ $? -eq 0 ];then
	echo "OK"
else
	echo "Error"
fi
