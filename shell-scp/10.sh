#!/bin/bash
for NUM in {1..25}
do
	ping -c1 -w1 172.25.254.$NUM &> /dev/null && (
	/root/Desktop/11.answer $NUM hostname | grep -E -v "spawn|password|ECDSA|authenticity|yes" )
done
