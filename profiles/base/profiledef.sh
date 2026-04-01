#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archcosta-@EDITION@"
iso_label="ARCHCOSTA_@VERSION@"
iso_publisher="ArchCosta OS <https://github.com/archcosta-os>"
iso_application="ArchCosta @EDITION@ Live/Install Medium"
iso_version="@VERSION@"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
            'uefi-ia32.grub.esp' 'uefi-x64.grub.esp'
            'uefi-ia32.grub.eltorito' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')
file_permissions=(
    ["/etc/shadow"]="0:0:400"
    ["/etc/gshadow"]="0:0:400"
    ["/root"]="0:0:750"
    ["/usr/local/bin/archcosta-install"]="0:0:755"
)
