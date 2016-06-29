#!/bin/bash
case $1 in
	start)
	systemctl start $2
	;;
	stop)
	systemctl stop $2
	;;
	status)
	systemctl status $2
	;;
	*)
	echo "Use start|stop|status"
esac
