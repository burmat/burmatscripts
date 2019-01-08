#!/usr/bin/python3.6
#
# convert decimal IP address (e.g. from snmpwalk) to hex
# (mischief from htb in this case)
ip_dec = "222.173.190.239.0.0.0.0.2.80.86.255.254.178.235.14"
ip_hex = ""
count = 0
for d in ip_dec.split('.'):
	ip_hex = ip_hex + hex(int(d)).split('x')[-1]
	count += 1
	if count%2 == 0:
		ip_hex = ip_hex + ":"

print("decimal format:   {}".format(ip_dec))
print("converted to hex: {}".format(ip_hex[:-1]))
