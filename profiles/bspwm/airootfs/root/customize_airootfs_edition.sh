#!/usr/bin/env bash
# ArchCosta bspwm Edition — Post-build customization
set -euo pipefail

systemctl enable lightdm.service

mkdir -p /var/lib/AccountsService/users
cat > /var/lib/AccountsService/users/liveuser <<EOF
[User]
Session=bspwm
XSession=bspwm
Icon=/usr/share/archcosta/logo.png
SystemAccount=false
EOF

echo "QT_QPA_PLATFORMTHEME=qt5ct" >> /etc/environment
