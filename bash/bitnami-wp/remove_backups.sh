#!/bin/bash
# REMOVE ALL BACKUPS
# (run on primary server)

BACKUP_DIR="/tmp/backup"
echo "    "
echo "!! WARNING: ARE YOU SURE YOU WANT TO?? !!"
echo "    "
echo "have you verified you do not need anything in $BACKUPDIR? Here is a listing:"
ls -la $BACKUP_DIR
echo "_____________________________________________________________________"
echo "    "
read -p "Press ENTER to delete $BACKUP_DIR, CTRL+C to quit."
echo "    "
echo "[>] Deleting backup folder: $BACKUP_DIR"

rm -rf $BACKUP_DIR
echo "[#] Done."
