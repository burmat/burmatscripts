#!/bin/bash
# RESTORE BACKUPS TO SECONDARY WEBSERVER
# (run on secondary server)

## make sure lego is installed, for Let's Encrypt certs comin'
lego &>/dev/null
if [ $? -eq 0 ]; then
	echo "[>] 'lego' install found. continuing.."
else
	echo "[!] 'lego' not installed. please run 'install_lego.sh'"
	exit 1
fi

## get the root credentials for mysql:
MYSQL_USER="root"
MYSQL_PW=`cat ~/bitnami_credentials | grep "username and password" | awk -F "'" '{print $4}'`

## make sure that corner banner is disabled:
echo "[>] ensuring the bitnami banner is turned off..."
sudo /opt/bitnami/apps/wordpress/bnconfig --disable_banner 1

## disable the bitnami page by commenting it out of  apache conf
echo "[>] ensuring the bitnami info page is disabled..."
sed -i '/banner.conf/s/^/#/g' /opt/bitnami/apache2/conf/httpd.conf

## purge the database:
echo "[>] dropping and re-creating 'bitnami_wordpress' database (creds: $MYSQL_USER:$MYSQL_PW)..."
mysql -u root -p$MYSQL_PW -e "DROP DATABASE bitnami_wordpress; CREATE DATABASE bitnami_wordpress;"

## restore the primary server database here:
echo "[>] restoring primary server database to newly created 'bitnami_wordpress' database..."
mysql -u root -p$MYSQL_PW bitnami_wordpress < $(ls ~/bak-database-bitnami_wordpress*.sql)
rm $(ls ~/bak-database-bitnami_wordpress*.sql)

## restore the certificate files:
echo "[>] moving certificates into place..."
sudo mv $(ls ~/bak-www.burmat.co*.key) /etc/lego/certificates/www.burmat.co.key
sudo mv $(ls ~/bak-www.burmat.co*.crt) /etc/lego/certificates/www.burmat.co.crt

## set the permissions for them:
echo "[>] setting permissions on new certificates..."
sudo chown root:root /etc/lego/certificates/www.burmat.co.crt
sudo chown root:root /etc/lego/certificates/www.burmat.co.key
sudo chmod 0600 /etc/lego/certificates/www.burmat.co.crt
sudo chmod 0600 /etc/lego/certificates/www.burmat.co.key

## from the secondary host, backup the old certs:
echo "[>] backing up original apache certificates (/opt/bitnami/apache2/conf/)..."
sudo mv /opt/bitnami/apache2/conf/server.crt /opt/bitnami/apache2/conf/server.crt.old
sudo mv /opt/bitnami/apache2/conf/server.key /opt/bitnami/apache2/conf/server.key.old
sudo mv /opt/bitnami/apache2/conf/server.csr /opt/bitnami/apache2/conf/server.csr.old

## create the symlink so the server will read them:
echo "[>] creating symlinks for new certificates and setting permissions...."
sudo ln -s /etc/lego/certificates/www.burmat.co.key /opt/bitnami/apache2/conf/server.key
sudo ln -s /etc/lego/certificates/www.burmat.co.crt /opt/bitnami/apache2/conf/server.crt
sudo chown root:root /opt/bitnami/apache2/conf/server*
sudo chmod 0600 /opt/bitnami/apache2/conf/server*

## stop the services so we can restore the site:
echo "[>] stopping services..."
sudo /opt/bitnami/ctlscript.sh stop

## move the conf backup to root, extract, and restore. delete when finished.
echo "[>] restoring wordpress conf/ folder (/opt/bitnami/apps/wordpress/conf/)"
sudo mv $(ls ~/bak-wordpress-conf-*.tar.gz) /wordpress-conf-backup.tar.gz
cd / && sudo tar -xf wordpress-conf-backup.tar.gz --overwrite && cd - &>/dev/null
sudo rm /wordpress-conf-backup.tar.gz

## move the site backup to root, extract, and restore. delete when finished.
echo "[>] restoring wordpress site folder (/opt/bitnami/apps/wordpress/htdocs/)"
sudo mv $(ls ~/bak-wordpress-site-*.tar.gz) /wordpress-site-backup.tar.gz
## it's important to NOT include wp-config.php, because the credentials to to this db ar different!
cd / && sudo tar -xf wordpress-site-backup.tar.gz --exclude='opt/bitnami/apps/wordpress/htdocs/wp-config.php' --overwrite && cd - &>/dev/null
sudo rm /wordpress-site-backup.tar.gz

## check to see if force SSL is enabled on login screen:
cat /opt/bitnami/apps/wordpress/htdocs/wp-config.php | grep "FORCE_SSL_LOGIN"
if [ $? -eq 0 ]; then
	echo "[>] 'force ssl enabled already within wp-config.php - moving on..."
else
	echo "[!] 'force ssl not enabled within wp-config.php - appending to config now..."
	echo "define('FORCE_SSL_LOGIN', true);" >> /opt/bitnami/apps/wordpress/htdocs/wp-config.php
fi

## start services:
echo "[>] starting services..."
sudo /opt/bitnami/ctlscript.sh start

echo "[#] Finished! Check the secondary website (https://<AWS PUBLIC IP>) and hope for the best!"
