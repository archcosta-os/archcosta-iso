#!/usr/bin/env bash
# ArchCosta Plasma Edition — Post-build customization
set -euo pipefail

# Enable SDDM
systemctl enable sddm.service

# Set default session
mkdir -p /var/lib/AccountsService/users
cat > /var/lib/AccountsService/users/liveuser <<EOF
[User]
Session=plasma
XSession=plasma
Icon=/usr/share/archcosta/logo.png
SystemAccount=false
EOF
