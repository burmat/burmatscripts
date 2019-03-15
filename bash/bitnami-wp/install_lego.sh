#!/bin/bash
# INSTALL LEGO:
# (run on secondary (new) server)

## download a copy of it
echo "[>] downloading lego to /tmp..."
cd /tmp && curl -s https://api.github.com/repositories/37038121/releases/latest | grep browser_download_url | grep linux_amd64 | cut -d '"' -f4 | wget -i -

echo "[>] extracting lego and moving to /usr/local/bin/lego..."
sudo tar -xf $(ls lego_*_linux_amd64.tar.gz)
sudo mv lego /usr/local/bin/lego && rm $(ls lego_*_linux_amd64.tar.gz)

## this will fail unless DNS is set up properly. either way, do a first run:
echo "[>] first run initiated - WILL likely fail due to DNS resolution failure:"
sudo lego --tls --email="burmat@burmat.co" --domains="www.burmat.co" --path="/etc/lego" run

echo "[#] lego install finished, first run done. you should be able to re-generate certs with (if DNS is configured):"
echo '~# sudo lego --email="burmat@burmat.co" --domains="www.burmat.co" --path="/etc/lego" renew'
echo "   "
echo "but it is recommended to use 'restore_backups.sh' to restore backups of existing certificates"
echo "________________________________________________"
