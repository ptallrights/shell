#!/bin/bash - 
#===============================================================================
#
#          FILE: lnmp.sh
# 
#         USAGE: ./lnmp.sh or lnmp.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: null
#  REQUIREMENTS: ---
#          BUGS: yum
#         NOTES: ---
#        AUTHOR: chenziyao 
#  ORGANIZATION: 
#       CREATED: 02/04/2016 17:00
#      REVISION: 1.2
#===============================================================================

#**********************************变量定义******************************************
mysql_path="/usr/local/lnmp/mysql"
nginx_path="/usr/local/lnmp/nginx"
php_path="/usr/local/lnmp/php"
cur_path=`pwd`
path="/mnt"								
nginx_version="nginx-1.8.0"
mysql_version="mysql-5.5.12"
php_version="php-5.4.36"
default=1
#*******************************************************************************


# Check if user is root
check_root(){
	if [ $(id -u) != "0" ]; then                           #通过判断当前用户的id来判断是否为root用户
		echo -e "\033[31m Error: You must be root to run this script, please use root to install lnmp \033[0m"   #不是则提示：该脚本必须以root身份运行，请用root身份安装lnmp
		exit 1                 #失败则退出
	fi
}
#----------------------------lnmp info---------------------------------------------------
lnmp_info(){
	clear
	echo -e "\033[37;5m=========================================================================="   #下面几行就是输出安装脚本的相关信息
	echo -e "||\t\t\tLNMP for CentOS/RadHat Linux\t\t\t|| "
	echo "=========================================================================="
	echo -e "||\tAUTHOR: chenziyao \t\t\t\t\t\t||"
	echo -e "||\tA tool to auto-compile & install Nginx+MySQL+PHP on Linux\t||"
	echo -e "||\tAll source packages are placed in the /mnt.\t\t\t||"
	echo -e "||\tDefault installation path in /usr/local/lnmp.\t\t\t||"
	echo -e "========================================================================== \033[0m"
}


#Set timezone       #设置系统的时区
set_timezone(){
	rm -rf /etc/localtime       #强制删除/etc/localtime文件夹和里面的文件
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  #做个软链
}

get_char(){          #这一段的代码其实的功能就是让用户输入任意键以继续执行脚本，是常用的代码段
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}
#***************************************************************************************
check_mysql(){
	rpm -qa|grep mysql &>/dev/null        #显示系统中所有已经安装的rpm包中是否有mysql
	[ $? -eq 0 ] && rpm -e mysql &>/dev/null &&             #删除mysql
	yum -y remove mysql-server mysql &>/dev/null   #yum卸载mysql相关服务
}
check_httpd(){
	rpm -qa |grep  httpd  &>/dev/null    #显示系统中所有已经安装的rpm包中是否有httpd
	[ $? -eq 0 ] && rpm -e httpd  &>/dev/null &&         #删除httpd包，也即是删除已经安装的apache
	yum -y remove httpd*  &>/dev/null  #yum卸载httpd相关组件
}

check_php(){
	rpm -qa|grep php   &>/dev/null      #显示系统中所有已经安装的rpm包中是否有php
	[ $? -eq 0 ] && yum -y remove php*  &>/dev/null &&       #yum卸载php
	yum -y remove php-mysql &>/dev.null       #yum卸载php-mysql
}
check_all(){
	check_mysql
	check_httpd
	check_php
}
#*******************************系统通用函数************************************************

#判断软件是否安装
installed_software(){
	[ -d "$1" ]
}

userctl(){
    grep $1 /etc/group &>/dev/null
    [ $? -eq 0 ] || (groupadd -g $2 $1 &>/dev/null)
    grep $1 /etc/passwd &>/dev/null
    [ $? -eq 0 ] || (useradd -u $2 -g $2 -M -s /sbin/nologin $1 &>/dev/null)
}

userdel(){
	grep $1 /etc/passwd &>/dev/null
	[ $? -eq 0 ] &&( &>/dev/null)
}

#**************************************错误定义*******************************************
install_failed_menu(){
	echo -e "\033[31mSorry, $1 installation failure, please try again, thank you for your cooperation\033[0m" 
}

install_cfailed_menu(){
	echo -e "\033[31mSorry,$1 compile failed, please try again, thank you for your cooperation\033[0m" 
}


#************************************************************************************


#********************************mysql模块**********************************************

reinstall_mysql(){
	remove_mysql
	mysql_install
}

remove_mysql(){
	if [ -d $mysql_path ] ;then
		/etc/init.d/mysqld stop &>/dev/null
		rm -rf  $mysql_path
		echo -e "\033[36m    mysql removed.\033[0m"
		userdel mysql
	else
		echo -e "\033[36m    Mysql not installed \033[0m" && return 5
	fi
}
mysql_install_init(){
	echo "Do you want to install the InnoDB Storage Engine?"   #提示你是否想安装innodb这个引擎
	read -p -t 5 "(Default no,if you want please input: y ,if not please press the enter button):" installinnodb #读取用户的输入，直接回车则默认是不安装
}
mysql_install(){
	check_mysql
	installinnodb="y"
	installed_software $mysql_path
	[ $? -eq 0 ] && echo -e "\033[33    m mysql is installed \033[0m" && return 5
	cd $path
	[ ! -s "${mysql_version}.tar.gz" ] && echo -e "\033[31m Error: ${mysql_version}.tar.gz not found!\033[0m"  && return 3
	[ $default -eq 0 ] && mysql_install_init
	echo -e "\033[32m    Mysql is installing"
	echo -en "###############[0%] \033[0m"
	tar zxf ${mysql_version}.tar.gz
	echo -en "\r\r\033[32m###############[10%] \033[0m"
	cd $mysql_version
	yum install -y cmake gcc gcc-c++ make ncurses-devel bison openssl-devel zlib-devel expect &> /dev/null
	echo -en "\r\r\033[32m###############[30%] \033[0m"
	if [[ $installinnodb = "y" ]]; then
		cmake -DCMAKE_INSTALL_PREFIX=${mysql_path} -DMYSQL_DATADIR=${mysql_path}/data -DMYSQL_UNIX_ADDR=${mysql_path}/data/mysql.sock -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci &> /dev/null
	else
		cmake -DCMAKE_INSTALL_PREFIX=${mysql_path} -DMYSQL_DATADIR=${mysql_path}/data -DMYSQL_UNIX_ADDR=${mysql_path}/data/mysql.sock -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci &> /dev/null
	fi
		[ $? -eq 1 ] && install_cfailed_menu mysql && return 5
		echo -en "\r\r\033[32m###############[60%] \033[0m"
		(make &>>/dev/null)&&(make install &>> /dev/null)
		[ $? -eq 1 ] && install_failed_menu mysql && return 3
		cp support-files/mysql.server /etc/init.d/mysqld
		echo "PATH=\$PATH:${mysql_path}/bin" >> /etc/profile
		source /etc/profile
		cp support-files/my-medium.cnf /etc/my.cnf
		cp support-files/mysql.server /etc/init.d/mysqld
		chmod u+x /etc/init.d/mysqld
		echo -en "\r\r\033[32m###############[90%] \033[0m"
		userctl mysql 27
		chown mysql.mysql ${mysql_path} -R
		${mysql_path}/scripts/./mysql_install_db --user=mysql --basedir=${mysql_path} --datadir=${mysql_path}/data/ &>/dev/null
		echo -en "\r\r\033[32m###############[100%] \033[0m"
		echo -e "\r\r\033[32m    Installed is ok! \033[0m"
	  	mysql_init
}
mysql_init(){
	mysqlrootpwd="root"                        #将root赋值给mysqlrootpwd
	/etc/init.d/mysqld start
	 echo -e "\033[32m Please input the root password of mysql(Default password: root)" 
	[ $default -eq 0 ] &&       #提示：设置mysql的root密码为
	read -p -t 5 -s "newpasswd:" mysqlrootpwd    #读取用户输入的mysql的root密码，输入则赋值给mysqlrootpwd这个变量，直接回车则默认密码是root
	if [ "$mysqlrootpwd" = "" ]; then                #判断用户是否输入，如果输入为空，则默认密码为root本文出处：www.ksharpdabu.info
		mysqlrootpwd="root"
	fi
	#
	#mysql初始化命令，
	mysql >>/dev/null<<EOF
	use mysql;
	update user set password=password('$mysqlrootpwd') where user='root';
	delete from user where not (user='root') ;
	delete from user where user='root' and password='';
	DROP USER ''@'%';
	flush privileges;
EOF
	echo -e "    Mysql init OK \033[0m"
	rm -rf ${path}{$mysql_version}
}

#mysql安装菜单
mysql_memu(){
	while : ;do
		echo 'Please select MYSQL server:'
		echo -e "1.\t\033[36m Install Mysql \033[0m"
		echo -e "2.\t\033[36m Uninstall Mysql \033[0m"
		echo -e "3.\t\033[36m ReInstall Mysql \033[0m"
		echo -e "4.\t\033[36m quit \033[0m"
		read -p "Please input a number:(Default 1 press Enter) " mysql_oper
		mysql_case
		[ $? -eq 4 ] && return 0
	done
}

mysql_case(){
		case $mysql_oper in
		1)	mysql_install
			;;
		2)	remove_mysql
			;;
		3)	reinstall_mysql
			;;
		4)	return 4
			;;
		*)
			echo -e "033[36m input error! Please only input number 1,2,3,4 \033[0m"
		esac
}



#*****************************************************************************************************

nginx_memu(){
	nginx_oper=1
	while : ;do
		echo 'Please select Nginx server:'
		echo -e "1.\t\033[36m Install Nginx \033[0m"
		echo -e "2.\t\033[36m Uninstall Nginx \033[0m"
		echo -e "3.\t\033[36m ReInstall Nginx \033[0m"
		echo -e "4.\t\033[36m quit \033[0m"
		read -p "Please input a number:(Default 1 press Enter) " nginx_oper
		nginx_case
		[ $? -eq 4 ] && return 0
	done
}

nginx_case(){
		case $nginx_oper in
		1)	install_nginx
			;;
		2)	remove_nginx
			;;
		3)	reinstall_nginx
			;;
		4)	return 4
			;;
		*)
			echo -e "\033[36m input error! Please only input number 1,2,3,4 \033[0m"
		esac
}


remove_nginx(){
	
	if [ -d ${nginx_path} ] ;then  
		kill -9 ${nginx_path}/logs/nginx.pid &>/dev/null
		rm -rf /sbin/nginx
		rm -rf  $nginx_path
		userdel nginx
		echo -e "    \033[36m    nginx removed.\033[0m"
	else
		echo -e "    \033[36m    Nginx not installed \033[0m" && return 5
	fi
}

install_nginx(){
		check_httpd
		installed_software $nginx_path
		[ $? -eq 0 ] && echo -e "    \033[33m    nginx is installed \033[0m" && return 5
		
		cd $path
		[ ! -s "${nginx_version}.tar.gz" ] && echo -e "\033[31m Error: ${nginx_version}.tar.gz not found!\033[0m"  && return 3
		echo -e "\033[32m    Nginx is installing"
		echo -en "###############[0%] \033[0m"
	        tar zxf ${nginx_version}.tar.gz
		echo -en "\r\r\033[32m###############[10%] \033[0m"
	        yum install gcc pcre-devel openssl-devel -y &> /dev/null
		echo -en "\r\r\033[32m###############[30%] \033[0m"
	        cd $nginx_version
	        sed -i '/CFLAGS="$CFLAGS -g"/c #CFLAGS="$CFLAGS -g"' auto/cc/gcc
	        sed -i 's/#define NGINX_VER.*NGINX_VERSION/#define NGINX_VER          "nginx"/' src/core/nginx.h
	        ./configure --prefix=${nginx_path} --with-http_ssl_module --with-http_stub_status_module &>/dev/null
	        [ $? -eq 1 ] && install_cfailed_menu nginx && return 5
		echo -en "\r\r\033[32m###############[50%] \033[0m"
	        make &>/dev/null && make install &>/dev/null
	        [ $? -eq 1 ] && install_failed_menu nginx && return 3
		echo -en "\r\r\033[32m###############[80%] \033[0m"
	       
	    ln -s ${nginx_path}/sbin/nginx /sbin
	    echo -e "\r\r\033[32m###############[100%] \033[0m"
	    echo -e "\033[32m    Installed is ok! \033[0m"
	    nginx_init
}

#nginx初始化
nginx_init(){
	userctl nginx 48 
	sed -i 's/#user.*/user nginx;/' ${nginx_path}/conf/nginx.conf
	cup_num=$(grep -c processor /proc/cpuinfo)
	sed -i "s:worker_processes.*:worker_processes $cup_num;:" ${nginx_path}/conf/nginx.conf
	nginx &>/dev/null
	if [ $? -eq 0 ];then 
		echo -e "\t\033[32m    nginx is running \033[0m" 
	else
		nginx -t
	fi
}

reinstall_nginx(){
	remove_nginx
	install_nginx
}

#*******************************************************************************************************
remove_php(){
	if [ -d ${php_path} ] ;then 
	
		rm -rf  $php_path
		echo -e "    \033[32m    php removed.\033[0m"
	else
		echo -e "    \033[33m    php not installed \033[0m" && return 5	
	fi
}
install_php(){
	check_php
	installed_software $php_path
	[ $? -eq 0 ] && echo -e "\033[33m    php is installed \033[0m" && return 5
	cd $path
	[ ! -s "${php_version}.tar.bz2" ] && echo -e "\033[31m Error: ${php_version}.tar.bz not found!\033[0m" && return 3
	echo -e "\033[32m    Php is installing"
	echo -en "###############[0%] \033[0m"
	tar jxf ${php_version}.tar.bz2
	userctl nginx 48 
	yum install libmcrypt-2.5.8-9.el6.x86_64.rpm libmcrypt-devel-2.5.8-9.el6.x86_64.rpm gd-devel-2.0.35-11.el6.x86_64.rpm -y &>/dev/null
	cd $php_version
	yum install net-snmp-devel libcurl-devel libxml2-devel libpng-devel libjpeg-turbo-devel-1.2.1-1.el6.x86_64 openssl-devel  freetype-devel gmp-devel openldap-devel -y &> /dev/null
	yum install gcc-c++ make ncurses-devel bison openssl-devel zlib-devel libxml2-devel easy-devel libcurl-devel-7.19.7-37.el6_4.x86_64 libjpeg-turbo-devel-1.2.1-1.el6.x86_64 gd-devel-2.0.35-11.el6.x86_64.rpm gmp-devel-4.3.1-7.el6_2.2.x86_64 net-snmp-devel php-pear.noarch mysql_devel -y &> /dev/null
	echo -en "\r\r\033[32m###############[20%] \033[0m"
	mem_totol=$(awk '/MemTotal/{total=$2}END{printf"%d",(total)/1024}'  /proc/meminfo) 
	#获取内存大小，php编译时内存小于1G时，编译要加上 --disable-fileinfo
	if [ $mem_totol -ge 1024 ] ;then
		./configure --prefix=/usr/local/lnmp/php --with-config-file-path=/usr/local/lnmp/php/etc --with-mysql --with-openssl --with-snmp --with-gd --with-zlib --with-curl --with-libxml-dir --with-png-dir --with-jpeg-dir --with-freetype-dir --without-pear --with-gettext --with-gmp --enable-inline-optimization --enable-soap --enable-ftp --enable-sockets --enable-mbstring --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx --with-mhash &>/dev/null
		#(./configure --prefix=${php_path} --with-config-file-path=${php_path}/etc --with-openssl --with-snmp --with-gd --with-zlib --with-curl --with-libxml-dir --with-png-dir --with-jpeg-dir --with-freetype-dir --with-pear --with-gettext --with-gmp --enable-inline-optimization --enable-soap --enable-ftp --enable-sockets --enable-mbstring --with-mysqli --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx --with-ldap-sasl --with-mcrypt --with-mhash )&>/dev/null
	else
		./configure --prefix=/usr/local/lnmp/php --with-config-file-path=/usr/local/lnmp/php/etc --with-mysql --with-openssl --with-snmp --with-gd --with-zlib --with-curl --with-libxml-dir --with-png-dir --with-jpeg-dir --with-freetype-dir --without-pear --with-gettext --with-gmp --enable-inline-optimization --enable-soap --enable-ftp --enable-sockets --enable-mbstring --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx --with-mhash --disable-fileinfo &>/dev/null
		#(./configure --prefix=${php_path} --with-config-file-path=${php_path}/etc --with-openssl --with-snmp --with-gd --with-zlib --with-curl --with-libxml-dir --with-png-dir --with-jpeg-dir --with-freetype-dir --with-pear --with-gettext --with-gmp --enable-inline-optimization --enable-soap --enable-ftp --enable-sockets --enable-mbstring --with-mysqli --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx --with-ldap-sasl --with-mcrypt --with-mhash --disable-fileinfo )&>/dev/null
	fi
	[ $? -eq 1 ] && install_cfailed_menu php && return 5
	echo -en "\r\r\033[32m###############[50%] \033[0m"
	(make &> /dev/null && make install &>/dev/null)
	[ $? -eq 1 ] && install_failed_menu php && return 3
	echo -en "\r\r\033[32m###############[80%] \033[0m"
	cp ${path}/${php_version}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
	chmod +x /etc/init.d/php-fpm
	cp ${path}/${php_version}/php.ini-production ${php_path}/etc/php.ini
	sed 's/.*date.timezone.*/date.timezone = Asia\/Shanghai/' ${php_path}/etc/php.ini -i
	cp ${php_path}/etc/php-fpm.conf.default ${php_path}/etc/php-fpm.conf
	sed -ir 's/;\(pid = run\/php-fpm.pid\)/\1/g' ${php_path}/etc/php-fpm.conf 
	echo -en "\r\r\033[32m###############[90%] \033[0m"
	php_init
	echo -e "\r\r\033[32m###############[100%] \033[0m"
	echo -e "\033[32m    Installed is ok! \033[0m"
}
php_init(){
	[ -d $nginx_path ] &&
	(sed -i '65,71s/#//g' ${nginx_path}/conf/nginx.conf
	sed -i 's/fastcgi_params/fastcgi.conf/g' ${nginx_path}/conf/nginx.conf
	sed -ir 's/\(^ *index.*\);/\1 index.php;/g' ${nginx_path}/conf/nginx.conf
	echo "<?php
phpinfo();
?>" > ${nginx_path}/html/index.php
	)
	/etc/init.d/php-fpm start &>/dev/null
	killall -9 nginx &>/dev/null && nginx &>/dev/null
}

reinstall_php(){
	remove_php
	install_php
}


php_memu(){
	php_oper=1
	while : ;do
		echo 'Please select PHP server:'
		echo -e "1.\t\033[36m Install PHP \033[0m"
		echo -e "2.\t\033[36m Uninstall PHP \033[0m"
		echo -e "3.\t\033[36m ReInstall PHP \033[0m"
		echo -e "4.\t\033[36m quit \033[0m"
		read -p "Please input a number:(Default 1 press Enter) " php_oper
		php_case
		[ $? -eq 4 ] && return 0
	done
}

php_case(){
		case $php_oper in
		1)	install_php
			;;
		2)	remove_php 
			;;
		3)	reinstall_php
			;;
		4)	return 4
			;;
		*)
			echo -e "\033[33m input error! Please only input number 1,2,3,4 \033[0m"
		esac
}

#********************************************************************************
lnmp_memu_op(){
	op=1
	echo -e "\t\033[36m LNMP MEMU \033[0m"
	echo -e "1.\t\033[36m Default install LNMP \033[0m"
	echo -e "2.\t\033[36m Custom  install LNMP \033[0m"
	read -p "Please input a number:(Default 1 press Enter) " op
	[ "$op" == "" ] && op=1
	
}
lnmp_memu(){
	echo -e "\t\033[36m LNMP MEMU MEUDLE \033[0m"
	
	echo -e "1.\t\033[36m Deployment of mysql services \033[0m"
	echo -e "2.\t\033[36m Deployment of nginx services \033[0m"
	echo -e "3.\t\033[36m Deployment of php services \033[0m"
	echo -e "4.\t\033[36m quit memu \033[0m"
	read -p "Please input a number:(Default 1 press Enter) " lnmp_oper
	lnmp_memu_case
	[ $? -eq 4 ] && return 4
}
lnmp_memu_case(){
	case $lnmp_oper in
	1)	mysql_memu
		;;
	2)	nginx_memu
		;;
	3)	php_memu
		;;
	4)	return 4 
		;;
	*)
		echo -e "\033[33m input error! Please only input number 1,2,3,4 \033[0m" 
	esac
}
lnmp_default_install(){
	#check_all &>/dev/null
	reinstall_mysql
	reinstall_nginx
	reinstall_php
}


main(){
	check_root
	[ $? -ne 0 ] && exit 1
	lnmp_info
	echo ""
	echo "Press any key to start..."
	char=`get_char`
	set_timezone
	lnmp_memu_op
	[ $op -eq 1 ] && lnmp_default_install && exit 0
	default=0
	while : ; do
		lnmp_memu
		[ $? -eq 4 ] && exit 0
	done
}
######################################################################################
main
