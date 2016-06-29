#!/bin/bash
if
	[ -z "$1" ]
then
	echo "NULL!"
elif
	[ ! -e "$1" ]
then
	echo "$1 not exist"
elif
	[ -d "$1" ]
then
	echo "$1 is directory"
else
	echo "$1 is file"
fi


