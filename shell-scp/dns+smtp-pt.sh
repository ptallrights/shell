#!/bin/bash
#DNS
yum install bind -y &>/dev/null ||echo "install Error"
firewall-cmd --permanent --add-service=dns &>/dev/null
firewall-cmd --reload &>/dev/null
firewall-cmd --list-all &>/dev/null
read -p "please enter your domain( eg: baidu.com ):" DOMAIN
read -p "please enter your reverse network( eg: 254.25.172 ):" NETWORK
read -p "please enter your local IP address( eg: 172.25.254.1 ):" LOCALIP
read -p "please enter your inter IP address( eg: 192.268.1.1 ):" INTERIP
IP=`ifconfig eth0 |grep inet |grep -v inet6 |awk '{ printf $2 "\n"}'` &>/dev/null
cat >> /etc/resolv.conf << EOF
nameserver $IP
EOF
sed -i "s/listen-on\ port\ 53\ {\ 127.0.0.1;\ };/listen-on\ port\ 53\ {\ any;\ };/g" /etc/named.conf
sed -i "s/allow-query\ \ \ \ \ {\ localhost;\ };/allow-query\ \ \ \ \ {\ any;\ };/g" /etc/named.conf
sed -i "s/^zone/\/\*zone/g"  /etc/named.conf
sed -i "s/root.key\";/root.key\";\*\//g"  /etc/named.conf
NET=`echo $LOCALIP | cut -d . -f 1-3`
cat >> /etc/named.conf << EOF
view localnet {
	match-clients { ${NET}.0/24; };
	zone "." IN {
        type hint;
        file "named.ca";
};
	include "/etc/named.rfc1912.zones";
};

view internet {
        match-clients { any; };
        zone "." IN {
        type hint;
        file "named.ca";
};
        include "/etc/named.rfc1913.zones";
};
EOF
cp -p /etc/named.rfc1912.zones  /etc/named.rfc1913.zones
cat >> /etc/named.rfc1912.zones << EOF
zone "$DOMAIN" IN {
        type master;
        file "${DOMAIN}.zone";
        allow-update { none; };
};

zone "${NETWORK}.in-addr.arpa" IN {
        type master;
        file "${DOMAIN}.ptr";
        allow-update { none; };
};
EOF
cat >> /etc/named.rfc1913.zones << EOF
zone "$DOMAIN" IN {
        type master;
        file "${DOMAIN}.inter";
        allow-update { none; };
};

zone "${NETWORK}.in-addr.arpa" IN {
        type master;
        file "${DOMAIN}.ptr";
        allow-update { none; };
};
EOF
touch /var/named/${DOMAIN}.zone
touch /var/named/${DOMAIN}.inter
NAME='$TTL'
cat >> /var/named/${DOMAIN}.zone << EOF
$NAME 1D
@       IN SOA  dns.${DOMAIN}. pt.${DOMAIN}. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      dns.${DOMAIN}.
        A       $LOCALIP
dns	A	$LOCALIP
www	A	$LOCALIP
just	CNAME	do.it.${DOMAIN}.
do.it	A	$LOCALIP
${DOMAIN}.	MX 1	${LOCALIP}.
EOF
touch /var/named/${DOMAIN}.ptr
HOST=`echo $LOCALIP | cut -d . -f 4`
cat >> /var/named/${DOMAIN}.ptr << EOF
$NAME 1D
@	IN SOA	dns.${DOMAIN}. pt.${DOMAIN}. (
					0	; serial
					1D	; refresh
					1H	; retry
					1W	; expire
					3H )	; minimum
	NS	dns.${DOMAIN}.
dns	A	$LOCALIP
$HOST	PTR	www.${DOMAIN}.
$HOST	PTR	just.${DOMAIN}.
EOF
cat >> /var/named/${DOMAIN}.inter << EOF
$NAME 1D
@       IN SOA  dns.${DOMAIN}. pt.${DOMAIN}. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      dns.${DOMAIN}.
        A       $INTERIP
dns     A       $INTERIP
www     A       $INTERIP
just    CNAME   do.it.${DOMAIN}.
do.it   A       $INTERIP
${DOMAIN}.      MX 1    ${IP}.
EOF
systemctl restart named
systemctl enable named &>/dev/null
#mail
sed -i "s/inet_interfaces\ =\ localhost/inet_interfaces\ =\ all/g" /etc/postfix/main.cf
sed -i "s/mydestination\ =\ \$myhostname,\ localhost.\$mydomain,\ localhost/mydestination\ =\ \$myhostname,\ \$mydomain,\ localhost/g" /etc/postfix/main.cf
cat >> /etc/postfix/main.cf << EOF
mydomain=$DOMAIN
myorigin=\$mydomain
EOF
systemctl restart postfix
yum install dovecot -y &>/dev/null
firewall-cmd --permanent --add-port=110/tcp &>/dev/null
firewall-cmd --permanent --add-port=143/tcp &>/dev/null
firewall-cmd --permanent --add-port=993/tcp &>/dev/null
firewall-cmd --permanent --add-port=995/tcp &>/dev/null
firewall-cmd --reload &>/dev/null
firewall-cmd --list-all &>/dev/null
cat >> /etc/dovecot/dovecot.conf << EOF
protocols = imap pop3 lmtp
disable_plaintext_auth = no
EOF
cat >> /etc/dovecot/conf.d/10-mail.conf << EOF
mail_location = mbox:~/mail:INBOX=/var/mail/%u
EOF
systemctl restart dovecot
systemctl enable dovecot &>/dev/null
su - student -c "mkdir /home/student/mail"
su - student -c "mkdir /home/student/mail/.imap"
su - student -c "touch /home/student/mail/.imap/INBOX"
chgrp mail /home/student/mail/ -R
