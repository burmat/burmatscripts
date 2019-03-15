## BITNAMI (WORDPRESS) Util Scripts

I like to have one primary server up and running WP with a secondary on standby. I leverage the scripts in this folder to backup the primary server, download the backups locally for long-term storage, and upload them to a secondary server in AWS. This makes it trivial to re-create our website from a specific backup date. Leveraging DNS makes it possible to re-target the secondary server while the primary is brought down for maintenance. This enables me to test the new WP upgrades and only correct DNS when testing on the primary is concluded. It also means I have a secondary server on standby to cut over to in the case of problems on the primary.

#### Certificate Names/Hostnames are hardcoded - make sure you read the scripts before running them

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
