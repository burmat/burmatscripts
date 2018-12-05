#!/usr/bin/python3.6

#####################################################################
# Created By: burmat
# Created On: 12/2018
# 
# Purpose: One script to get EDI files from point A -> B. Works
# 	well from cron. Let it rain all of the crons.
#
# Parameters:
# 	--method = The transfer method - (upload or download)
# 	--files = The types of files you want to transmit 
#
# Usage Example - Download 850 files from EDI server:
# 	./edi_transfer.py --method download --files 850
#
# The main method function will have the logic for what fires
# where. Update that when you want to add a new file type or new
# features.	
#
# At the end, whatever is in the list "OBJECT" will get logged
# to file. If files are transmitted, and email is set. It will
# Also trim up the length of the file.
#
# If you want to add recipients to get emails for particular
# file transmissions, do so in the main function. search for
# "ap@burmat.co" to see an example.
#####################################################################

## required:
import glob, os, sys, argparse, datetime, fnmatch, smtplib, pysftp as sftp
from shutil import copyfile
from email.mime.text import MIMEText

EDI_SERVER="177.66.55.123"				## EDI Server
EDI_USERNAME="BURMAT" 					## SFTP Username
EDI_PASSWORD="BURMAT123" 				## SFTP Password
EDI_PORT=22 							## SFTP Port


LOG_FILE="~/scripts/output/" 			## Where to log the output (updated in main)
TOTAL_LOG_SIZE=1500						## amount of lines to keep in log files (history)
PROCESSED_FILES=0 						## The number of files processed
OUTPUT=[] 								## String array to hold our output (line by line)

'''
NOTE: you can use: `EMAIL_TO.append("another.email@burmat.co")` 
in main function below to add more recipients for particular 
methods/file types. search for `ap@burmat.co` for an example.

Update for your server. In this case, we will use on-prem anon relay
'''
EMAIL_SERVER="mail.burmat.co"
EMAIL_TO=["info@burmat.co"]
EMAIL_FROM="edi_transfer@burmat.co"


## log the output to file and exit with error code 1
def exit_with_error(message):
	OUTPUT.append("[!] An exception caused the program to exit: {0}".format(message))
	append_output_to_log()
	sys.exit("[!] {0}".format(message))

## append OUTPUT to file (line by line)
def append_output_to_log():
	with open(LOG_FILE, "a") as file:
		file.write("\n")
		for msg in OUTPUT:
			file.write(msg + "\n")

## trim the log file to specified length in lines
def trim_log_file(filepath):
	count = 0 # will keep count of the lines we have
	with open(filepath) as file:
		for line in file:
			count += 1

	## if the file is longer then we want, trim it with `sed`
	if count > TOTAL_LOG_SIZE:
		trim = count - TOTAL_LOG_SIZE
		os.system("sed -i \"1,{0}d\" {1}".format(str(trim), filepath))

## get a total size (KB) of a given file
def get_file_size(filepath):
	## convert bytes to KB and return as string
	return str(round(os.path.getsize(filepath) / 1024.00, 2)) + "KB";

## upload a file given a source and destination
def upload_file(source, destination):
	OUTPUT.append("[>] Attempting to upload {0} to {1}".format(source, destination))
	try:
		transfer= sftp.Connection(host=EDI_SERVER, port=EDI_PORT, username=EDI_USERNAME, password=EDI_PASSWORD)
		transfer.put(source, destination, preserve_mtime=True)
		OUTPUT.append("[#] {0} Uploaded".format(source))
		transfer.close()
	except Exception as e:
		exit_with_error(e)

## download files based on an extension mask
def download_files(source_dir, ext_mask, destination):

	## make sure we are updating the global counter
	global PROCESSED_FILES

	## we can't do a bulk dl using ext mask, we have to get dirlist first:	
	try:
		transfer= sftp.Connection(host=EDI_SERVER, port=EDI_PORT, username=EDI_USERNAME, password=EDI_PASSWORD)
		for filename in transfer.listdir(source_dir):
			if (fnmatch.fnmatch(filename, ext_mask)): # if the filename matches the ext mask
				OUTPUT.append("[>] Attempting to download {0}{1} to {2}{1}".format(source_dir, filename, destination))
				transfer.get(source_dir + filename, destination + filename, preserve_mtime=True)
				OUTPUT.append("[#] Download complete for {0} [{1}]".format(filename, get_file_size(destination + filename)))
				PROCESSED_FILES += 1
		transfer.close()
	except Exception as e:
		exit_with_error(e)

## copy a file from one place to another
def archive_file(source, destination):
	try:
		OUTPUT.append("[>] Archiving {0} to {1}".format(source, destination))
		return copyfile(source, destination)
	except Exception as e:
		exit_with_error("Unable to archive file with error: {0}".format(e))


## delete a file (make sure it's archived first!)
def delete_file(filepath):
	try:
		os.remove(filepath)
	except Exception as e:
		exit_with_error("Unable to remove file with error: {0}".format(e))

## email the OUTPUT
def email_output(email_subject):
	## we have to doublespace for some reason
	email_msg = MIMEText("\r\n\r\n".join(OUTPUT))
	email_msg["From"] = EMAIL_FROM
	email_msg["To"] = ", ".join(EMAIL_TO)
	email_msg["Subject"] = email_subject
	server = smtplib.SMTP(EMAIL_SERVER, 25)
	server.sendmail(EMAIL_FROM, EMAIL_TO, email_msg.as_string())
	server.quit()


## main function:
if __name__ == '__main__':

	## help and parameters:
	parser = argparse.ArgumentParser(description="Upload/Download EDI Files.")
	parser.add_argument('--method', help="upload or download", required=True)
	parser.add_argument('--files', help="850, 832, or 810", required=True)
	args = parser.parse_args()

	## get the options given
	transfer_type = args.method;
	file_type = args.files;

	## grab the time that we are starting with:
	now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
	OUTPUT.append("[#] {0} - Program Starting ({1} / {2})".format(now, file_type, transfer_type))

	# exit if the values are not correct:
	if transfer_type not in ("upload", "download"):
		exit_with_error("Incorrect transfer type provided.")
	elif file_type not in ("850", "832", "810"):
		exit_with_error("Incorrect file type provided.")

	## update the log file location:
	LOG_FILE = LOG_FILE + transfer_type + "_" + file_type + "_transfer.log"

	## if we want to upload something:
	if transfer_type == 'upload':
		
		if file_type == "850":
			upload_from = "~/data/outbound/"
			upload_ext = "*.csv"
			upload_to = "inbound/"
			archive_to = "~/data/uploaded/"
		
		elif file_type == "810":
			upload_from = "~/data/outbound/"
			upload_ext = "*.810"
			archive_to = "~/data/uploaded/"

		elif file_type == "832":
			upload_from = "~/data/outbound/"
			upload_ext = "*.832"
			upload_to = "inbound/"
			archive_to = "~/data/uploaded/"

		## FILE TYPE NOT SUPPORTED
		else:
			exit_with_error("Option '{0}' not supported with transfer type '{1}'".format(file_type, transfer_type))

		## for each file found in a given directory, upload:
		for file in glob.glob(upload_from + upload_ext):
			filepath = file
			filename = os.path.basename(file)

			## if any of these steps fail, it will exit the program
			upload_file(filepath, upload_to + filename)
			if (archive_file(filepath, archive_to + filename)):
				delete_file(filepath)
			else:
				exit_with_error("Unable to archive file from to {1}".format(archive_to + filename))

			## increment the counter
			PROCESSED_FILES += 1
	

	## if we want to download something:
	elif transfer_type == 'download':

		## CUSTOMER PO'S DOWNLOAD
		if file_type == "850":
			download_from = "outbound/"
			download_ext = "*.850"
			download_to = "~/data/downloaded/"

		## VENDOR INVOICE DOWNLOAD
		elif file_type == "810":
			download_from = "outbound/"
			download_ext = "*.810"
			download_to = "~/data/downloaded"
			EMAIL_TO.append("ap@burmat.co")

		## FILE TYPE NOT SUPPORTED
		else:
			exit_with_error("Option '{0}' not supported with transfer type '{1}'".format(file_type, transfer_type))

		## attempt to run the download
		download_files(download_from, download_ext, download_to)

	## feedback on the number of files processed
	OUTPUT.append("[>] {0} files where processed for {1} file {2}".format(PROCESSED_FILES, file_type, transfer_type))

	## grab the endtime of the program
	now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
	OUTPUT.append("[#] {0} - Program Finished ({1} / {2})".format(now, file_type, transfer_type))

	## append the log output to file:
	append_output_to_log()

	## trim the log file if its too long
	trim_log_file(LOG_FILE)

	## send an email if files were actually uploaded/downloaded
	if PROCESSED_FILES > 0:
		email_output("{0} file {1} has been completed!".format(file_type, transfer_type))