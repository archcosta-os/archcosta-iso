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

# Create autologin group and live user
groupadd -r autologin
useradd -m -G wheel,storage,power,video,audio,network,lp,scanner,autologin -s /bin/zsh liveuser
echo "liveuser:liveuser" | chpasswd
echo "root:root" | chpasswd

# Passwordless sudo for live user
install -dm755 /etc/sudoers.d
echo "liveuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/10-liveuser
chmod 440 /etc/sudoers.d/10-liveuser

# Enable core services
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable fstrim.timer
systemctl enable reflector.timer
systemctl enable acpid.service

# Virtual machine guest services
# These units have ConditionVirtualization= guards so they only
# activate inside the matching hypervisor.
systemctl enable vmtoolsd.service
systemctl enable vmware-vmblock-fuse.service
systemctl enable vboxservice.service
systemctl enable qemu-guest-agent.service
systemctl enable spice-vdagentd.service

# Pacman setup
pacman-key --init
pacman-key --populate archlinux

# Set default shell for new users to zsh
sed -i 's|/bin/bash|/bin/zsh|' /etc/default/useradd

# Skip zsh newuser installation wizard for all users
echo "SKIP_ZSH_NEWUSER_INSTALL=1" >> /etc/environment

# Copy skel files to root home (for root user)
cp -r /etc/skel/ /root/

# Enable Plymouth boot splash
if command -v plymouth-set-default-theme &>/dev/null; then
    plymouth-set-default-theme archcosta 2>/dev/null || true
fi

# Set ArchCosta OS identity (after filesystem package)
if [[ -f /usr/lib/os-release.archcosta ]]; then
    cp /usr/lib/os-release.archcosta /usr/lib/os-release
fi
if [[ -f /etc/lsb-release.archcosta ]]; then
    cp /etc/lsb-release.archcosta /etc/lsb-release
fi

# Clean up to reduce ISO size
rm -rf /var/cache/pacman/pkg/*
rm -f /var/log/pacman.log
rm -rf /var/lib/pacman/sync/*

# Run edition-specific customization if present
if [[ -x /root/customize_airootfs_edition.sh ]]; then
    /root/customize_airootfs_edition.sh
    rm /root/customize_airootfs_edition.sh
fi
