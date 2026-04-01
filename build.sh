#!/usr/bin/env bash
#
# ArchCosta ISO Build Script
# Builds a live/installable ISO for a specified desktop edition.
#
# Usage: ./build.sh <edition> [--work-dir <path>] [--out-dir <path>]
#
# Editions: xfce, plasma, gnome, cinnamon
#

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERSION="$(date +%Y.%m.%d)"
readonly ISO_LABEL="ARCHCOSTA_${VERSION}"

# Defaults
EDITION=""
WORK_DIR="/tmp/archcosta-build"
OUT_DIR="${SCRIPT_DIR}/out"
VERBOSE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

msg() { printf "${GREEN}[archcosta]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[warning]${NC} %s\n" "$1"; }
error() { printf "${RED}[error]${NC} %s\n" "$1" >&2; exit 1; }

usage() {
    cat <<EOF
ArchCosta ISO Builder v${VERSION}

Usage: $(basename "$0") <edition> [options]

Desktop Editions:
    xfce        XFCE desktop with LightDM
    plasma      KDE Plasma desktop with SDDM
    gnome       GNOME desktop with GDM
    cinnamon    Cinnamon desktop with LightDM

Window Manager Editions:
    i3          i3 tiling WM with LightDM
    hyprland    Hyprland Wayland compositor with SDDM
    sway        Sway Wayland compositor with SDDM
    bspwm       bspwm tiling WM with LightDM

Options:
    --work-dir <path>   Working directory (default: /tmp/archcosta-build)
    --out-dir <path>    Output directory (default: ./out)
    --verbose           Enable verbose output
    -h, --help          Show this help message

Examples:
    $(basename "$0") xfce
    $(basename "$0") plasma --out-dir /home/user/iso
    $(basename "$0") gnome --work-dir /mnt/fast-disk/build
EOF
    exit 0
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root. Use: sudo ./build.sh <edition>"
    fi
}

check_dependencies() {
    local deps=(mkarchiso mksquashfs mkfs.fat xorriso)
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing dependencies: ${missing[*]}\nInstall with: pacman -S archiso squashfs-tools dosfstools xorriso"
    fi
}

validate_edition() {
    local valid_editions=(xfce plasma gnome cinnamon i3 hyprland sway bspwm)
    for e in "${valid_editions[@]}"; do
        [[ "$EDITION" == "$e" ]] && return 0
    done
    error "Invalid edition: '$EDITION'. Valid editions: ${valid_editions[*]}"
}

prepare_profile() {
    local profile_dir="${SCRIPT_DIR}/profiles/${EDITION}"
    local build_profile="${WORK_DIR}/profile"

    msg "Preparing ${EDITION} profile..."

    rm -rf "$build_profile"
    mkdir -p "$build_profile"

    # Copy base profile
    cp -a "${SCRIPT_DIR}/profiles/base/"* "$build_profile/"

    # Merge edition-specific profile on top
    if [[ -d "$profile_dir" ]]; then
        cp -a "$profile_dir/"* "$build_profile/"
    else
        error "Profile directory not found: $profile_dir"
    fi

    # Merge package lists: base + edition
    if [[ -f "${SCRIPT_DIR}/profiles/base/packages.x86_64" ]]; then
        cat "${SCRIPT_DIR}/profiles/base/packages.x86_64" >> "$build_profile/packages.x86_64"
    fi

    # Remove duplicate packages and sort
    sort -u "$build_profile/packages.x86_64" -o "$build_profile/packages.x86_64"

    # Set ISO label in profiledef
    sed -i "s|@EDITION@|${EDITION}|g; s|@VERSION@|${VERSION}|g; s|@ISO_LABEL@|${ISO_LABEL}|g" \
        "$build_profile/profiledef.sh"

    msg "Profile ready at: $build_profile"
}

build_iso() {
    local build_profile="${WORK_DIR}/profile"
    local iso_name="archcosta-${EDITION}-${VERSION}-x86_64.iso"

    mkdir -p "$OUT_DIR"

    msg "Building ArchCosta ${EDITION^} Edition ISO..."
    msg "Output: ${OUT_DIR}/${iso_name}"

    mkarchiso -v \
        -w "${WORK_DIR}/work" \
        -o "$OUT_DIR" \
        "$build_profile"

    # Rename to our naming convention
    local built_iso
    built_iso=$(ls -t "${OUT_DIR}"/archcosta-*.iso 2>/dev/null | head -1)
    if [[ -n "$built_iso" && "$built_iso" != "${OUT_DIR}/${iso_name}" ]]; then
        mv "$built_iso" "${OUT_DIR}/${iso_name}"
    fi

    msg "ISO built successfully: ${OUT_DIR}/${iso_name}"

    # Generate checksums
    cd "$OUT_DIR"
    sha256sum "$iso_name" > "${iso_name}.sha256"
    msg "SHA256: $(cat "${iso_name}.sha256")"
}

cleanup() {
    if [[ -d "${WORK_DIR}/work" ]]; then
        msg "Cleaning up work directory..."
        rm -rf "${WORK_DIR}/work"
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        xfce|plasma|gnome|cinnamon|i3|hyprland|sway|bspwm)
            EDITION="$1"
            shift
            ;;
        --work-dir)
            WORK_DIR="$2"
            shift 2
            ;;
        --out-dir)
            OUT_DIR="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            error "Unknown argument: $1. Use --help for usage."
            ;;
    esac
done

[[ -z "$EDITION" ]] && usage

# Main
trap cleanup EXIT
check_root
check_dependencies
validate_edition
prepare_profile
build_iso

msg "ArchCosta ${EDITION^} Edition build complete!"
