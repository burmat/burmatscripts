import csv, sys, os, socket

csvfilename = 'hosts_to_ips-output.csv'

def get_actual_ip(record):
	try:
		return socket.gethostbyname(record)
	except Exception as e:
		return 'Could not resolve. May be stale data.'

if len(sys.argv) > 1:
	domains_file = sys.argv[1]
	if not os.path.exists(domains_file):
		print("[!] Unable to read input file location")
		exit();
else:
	print("[!] No source file provided")
	print("[#] Run: python3 hosts_to_ips.py ~/domains.txt")
	exit();

# create a csv to write data to
with open(csvfilename, mode='a', newline='') as outputfile:
	output_writer = csv.writer(outputfile)
	if os.path.getsize(csvfilename) == 0:
		# add a header row to the new csv file
		output_writer.writerow(['Domain', 'Subdomain', 'IP'])

	with open(domains_file, 'r') as subdomains:
		for sd in subdomains:
			sd = sd.strip().lower()
			resolvedip = get_actual_ip(sd)
			sld = ('.'.join(sd.split('.')[-2:]))
			output_writer.writerow([sld,sd,resolvedip])

print("[#] DONE! Check the output at this filename: %s" % csvfilename)
