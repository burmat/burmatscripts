#!/bin/bash

which nmap &>/dev/null || { echo '[!] nmap not found. exiting..' ; exit 1; }

if [[ $# -eq 0 ]] ; then 
	echo '[!] Error: please provide a list of scopes as an argument, e.g.:';
	echo '#   ./subnet_to_cidr.sh /tmp/scopes.txt';
	exit 1;
fi

if [[ -f "$1" ]]; then
	cat $1 | while read line 
	do
		nmap -sL -n $line | awk '/Nmap scan report/{print $NF}';
	done
else
	echo '[!] input file "$1" not found. exiting..';
	exit 1; 
fi
