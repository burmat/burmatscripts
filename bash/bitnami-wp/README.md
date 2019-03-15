## BITNAMI (WORDPRESS) Util Scripts

I like to have one primary server up and running WP with a secondary on standby. I leveage the scripts in this folder to backup the primary server, download the backups locally for long-term storage, and upload them to a secondary server. This makes it trivial to recreate our website for a specific backup date.

I can then leverage DNS to point to the secondary server while I bring the primary down for maintenance (WP Updates, plugin updates, etc..). This enables me to test the new WP upgrades and only direct visiters there when testing is concluded. It also means I have a secondary server on standby to cut over to in the case of problems on the primary.

### !! Certificate/Hostnames are hardcoded - make sure you read the scripts before running them

| Filename        | Description                                                                          |
|-----------------|--------------------------------------------------------------------------------------|
| [backup.sh](https://github.com/burmat/burmatscripts/blob/master/bash/bitnami-wp/backup.sh) | Backup the bitnami server site, certs, and configurations |
| [download_backups.sh](https://github.com/burmat/burmatscripts/blob/master/bash/bitnami-wp/download_backups.sh) | Download the backups from the bitnami server to staging server |
| [install_lego.sh](https://github.com/burmat/burmatscripts/blob/master/bash/bitnami-wp/install_lego.sh) | Install lego on a new server |
| [remove_backups.sh](https://github.com/burmat/burmatscripts/blob/master/bash/bitnami-wp/remove_backups.sh) | Remove the backups from a bitnami server |
| [renew_certificate.sh](https://github.com/burmat/burmatscripts/blob/master/bash/bitnami-wp/renew_certificate.sh) | Renew the certificate (primary server only!) |
| [restore_backups.sh](https://github.com/burmat/burmatscripts/blob/master/bash/bitnami-wp/restore_backups.sh) | Restore the backups to the server and set configurations |
| [set_update_permissions.sh](https://github.com/burmat/burmatscripts/blob/master/bash/bitnami-wp/set_update_permissions.sh) | Set the permissions needed to get WP updated |
| [upload_backups.sh](https://github.com/burmat/burmatscripts/blob/master/bash/bitnami-wp/upload_backups.sh) | Upload all backup files and scripts to secondary server |
|                 |                                                                                      |
