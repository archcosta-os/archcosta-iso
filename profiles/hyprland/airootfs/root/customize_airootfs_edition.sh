#!/usr/bin/env bash
# ArchCosta Hyprland Edition — Post-build customization
set -euo pipefail

systemctl enable sddm.service

mkdir -p /var/lib/AccountsService/users
cat > /var/lib/AccountsService/users/liveuser <<EOF
[User]
Session=hyprland
XSession=hyprland
Icon=/usr/share/archcosta/logo.png
SystemAccount=false
EOF
