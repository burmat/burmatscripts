#!/bin/bash
# SET UPDATE PERMISSIONS
# (run on primary server)

echo "[>] setting owner to daemon - get ready to run updates.."
sudo chown -R daemon:daemon /opt/bitnami/apps/wordpress/htdocs

echo "!! RUN YOUR WORDPRESS PDATES NOW! COME BACK WHEN FINISHED !!"
echo "    "
echo "After you are done running your wordpress updates, press ENTER!"
echo "    "
echo "_______________________________________"
read -p "Press ENTER when finished updating to set permissions back."
echo "    "

echo "[>] setting owner to bitnami.."
sudo chown -R bitnami:daemon /opt/bitnami/apps/wordpress/htdocs

echo "[#] done."