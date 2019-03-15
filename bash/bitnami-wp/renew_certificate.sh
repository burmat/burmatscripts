#!/bin/bash
# RENEW_CERTIFICATE:
# (run on primary server)

lego &>/dev/null

if [ $? -eq 0 ]; then
	echo "[>] 'lego' install found. continuing.."
else
	echo "[!] 'lego' not installed. please run 'install_lego.sh' script"
	exit 1
fi

## stop the services
echo "[>] stopping services:"
sudo /opt/bitnami/ctlscript.sh stop

## renew the certificates (## UPDATE DOMAIN/EMAIL BELOW)
sudo lego --email="burmat@burmat.co" --domains="www.burmat.co" --path="/etc/lego" renew

## start the services
echo "[>] starting services:"
sudo /opt/bitnami/ctlscript.sh start