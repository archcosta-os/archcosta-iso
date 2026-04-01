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
echo "liveuser:" | chpasswd -e
echo "root:" | chpasswd -e

# Passwordless sudo for live user
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

# Run edition-specific customization if present
if [[ -x /root/customize_airootfs_edition.sh ]]; then
    /root/customize_airootfs_edition.sh
    rm /root/customize_airootfs_edition.sh
fi
