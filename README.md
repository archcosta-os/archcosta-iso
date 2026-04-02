# ArchCosta ISO Builder

Build system for ArchCosta OS live/installable ISO images. Based on [archiso](https://wiki.archlinux.org/title/Archiso).

## Editions

### Desktop Environments

| Edition | Desktop | Display Manager | Status |
|---------|---------|----------------|--------|
| XFCE | XFCE 4 | LightDM (GTK Greeter) | Stable |
| Plasma | KDE Plasma 6 | SDDM | Stable |
| GNOME | GNOME 46+ | GDM | Stable |
| Cinnamon | Cinnamon | LightDM (Slick Greeter) | Stable |

### Window Managers

| Edition | WM | Display Manager | Status |
|---------|---------|----------------|--------|
| i3 | i3-wm (X11) | LightDM (GTK Greeter) | Stable |
| Hyprland | Hyprland (Wayland) | SDDM | Stable |
| Sway | Sway (Wayland) | SDDM | Stable |
| bspwm | bspwm (X11) | LightDM (GTK Greeter) | Stable |

## Live Session Credentials

| User | Password |
|------|----------|
| `liveuser` | `liveuser` |
| `root` | `root` |

> These credentials are for the **live ISO session only**. The installed system sets its own passwords via Calamares.

## Requirements

```bash
sudo pacman -S archiso squashfs-tools dosfstools xorriso
```

## Build

```bash
# Build a specific edition
sudo ./build.sh xfce
sudo ./build.sh plasma
sudo ./build.sh hyprland
sudo ./build.sh sway

# Or use make
make xfce
make all-de       # All desktop editions
make all-wm       # All window manager editions
make all          # Everything
```

Output ISOs are written to `./out/`.

## Validation

```bash
# Validate all profiles (structure, DM assignment, package conflicts)
make validate

# Check that all packages exist in Arch repos
./scripts/check-packages.sh
```

## Project Structure

```
profiles/
├── base/                  # Shared base profile (merged into every edition)
│   ├── airootfs/          # Root filesystem overlay
│   ├── packages.x86_64   # Base packages (116 shared packages)
│   ├── pacman.conf        # Pacman configuration
│   ├── profiledef.sh      # archiso profile definition
│   ├── grub/              # GRUB bootloader config
│   ├── syslinux/          # Syslinux bootloader config
│   └── efiboot/           # EFI boot config
├── xfce/                  # XFCE-specific overlay + packages
├── plasma/                # Plasma-specific overlay + packages
├── gnome/                 # GNOME-specific overlay + packages
├── cinnamon/              # Cinnamon-specific overlay + packages
├── i3/                    # i3 WM overlay + packages
├── hyprland/              # Hyprland overlay + packages
├── sway/                  # Sway overlay + packages
└── bspwm/                 # bspwm overlay + packages
scripts/
├── validate-profiles.sh   # Profile integrity checker
└── check-packages.sh      # Package availability checker
.github/workflows/
└── validate.yml           # CI pipeline
```

Each edition directory contains only the packages and configs unique to that DE/WM. The build script merges `base/` + `<edition>/` into a single profile before invoking `mkarchiso`. No cross-edition contamination.

## License

GPL-3.0
