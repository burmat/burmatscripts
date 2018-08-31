#!/bin/bash
#
# get list of packages (rpm or dpkg) and dump them to a grep-able
# format for searchsploit. og credit to chryzsh, modified by burmat
#
# https://burmat.gitbook.io/security/one-liners-and-dirty-scripts#finding-vulnerable-applications-linux
#
#################
# Instructions: #
#################

# 1) Run the following one-liner on the victim:
#
# > FILE="packages.txt"; FILEPATH="/tmp/$FILE"; /usr/bin/rpm -q -f /usr/bin/rpm >/dev/null 2>&1; if [ $? -eq 0 ]; then rpm -qa --qf "%{NAME} %{VERSION}\n" | sort -u > $FILEPATH; echo "kernel $(uname -r)" >> $FILEPATH; else dpkg -l | grep ii | awk '{print $2 " " substr($3,1)}' > $FILEPATH; echo "kernel $(uname -r)" >> $FILEPATH; fi; echo ""; echo "[>] Done. Transfer $FILEPATH to your computer and run: "; echo ""; echo "./packages_compare.sh /path/to/$FILE"; echo "";
#
# 2) Copy the file it generates back to your machine (or any machine with searchsploit)
# 3) Run this script, passing in the filepath:
# >  hello@burmat~$ ./pkg_loookup.sh ~/packages.txt
#
# 4) Wait for something juicy
###################################

if [ ! -k $1 ];  then
	PACKAGES=$1;
	if [ ! -f $PACKAGES ]; then
    	echo "[!] ERROR: File not found!"
    	exit 1
	fi
	# TODO: VERIFY THIS PATH
	EXPLOITS=$(grep -F "/local/" /usr/share/exploitdb/files_exploits.csv | 
			grep -v "windows" | cut -d, -f1-3 | tr --delete \" | 
			awk -F, '{print $3 "\t" $2}' | awk -F' - ' '{print tolower($1) "\t" $2}');
	IFS=$'\n'; 
	for pkg in $(cat $PACKAGES); do 
		## DEBUG - see the terms that are searched
		# echo -n "$pkg => " && echo -n $pkg | awk '{printf $1 " " substr($2,1,2)}'; echo "";
		QUERY=$(echo -n $pkg | awk '{printf $1 " " substr($2,1,2)}')
		echo "$EXPLOITS" | grep "$QUERY" --color
	done
	exit 0
fi
