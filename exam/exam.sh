#!/bin/bash
echo "DEVICE=eth0
BOOTPROTO=static
ONBOOT=yes
IPADDR=172.25.254.12
NETMASK=255.255.255.0
NAME=eth0
GATEWAY=172.25.254.250
DNS1=172.25.254.250" > /etc/sysconfig/network-scripts/ifcfg-eth0
systemctl restart network

echo "[rhel]
name=localsoftware
baseurl=ftp://172.25.254.250/pub/rhel7.0
enabled=1
gpgcheck=0" > /etc/yum.repos.d/rhel.repo
yum clean all &>/dev/null
#1
echo "examwestos" | passwd --stdin root &>/dev/null
if [ $? -eq 0 ];then
	echo "passwd already add successfully for root."
else
	echo "Error:passwd add failure for root."
fi
#2
X=`ifconfig eth0 |grep inet |grep -v inet6 |awk '{ printf $2 "\n"}'|cut -d . -f 4`
if [ $? -eq 0 ];then
	hostname station.domain${X}.example.com &>/dev/null
	echo "hostname already change successfully."
else
	echo "Error:hostname change failure."
fi
#3
fdisk /dev/vdb <<end
n
p
1

+512M
wq
end
partprobe
mkfs.vfat /dev/vdb1
cp -p /home/* /dev/vdb1
mount /dev/vdb1 /home
#4
fdisk /dev/vdb <<end
n
p
2

+500M
t
2
8e
wq
end
partprobe
pvcreate /dev/vdb2
vgcreate -s 8M datastore /dev/vdb2
lvcreate -L 50 -n database datestore
mkfs.vfat /dev/datastore/database
echo "/dev/datastore/database  /mnt/database vfat defaults 0 0" >> /etc/fstab
mkdir /mnt/database
mount -a
#5
fdisk /dev/vdb<<end
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
mkswap /dev/vdb3
echo /dev/vdb3 swap swap defaults 0 0 >> /etc/fstab
swapon -a
if [ $? -eq 0 ];then
	echo "swap partition already set."
else
	echo "Error:swap partition setting is fault."
fi
#6
setenforce 1
#7
groupadd -g 600 sysadms
#8
useradd -u 2013 tommy
echo redhat | passwd --stdin tommy
#9
useradd -s /sbin/nologin jimmy
echo redhat | passwd --stdin jimmy
#10
useradd -G sysadms natasha 
useradd -G sysadms harry
echo redhat | passwd --stdin natasha
echo redhat | passwd --stdin harry
#11
mkdir /home/materials
chgrp sysadms /home/materials
chmod 2777 /home/materials
#12
cp -p /etc/fstab /var/tmp
setfacl -m u:harry:--- /var/tmp/fstab
setfacl -m u:natasha:rwx /var/tmp/fstab
chown root /var/tmp/fstab
chgrp root /var/tmp/fstab
setfacl -m o::r-- /var/tmp/fstab
#13
su - natasha
at 14:23<<end
/bin/echo hiya
<EOT>
end
logout
#14
sed -i "s/0.rhel.pool.ntp.org/172.25.254.254/g" /etc/chrony.conf
sed -i "s/server 1.rhel.pool.ntp.org iburst/ /g" /etc/chrony.conf
sed -i "s/server 2.rhel.pool.ntp.org iburst/ /g" /etc/chrony.conf
sed -i "s/server 3.rhel.pool.ntp.org iburst/ /g" /etc/chrony.conf
systemctl restart chronyd.service
#15
mkdir /root/findresults
find / -group mail 2>/dev/null -exec cp -p {} /root/findresults/ \;
#16
cat /usr/share/mime/packages/freedesktop.org.xml |grep ich > /root/lines
sed -i "s/ /\/g" /root/lines &>/dev/null
#17
yum install vsftpd -y
systemctl start vsftpd 
systemctl stop firewalld 
systemctl enable vsftpd
NAME=`grep write_enable /etc/vsftpd/vsftpd.conf | grep -v '#'`
sed -i "s/$NAME/write_enable=YES/g" /etc/vsftpd/vsftpd.conf
NAME=`grep anon_upload_enable /etc/vsftpd/vsftpd.conf | grep -v '#'`
sed -i "s/$NAME/anon_upload_enable=YES/g" /etc/vsftpd/vsftpd.conf
NAME=`grep anon_world_readable_only /etc/vsftpd/vsftpd.conf | grep -v '#'`
sed -i "s/$NAME/anon_world_readable_only=NO/g" /etc/vsftpd/vsftpd.conf
chgrp ftp /var/ftp/pub
chmod 775 /var/ftp/pub
systemctl restart vsftpd
#18
yum install sssd -y
yum install krb5-workstation -y

