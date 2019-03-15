#!/bin/bash
# DOWNLOAD BACKUPS
# (run on staging server)

PUB_DNS_RECORD=`dig +short www.burmat.co`
LOC_DNS_RECORD=`cat /etc/hosts | grep burmat-primary.co | cut -f1 -d ' '`
BACKUP_DIR="/apps/aws/backups"
SSH_KEY="/apps/aws/keys/burmatcorp.pem"

echo "!! WARNING: VERIFY PRIMARY IP BEFORE CONTINUING !!"
echo "These two IP's should match:"
echo "	PUBLISHED DNS RECORD: $PUB_DNS_RECORD"
echo "	    LOCAL DNS RECORD: $LOC_DNS_RECORD"
echo "    "
echo "If they do not, QUIT this script and go update your '/etc/hosts' file to contain:"
echo "$PUB_DNS_RECORD    burmat-primary.co"
echo "    "
echo "______________________________________________"
read -p "Press ENTER to continue backup, CTRL+C to quit."

cd $BACKUP_DIR
scp -i $SSH_KEY bitnami@burmat-primary.co:/tmp/backup/bak* .

echo "   "
echo "[>] download of backup files completed!"
echo "[*] don't forget to run 'remove_backup.sh' on primary server."
