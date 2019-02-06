#!/bin/bash

while [ True ];
do
	ip neighbor show > /tmp/arp_table
	echo "IP	DEV"
	cat /tmp/arp_table
	sleep 1
	clear
done

