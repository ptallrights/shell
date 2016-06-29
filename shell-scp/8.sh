#!/bin/bash
read -p "please input a username:" UAERNAME
read -s -p "please input passwd:" PASSWD
echo "		"
useradd $UAERNAME
echo $PASSWD |passwd --stdin $USERNAME 
