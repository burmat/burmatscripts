import os
import hashlib

repo = "/Volumes/repo/"
list = []

def md5file(file):
	return hashlib.md5(open(file, 'rb').read()).hexdigest()

for file in os.listdir(repo):
	if os.path.isdir(repo+file):
		continue

	checksum = md5file(repo + file)

	if checksum in list:
		os.remove(repo+file)
		print('[>] deleting {0}'.format(checksum))
	else:
		list.append(checksum)

