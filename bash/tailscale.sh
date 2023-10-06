#!/bin/bash

mkdir -p --mode=0755 /usr/share/keyrings;
curl -fsSL "https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg" > /usr/share/keyrings/tailscale-archive-keyring.gpg
curl -fsSL "https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list" > /etc/apt/sources.list.d/tailscale.list
apt-get update -yqq && apt-get install -yqq tailscale tailscale-archive-keyring;
systemctl enable --now tailscaled && systemctl start tailscaled;
if [[ $? -ne 0 ]]; then
  echo -e "[!] Error attempting to install and start Tailscale";
else
  echo -e "[+] Run 'tailscale up' to login and activate your reverse connection.";
fi
