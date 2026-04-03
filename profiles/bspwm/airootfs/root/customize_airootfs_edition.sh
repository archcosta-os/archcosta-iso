#!/usr/bin/env bash
# ArchCosta bspwm Edition — Post-build customization
set -euo pipefail

# Enable SDDM
systemctl enable sddm.service

# Enable pipewire services
systemctl --user enable pipewire.service
systemctl --user enable wireplumber.service

# Set default session
mkdir -p /var/lib/AccountsService/users
cat > /var/lib/AccountsService/users/liveuser <<EOF
[User]
Session=bspwm
XSession=bspwm
Icon=/usr/share/archcosta/logo.png
SystemAccount=false
EOF

# Set Qt theming
echo "QT_QPA_PLATFORMTHEME=qt5ct" >> /etc/environment
