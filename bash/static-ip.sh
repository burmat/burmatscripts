#!/bin/bash
#: A script to interactively set the /etc/network/interfaces file - 
#: primarily for clients to use with the command `static-ip`.

# set the adapter name
ETH_ADAPTER_NAME="eth0";
if [ $(ifconfig | grep -i "ens192" &>/dev/null; echo $?;) -eq "0" ]; then
	ETH_ADAPTER_NAME="ens192";
# else if - "adapter name" (TODO?)
fi

# only back up the og interfaces file - don't backup altered copies
if [ ! -f "/etc/network/interfaces.og.bak" ]; then
	echo -e "[i] Original interfaces file has been backed up here: /etc/network/interfaces.og.bak";
	cp "/etc/network/interfaces" "/etc/network/interfaces.og.bak";
fi

# collect the settings the user wants:
echo -e "IP Address:" && read ETH_IP_ADDR;
echo -e "Netmask:" && read ETH_BROADCAST;
echo -e "Gateway:" && read GATEWAY_ADDR;

# write the file
echo -e "\n[+] Setting Static IP...\n";
cat << EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

allow-hotplug ${ETH_ADAPTER_NAME}
iface ${ETH_ADAPTER_NAME} inet static 
    address ${ETH_IP_ADDR}
    netmask ${ETH_BROADCAST}
    gateway ${GATEWAY_ADDR}
EOF

echo -e "\nPlease review the interfaces file to verify it appears correct:\n";

# print the results for confirmation
cat /etc/network/interfaces;

# confirm required - either bounce the network or restore the og file
while true; do
	read -p "Do you want to proceed? (y/n) " yn;
	case $yn in 
		y )
			echo -e "[+] Bouncing the interface";
			if [ $(ip a s ${ETH_ADAPTER_NAME} | grep 'state UP' &> /dev/null; echo $?;) -eq "0" ]; then
				ifdown ${ETH_ADAPTER_NAME} &> /dev/null;
			fi
			ifup ${ETH_ADAPTER_NAME};
			echo -e "[+] Restarting networking services";
			systemctl restart networking;
			systemctl restart NetworkManager;
			systemctl restart openvpn;
			echo -e "[:] All set! Bye! :)";
			break;
			;;
		n )
			echo -e "[+] Reverting to original interfaces file and exiting";
			cp "/etc/network/interfaces.og.bak" "/etc/network/interfaces";
			echo -e "[:] Bye! :)";
			exit 0;
			;;
		* ) echo -e "[!] Invalid response - please use 'y' or 'n' only.";
			;;
	esac
done

exit 0
