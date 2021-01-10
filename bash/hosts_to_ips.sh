#!/bin/bash


if [[ $# -eq 0 ]] ; then
        echo '[!] Error: please provide a list of hostnames as an argument, e.g.:';
        echo '#   ./hosts_to_ips.sh /tmp/hosts.txt';
        exit 1;
fi

if [[ -f "$1" ]]; then
	cat $1 | while read line
	do
		host $line | grep -v "alias\|not found" | awk -F ' ' '{print $NF}'
	done
fi
