#!/bin/bash
case "$*" in 
	dog)
		echo "cat"
		;;
	cat)
		echo "dog"
		;;
	*)
		echo "error"
		;;
esac


#if [ "$1" = "dog" ];then
#	echo "cat"
#elif [ "$1" = "cat" ];then
#	echo "dog"
#else
#	echo "error"
#fi
