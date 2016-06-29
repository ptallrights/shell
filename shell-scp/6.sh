#!/bin/bash
if
	[ -z "$1" ]
then
	echo "please input information after the command"
elif
	[ "$1" = "westos" ]
then
	echo linux
elif
	[ "$1" = "linux" ]
then
	echo westos
else
	echo error
fi
