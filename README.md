# ArchCosta ISO Builder

Build system for ArchCosta OS live/installable ISO images. Based on [archiso](https://wiki.archlinux.org/title/Archiso).

## Editions

| Edition | Desktop | Display Manager | Status |
|---------|---------|----------------|--------|
| XFCE | XFCE 4 | LightDM (GTK Greeter) | Stable |
| Plasma | KDE Plasma 6 | SDDM | Stable |
| GNOME | GNOME 46+ | GDM | Stable |
| Cinnamon | Cinnamon | LightDM (Slick Greeter) | Stable |

## Requirements

```bash
sudo pacman -S archiso squashfs-tools dosfstools xorriso
```

## Build

```bash
# Build a specific edition
sudo ./build.sh xfce
sudo ./build.sh plasma
sudo ./build.sh gnome
sudo ./build.sh cinnamon

# Or use make
make xfce
make all
```

Output ISOs are written to `./out/`.

## Project Structure

```
profiles/
├── base/                  # Shared base profile (merged into every edition)
│   ├── airootfs/          # Root filesystem overlay
│   ├── packages.x86_64   # Base packages (shared)
│   ├── pacman.conf        # Pacman configuration
│   ├── profiledef.sh      # archiso profile definition
│   ├── grub/              # GRUB bootloader config
│   ├── syslinux/          # Syslinux bootloader config
│   └── efiboot/           # EFI boot config
├── xfce/                  # XFCE-specific overlay + packages
├── plasma/                # Plasma-specific overlay + packages
├── gnome/                 # GNOME-specific overlay + packages
└── cinnamon/              # Cinnamon-specific overlay + packages
```

Each edition directory contains only the packages and configs unique to that DE. The build script merges `base/` + `<edition>/` into a single profile before invoking `mkarchiso`.

## License

GPL-3.0
