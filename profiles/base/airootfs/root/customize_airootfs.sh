#!/usr/bin/env bash
#
# ArchCosta: Customize the live environment filesystem
# Runs inside the chroot during ISO build.
#

set -euo pipefail

# Locale
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen

# Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Create live user
useradd -m -G wheel,storage,power,video,audio,network,lp,scanner -s /bin/zsh liveuser
echo "liveuser:" | chpasswd -e
echo "root:" | chpasswd -e

# Passwordless sudo for live user
echo "liveuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/10-liveuser
chmod 440 /etc/sudoers.d/10-liveuser

# Enable core services
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable cups.service
systemctl enable firewalld.service
systemctl enable fstrim.timer
systemctl enable reflector.timer
systemctl enable acpid.service

# Pacman setup
pacman-key --init
pacman-key --populate archlinux

# Update pkgfile database
pkgfile --update || true

# Set default shell for new users to zsh
sed -i 's|/bin/bash|/bin/zsh|' /etc/default/useradd
