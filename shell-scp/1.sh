#!/bin/bash
HOUR=2
MIN=2
SEC=6
for ((S=$SEC;S>=0;S--))
do
	echo -n "after $HOUR hour $MIN min $S s end "
	echo -ne "\r	\r"
	sleep 1
	while [ "$HOUR" -ge 0 -a  "$MIN" -ge 1 -a "$S" = 0 ]
	do
	((MIN--))
	S=2
	echo  -n "after $HOUR hour $MIN min $S s end "
        echo -ne "\r    \r"         
        sleep 1
	done
	while [ "$HOUR" -ge 1 -a "$MIN" = 0 -a "$S" = 0 ]
	do
      	((HOUR--))
      	MIN=2
       	S=2
      	echo -n "after $HOUR hour $MIN min $S s end "
      	echo -ne "\r    \r"
      	sleep 1
	done
	while [ "$HOUR" = 0 -a "$MIN" -ge 1 -a "$S" = 0 ]
	do
	((MIN--))
	S=2
	echo -n "after $HOUR hour $MIN min $S s end  "
	echo -ne "\r	\r"
	sleep 1
	done
done
