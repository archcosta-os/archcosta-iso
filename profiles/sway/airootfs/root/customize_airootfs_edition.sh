#!/usr/bin/env bash
# ArchCosta Sway Edition — Post-build customization
set -euo pipefail

systemctl enable sddm.service

mkdir -p /var/lib/AccountsService/users
cat > /var/lib/AccountsService/users/liveuser <<EOF
[User]
Session=sway
XSession=sway
Icon=/usr/share/archcosta/logo.png
SystemAccount=false
EOF
