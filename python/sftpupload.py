import glob, os, sys, argparse, datetime, fnmatch, smtplib, pysftp
from shutil import copyfile
from email.mime.text import MIMEText
from collections import namedtuple
'''
	Class file for automated transmission. You can find a template to use this class here:
	> transfer.py - https://github.com/burmat/burmatscripts/blob/master/python/transfer.py
'''
class SFTPUpload:

	def __init__(self, connect, log):

		## sftp server connection variables:
		self.SERVER = connect.SERVER
		self.PORT   = connect.PORT
		self.USER   = connect.USER
		self.PASS   = connect.PASS
		self.KEY    = connect.KEY

		## logging and output variables:
		self.OUTPUT          = []
		self.LOGFILE         = log.FILEPATH
		self.LOGSIZE         = log.SIZE
		self.PROCESSED_FILES = 0

		## email server connection:
		self.EMAIL_SERVER = "smtp.burmat.co"
		self.EMAIL_PORT   = 25

	def initiate_upload(self, trans):
		## grab the time that we are starting with:
		now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
		self.OUTPUT.append("[>] {0} - SFTP Upload Starting".format(now))

		## for each file found in a given directory, upload:
		for file in glob.glob(trans.SOURCE_DIR + trans.EXT_MASK):
			filepath = file
			filename = os.path.basename(file)

			## if any of these steps fail, it will exit the program
			self.upload_file(filepath, trans.DEST_DIR + filename)

			## if we want to archive, archive:
			if trans.ARCHIVE == True:
				if (self.archive_file(filepath, trans.ARCHIVE_DIR + filename)):
					self.delete_file(filepath)
				else:
					self.exit_with_error("Unable to archive file from to {1}".format(archive_to + filename))

			## increment the counter
			self.PROCESSED_FILES += 1

		## feedback on the number of files processed
		self.OUTPUT.append("[#] {0} file(s) processed".format(self.PROCESSED_FILES))

		## grab the endtime of the program
		now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
		self.OUTPUT.append("[X] {0} - SFTP Upload Finished)".format(now))

		self.append_output_to_log()
		self.trim_log_file(self.LOGFILE, self.LOGSIZE)

	## email the OUTPUT
	def email_output(self, msg_from, msg_to, msg_subject):
		# TODO: Try/Catch Exception Handling
		## we have to doublespace for some reason
		email_msg = MIMEText("\r\n\r\n".join(self.OUTPUT))
		email_msg["From"] = msg_from
		email_msg["To"] = ", ".join(msg_to)
		email_msg["Subject"] = msg_subject
		server = smtplib.SMTP(self.EMAIL_SERVER, self.EMAIL_PORT)
		server.sendmail(msg_from, msg_to, email_msg.as_string())
		server.quit()

	## print the output to screen
	def print_output(self):
		for msg in self.OUTPUT:
			print(msg)

	## trim the log file to specified length in lines
	def trim_log_file(self, filepath, logfile_size):
		count = 0 # will keep count of the lines we have
		with open(filepath) as file:
			for line in file:
				count += 1

		## if the file is longer then we want, trim it with `sed`
		if count > logfile_size:
			trim = count - logfile_size
			os.system("sed -i \"1,{0}d\" {1}".format(str(trim), filepath))

	## copy a file from one place to another
	def archive_file(self, source, destination):
		try:
			self.OUTPUT.append("[>] Archiving {0} to {1}".format(source, destination))
			return copyfile(source, destination)
		except Exception as e:
			self.exit_with_error("Unable to archive file with error: {0}".format(e))

	## delete a file (make sure it's archived first!)
	def delete_file(self, filepath):
		try:
			os.remove(filepath)
		except Exception as e:
			self.exit_with_error("Unable to remove file with error: {0}".format(e))

	## upload a file given a source and destination
	def upload_file(self, source, destination):
		try:
			cnopts = pysftp.CnOpts()
			cnopts.hostkeys = None

			if (self.KEY != "" and self.KEY != "<PRIVATE_KEY_PATH>"):
				self.OUTPUT.append("[>] Attempting connection to [{0}:{1}] with private key for user [{2}]".format(self.SERVER, self.PORT, self.USER))
				transfer = pysftp.Connection(host=self.SERVER, port=self.PORT, username=self.USER, private_key=self.KEY, cnopts=cnopts)
			else:
				self.OUTPUT.append("[>] Attempting connection to [{0}:{1}] with passphrase for user [{2}]".format(self.SERVER, self.PORT, self.USER))
				transfer = pysftp.Connection(host=self.SERVER, port=self.PORT, username=self.USER, password=self.PASS, cnopts=cnopts)

			self.OUTPUT.append("[>] Attempting to upload {0} to {1}".format(source, destination))
			transfer.put(source, destination)

			self.OUTPUT.append("[#] {0} Uploaded".format(source))

			transfer.close()
		except Exception as e:
			if "The requested file does not exist" in repr(e):
				'''
					If the file get's sucked in right away, this might throw an exception - continue
					gracefully if this happens
				'''
				pass
			else:
				self.OUTPUT.append("[!] UPLOAD FAILURE.")
				self.exit_with_error(e)

	## log the output to file and exit with error code 1
	def exit_with_error(self, message):
        	self.OUTPUT.append("[!] An exception caused the program to exit: {0}".format(message))
        	self.append_output_to_log()
        	sys.exit("[!] {0}".format(repr(message)))

	## append OUTPUT to file (line by line)
	def append_output_to_log(self):
		with open(self.LOGFILE, "a") as file:
			file.write("\n")
			for msg in self.OUTPUT:
				file.write(msg + "\n")
