#!/usr/bin/python3.6
'''

	Program: transfer.py
	Author: burmat
	Date: 01/2019

	Purpose: Use and modify the below template to use with `sftpupload.py`
		(https://github.com/burmat/burmatscripts/blob/master/python/sftpupload.py)

	Usability: Update the parameters in `__main__`, and the the `sftpupload.py` class
		file should handle the rest. Just put a call to this script in cron or at the bottom
		of a Progress/ABL program (e.g. `UNIX SILENT /scripts/transfer.py.`)

'''
from sftpupload import SFTPUpload
from collections import namedtuple

# hold our options in these objects:
trans = namedtuple('Transmission', 'SOURCE_DIR EXT_MASK DEST_DIR ARCHIVE_DIR')
conn = namedtuple('Connection', 'SERVER PORT USER PASS')
log = namedtuple('Logging', 'FILEPATH SIZE')

if __name__ == '__main__':

	## local vars to handle the output:
	print_output = False
	email_output = True

	## remote server we are sending to:
	conn.SERVER = "transfer.burmat.co"
	conn.PORT   = 22
	conn.USER   = "burmat"
	conn.PASS   = "S3cr3tP@ssw0rd" # not needed if using private key
	conn.KEY    = "/home/burmat/.ssh/id_rsa" # the full path to a private key
	
	## file transmission settings
	trans.SOURCE_DIR  = "/data/outbound/"
	trans.EXT_MASK    = "*.csv" # (file mask used for finding files)
	trans.DEST_DIR    = "incoming/"
	trans.ARCHIVE     = True
	trans.ARCHIVE_DIR = "/data/outbound/sent/"
	
	## file to log to:
	log.FILEPATH = "/var/log/sftp_upload.log"
	log.SIZE     = 3500 # (lines to keep)

	## email options (email_output must be True):
	email_from    = "cron@burmat.co"
	email_to      = ["nathan@burmat.co"]
	email_subject = "Template Script/Transfer Complete!"

	'''
		Now to get to work:
		1) Instantiate the SFTPUpload (sftpupload.py) Class
		2) Initiate the transmission
		3) Print the output to screen if the user wants
		4) Email the output if the user wants
	'''
	sftp = SFTPUpload(conn, log)
	sftp.initiate_upload(trans)
	if print_output:
		sftp.print_output()

	if email_output and sftp.PROCESSED_FILES > 0:
		sftp.email_output(email_from, email_to, email_subject)

	## DONE.
