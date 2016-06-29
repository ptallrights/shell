#!/bin/bash
read -p "please input network name:" NET
ifconfig $NET | grep inet |grep -v inet6 | awk '{printf $2 "\n"}'
