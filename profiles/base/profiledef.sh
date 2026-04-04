#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archcosta-@EDITION@"
iso_label="ARCHCOSTA_@VERSION@"
iso_publisher="ArchCosta OS <https://github.com/archcosta-os>"
iso_application="ArchCosta @EDITION@ Live/Install Medium"
iso_version="@VERSION@"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
            'uefi.systemd-boot')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
    ["/etc/shadow"]="0:0:400"
    ["/etc/gshadow"]="0:0:400"
    ["/root"]="0:0:750"
    ["/root/customize_airootfs.sh"]="0:0:755"
    ["/root/customize_airootfs_edition.sh"]="0:0:755"
    ["/usr/local/bin/archcosta-install"]="0:0:755"
    ["/usr/local/bin/archcosta-welcome"]="0:0:755"
    ["/usr/share/plymouth"]="0:0:755"
)
