#!/usr/bin/env bash
# ArchCosta Cinnamon Edition — Post-build customization
set -euo pipefail

# Enable SDDM
systemctl enable sddm.service

# Set default session
mkdir -p /var/lib/AccountsService/users
cat > /var/lib/AccountsService/users/liveuser <<EOF
[User]
Session=cinnamon
XSession=cinnamon
Icon=/usr/share/archcosta/logo.png
SystemAccount=false
EOF

# Qt theming under Cinnamon
echo "QT_QPA_PLATFORMTHEME=qt5ct" >> /etc/environment
