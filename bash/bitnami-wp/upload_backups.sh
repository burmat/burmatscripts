#!/bin/bash
# UPLOAD BACKUPS TO SECONDARY WEBSERVER
# (run on staging server)

LOC_DNS_RECORD=`cat /etc/hosts | grep burmat-secondary.co | cut -f1 -d ' '`
BACKUP_DIR="/apps/aws/backups"
SCRIPTS_DIR="/apps/aws/scripts"
SSH_KEY="/apps/aws/keys/burmatcorp.pem"

## in case this is a new server (it will have diff fingerprint)
echo "[>] removing host key.."
ssh-keygen -f "/root/.ssh/known_hosts" -R burmat-secondary.co

echo "!! WARNING: VERIFY SECONDARY IP BEFORE CONTINUING !!"
echo "Verify that 'BURMAT.CO - Secondary' Matches this IP:"
echo "    LOCAL DNS RECORD: $LOC_DNS_RECORD"
echo "    "
echo "If they do not match, QUIT this script and go update your"
echo "'/etc/hosts' to contain the Public IP documented in AWS:"
echo "    "
echo "<AWS PUBLIC IP>    burmat-secondary.co"
echo "    "
echo "________________________________________________"
read -p "Press ENTER to continue backup, CTRL+C to quit."
echo "   "

cd $BACKUP_DIR

echo "[>] archiving full bitnami backup for safe keeping."
mv $(ls bak-bitnami-*.tar.gz) archive/

echo "[>] uploading backup files to secondary server (/home/bitnami/):"
scp -o "StrictHostKeyChecking no" -i $SSH_KEY $BACKUP_DIR/bak* bitnami@burmat-secondary.co:/home/bitnami/.

echo "[>] uploading restore script to secondary server (/home/bitnami/):"
scp -o "StrictHostKeyChecking no" -i $SSH_KEY $SCRIPTS_DIR/restore_backups.sh bitnami@burmat-secondary.co:/home/bitnami/.

echo "[>] uploading lego installation script, in case it is not installed (/home/bitnami/):"
scp -o "StrictHostKeyChecking no" -i $SSH_KEY $SCRIPTS_DIR/install_lego.sh bitnami@burmat-secondary.co:/home/bitnami/.

echo "[>] moving backup files to archive and exiting..."
mv bak* archive/
cd - &> /dev/null
