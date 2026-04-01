#!/usr/bin/env bash
#
# ArchCosta Package Checker
# Verifies that all listed packages exist in the Arch repositories.
# Requires: pacman (run on an Arch system)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_DIR="${SCRIPT_DIR}/../profiles"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "ArchCosta Package Checker"
echo "========================="

if ! command -v pacman &>/dev/null; then
    echo "Error: pacman not found. Run this on an Arch Linux system."
    exit 1
fi

echo "Syncing package database..."
sudo pacman -Sy --noconfirm &>/dev/null

total_missing=0

for pkg_file in "${PROFILES_DIR}"/base/packages.x86_64 "${PROFILES_DIR}"/*/packages.x86_64; do
    [[ ! -f "$pkg_file" ]] && continue
    edition=$(basename "$(dirname "$pkg_file")")
    echo ""
    printf "${YELLOW}--- %s ---${NC}\n" "$edition"

    missing=0
    found=0

    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == \#* ]] && continue

        if pacman -Si "$pkg" &>/dev/null; then
            ((found++))
        else
            printf "  ${RED}NOT FOUND${NC}: %s\n" "$pkg"
            ((missing++))
        fi
    done < "$pkg_file"

    printf "  ${GREEN}Found: %d${NC}  " "$found"
    if [[ $missing -gt 0 ]]; then
        printf "${RED}Missing: %d${NC}\n" "$missing"
    else
        printf "Missing: 0\n"
    fi
    ((total_missing += missing))
done

echo ""
echo "========================="
if [[ $total_missing -gt 0 ]]; then
    printf "${RED}Total missing packages: %d${NC}\n" "$total_missing"
    echo "Some packages may be in the AUR or need custom PKGBUILDs."
    exit 1
else
    printf "${GREEN}All packages verified successfully.${NC}\n"
    exit 0
fi
