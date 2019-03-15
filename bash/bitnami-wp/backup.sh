#!/bin/bash
# BACKUP - BITNAMI, SQL DB, WORDPRESS, CERTIFICATES
# (run on primary server)

TZ=":US/Eastern" date
BACKUP_DIR="/tmp/backup"
WP_USER=`sudo cat /opt/bitnami/apps/wordpress/htdocs/wp-config.php | grep "DB_USER" | awk -F "'" '{print $4}'`
WP_PASS=`sudo cat /opt/bitnami/apps/wordpress/htdocs/wp-config.php | grep "DB_PASSWORD" | awk -F "'" '{print $4}'`

## exit if backup directory exits - force user to remove it
if [ -d "$BACKUP_DIR" ]; then
  echo "[!] $BACKUP_DIR exists! Make sure you don't need this directory, remove/rename it, and re-run this script".
  echo "    You can run 'remove_backups.sh' script to remove it."
  echo "[!] exiting now..."
  exit 1
fi

echo "!! WARNING: SERVICES WILL BE STOPPED !!"
echo "Make sure DNS is pointed to MAINTENANCE page."
echo "_____________________________________________________________________"
echo "    "
read -p "Press ENTER to stop services and continue backup, CTRL+C to quit."

## create a backup directory, move into it:
mkdir $BACKUP_DIR && cd $BACKUP_DIR

## backup database BEFORE shutting down the services:
echo "[#] backing up wordpress database 'bitnami_wordpress' (credentials: $WP_USER:$WP_PASS)"
sudo mysqldump -u $WP_USER -p$WP_PASS bitnami_wordpress > bak-database-bitnami_wordpress-$(date +%m-%d-%Y).sql

## stop the services:
echo "[#] stopping services..."
sudo /opt/bitnami/ctlscript.sh stop

## backup bitnami:
echo "[#] backing up entire bitnami folder (/opt/bitnami)..."
sudo tar -czf bak-bitnami-$(date +%m-%d-%Y).tar.gz /opt/bitnami

## backup wordpress:
echo "[#] backing up the wordpress website (/opt/bitnami/apps/wordpress/htdocs/)..."
sudo tar -czf bak-wordpress-site-$(date +%m-%d-%Y).tar.gz /opt/bitnami/apps/wordpress/htdocs

echo "[#] backing up the wordpress configuration (/opt/bitnami/apps/wordpress/conf/)..."
sudo tar -czf bak-wordpress-conf-$(date +%m-%d-%Y).tar.gz /opt/bitnami/apps/wordpress/conf

## backup certificates (## UPDATE FILENAMES BELOW)
echo "[#] backing up website certificates (/etc/logo/certificates/)..."
sudo cp /etc/lego/certificates/www.burmat.co.key bak-www.burmat.co-$(date +%m-%d-%Y).key
sudo cp /etc/lego/certificates/www.burmat.co.crt bak-www.burmat.co-$(date +%m-%d-%Y).crt

## set permissions in /tmp so we can download:
sudo chmod 777 bak-*

## start services:
echo "[#] starting services..."
sudo /opt/bitnami/ctlscript.sh start


echo "[>] BACKUP COMPLETED TO: $BACKUP_DIR"
echo "___________________________________________________________________"
echo "   "
echo "[*] Run 'remove_backups.sh' on this host after downloading backups"
echo "   "
