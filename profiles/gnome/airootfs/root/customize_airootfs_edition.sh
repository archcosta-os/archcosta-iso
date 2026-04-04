#!/usr/bin/env bash
# ArchCosta GNOME Edition — Post-build customization
set -euo pipefail

# Enable GDM
systemctl enable gdm.service

# Enable system services
systemctl enable bluetooth.service
systemctl enable avahi-daemon.service
systemctl enable usbguard.service

# Compile dconf database
dconf update

# Set default session
mkdir -p /var/lib/AccountsService/users
cat > /var/lib/AccountsService/users/liveuser <<EOF
[User]
Session=gnome
XSession=gnome
Icon=/usr/share/archcosta/logo.png
SystemAccount=false
EOF

# Qt theming under GNOME
echo "QT_QPA_PLATFORMTHEME=qt5ct" >> /etc/environment
