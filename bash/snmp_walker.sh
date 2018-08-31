#!/bin/bash
for ip in $(cat ~/Documents/labs/targets.txt  | awk '/^[0-9]/ {print $1}'); do
​
	echo "Performing snmpwalk on public tree for" $ip " - Checking for System Processes"	
	snmpwalk -c public -v1 $ip 1.3.6.1.2.1.25.1.6.0 > ~/Documents/labs/$ip/scans/systemprocesses.txt
​
	echo "Performing snmpwalk on public tree for" $ip " - Checking for Running Programs"	
	snmpwalk -c public -v1 $ip 1.3.6.1.2.1.25.4.2.1.2 > ~/Documents/labs/$ip/scans/runningprograms.txt
​
	echo "Performing snmpwalk on public tree for" $ip " - Checking for Processes Path"	
	snmpwalk -c public -v1 $ip 1.3.6.1.2.1.25.4.2.1.4 > ~/Documents/labs/$ip/scans/processespath.txt
​
	echo "Performing snmpwalk on public tree for" $ip " - Checking for Storage Units"	
	snmpwalk -c public -v1 $ip 1.3.6.1.2.1.25.2.3.1.4 > ~/Documents/labs/$ip/scans/storageunits.txt
​
	echo "Performing snmpwalk on public tree for" $ip " - Checking for Software Name"	
	snmpwalk -c public -v1 $ip 1.3.6.1.2.1.25.6.3.1.2 > ~/Documents/labs/$ip/scans/softwarename.txt
​
	echo "Performing snmpwalk on public tree for" $ip " - Checking for User Accouints"	
	snmpwalk -c public -v1 $ip 1.3.6.1.4.1.77.1.2.25 > ~/Documents/labs/$ip/scans/useraccounts.txt
​
	echo "Performing snmpwalk on public tree for" $ip " - Checking for TCP Local Ports"	
	snmpwalk -c public -v1 $ip 1.3.6.1.2.1.6.13.1.3 > ~/Documents/labs/$ip/scans/tcplocalports.txt
​
	echo "Performing snmp-check scan for" $ip	
	snmp-check $ip > ~/Documents/labs/$ip/scans/snmpcheck.txt
	
	echo "Cleaning up empty files..."
	find ~/Documents/labs/$ip/scans/ -size  0 -print0 |xargs -0 rm
done