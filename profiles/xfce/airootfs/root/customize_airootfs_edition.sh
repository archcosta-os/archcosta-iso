#!/usr/bin/env bash
# ArchCosta XFCE Edition — Post-build customization
set -euo pipefail

# Enable LightDM
systemctl enable lightdm.service

# Set default session
mkdir -p /var/lib/AccountsService/users
cat > /var/lib/AccountsService/users/liveuser <<EOF
[User]
Session=xfce
XSession=xfce
Icon=/usr/share/archcosta/logo.png
SystemAccount=false
EOF

# Qt theming under XFCE
echo "QT_QPA_PLATFORMTHEME=qt5ct" >> /etc/environment
