#!/usr/bin/env bash
# ArchCosta i3 Edition — Post-build customization
set -euo pipefail

systemctl enable sddm.service

mkdir -p /var/lib/AccountsService/users
cat > /var/lib/AccountsService/users/liveuser <<EOF
[User]
Session=i3
XSession=i3
Icon=/usr/share/archcosta/logo.png
SystemAccount=false
EOF

echo "QT_QPA_PLATFORMTHEME=qt5ct" >> /etc/environment
