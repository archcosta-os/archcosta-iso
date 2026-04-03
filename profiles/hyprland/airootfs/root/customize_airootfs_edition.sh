#!/usr/bin/env bash
# ArchCosta Hyprland Edition — Post-build customization
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
Session=hyprland
XSession=hyprland
Icon=/usr/share/archcosta/logo.png
SystemAccount=false
EOF

# Set environment variables for Hyprland
cat >> /etc/environment <<EOF
XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_TYPE=wayland
MOZ_ENABLE_WAYLAND=1
QT_QPA_PLATFORM=wayland;xcb
SDL_VIDEODRIVER=wayland
EOF

# Set default applications
xdg-mime default org.kde.dolphin.desktop inode/directory
