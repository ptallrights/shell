#!/bin/bash
if [ "$1" = "dog" ];then
	echo "cat"
elif [ "$1" = "cat" ];then
	echo "dog"
else
	echo "error"
fi
