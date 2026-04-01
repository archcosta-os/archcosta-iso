#!/usr/bin/env bash
#
# ArchCosta Profile Validator
# Checks all edition profiles for structural integrity, duplicate packages,
# missing configs, and display manager conflicts.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_DIR="${SCRIPT_DIR}/../profiles"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

pass() { printf "  ${GREEN}PASS${NC}  %s\n" "$1"; }
fail() { printf "  ${RED}FAIL${NC}  %s\n" "$1"; ((ERRORS++)); }
warn() { printf "  ${YELLOW}WARN${NC}  %s\n" "$1"; ((WARNINGS++)); }
info() { printf "  ${CYAN}INFO${NC}  %s\n" "$1"; }

DE_EDITIONS=(xfce plasma gnome cinnamon)
WM_EDITIONS=(i3 hyprland sway bspwm)
ALL_EDITIONS=("${DE_EDITIONS[@]}" "${WM_EDITIONS[@]}")

# Display manager mapping
declare -A EXPECTED_DM
EXPECTED_DM[xfce]="lightdm"
EXPECTED_DM[plasma]="sddm"
EXPECTED_DM[gnome]="gdm"
EXPECTED_DM[cinnamon]="lightdm"
EXPECTED_DM[i3]="lightdm"
EXPECTED_DM[hyprland]="sddm"
EXPECTED_DM[sway]="sddm"
EXPECTED_DM[bspwm]="lightdm"

echo "ArchCosta Profile Validator"
echo "=========================="
echo ""

# 1. Check base profile exists
echo "--- Base Profile ---"
if [[ -d "${PROFILES_DIR}/base" ]]; then
    pass "Base profile directory exists"
else
    fail "Base profile directory missing"
fi

if [[ -f "${PROFILES_DIR}/base/packages.x86_64" ]]; then
    base_pkg_count=$(grep -cv '^#\|^$' "${PROFILES_DIR}/base/packages.x86_64" || true)
    pass "Base packages.x86_64 exists (${base_pkg_count} packages)"
else
    fail "Base packages.x86_64 missing"
fi

for f in profiledef.sh pacman.conf; do
    if [[ -f "${PROFILES_DIR}/base/$f" ]]; then
        pass "Base $f exists"
    else
        fail "Base $f missing"
    fi
done

echo ""

# 2. Check each edition
for edition in "${ALL_EDITIONS[@]}"; do
    echo "--- ${edition^} Edition ---"
    profile_dir="${PROFILES_DIR}/${edition}"

    # Profile directory
    if [[ ! -d "$profile_dir" ]]; then
        fail "Profile directory missing: profiles/${edition}/"
        echo ""
        continue
    fi
    pass "Profile directory exists"

    # Packages file
    pkg_file="${profile_dir}/packages.x86_64"
    if [[ -f "$pkg_file" ]]; then
        pkg_count=$(grep -cv '^#\|^$' "$pkg_file" || true)
        pass "packages.x86_64 exists (${pkg_count} edition-specific packages)"

        # Check for display manager in packages
        expected_dm="${EXPECTED_DM[$edition]}"
        if grep -q "^${expected_dm}$" "$pkg_file"; then
            pass "Display manager '${expected_dm}' found in packages"
        else
            fail "Expected display manager '${expected_dm}' NOT found in packages"
        fi

        # Check no competing DMs are included
        all_dms=(lightdm sddm gdm)
        for dm in "${all_dms[@]}"; do
            if [[ "$dm" != "$expected_dm" ]] && grep -q "^${dm}$" "$pkg_file"; then
                fail "Competing display manager '${dm}' found in ${edition} packages (expected only '${expected_dm}')"
            fi
        done

        # Check for duplicate packages within the edition file
        dupes=$(sort "$pkg_file" | grep -v '^#\|^$' | uniq -d)
        if [[ -n "$dupes" ]]; then
            warn "Duplicate packages in ${edition}: ${dupes}"
        else
            pass "No duplicate packages"
        fi
    else
        fail "packages.x86_64 missing"
    fi

    # Customize script
    customize="${profile_dir}/airootfs/root/customize_airootfs_edition.sh"
    if [[ -f "$customize" ]]; then
        pass "customize_airootfs_edition.sh exists"

        # Check it enables the correct DM
        if grep -q "systemctl enable ${expected_dm}" "$customize"; then
            pass "Enables ${expected_dm}.service"
        else
            warn "Does not explicitly enable ${expected_dm}.service"
        fi
    else
        warn "customize_airootfs_edition.sh missing (optional)"
    fi

    # DM config files
    case "$expected_dm" in
        lightdm)
            dm_conf="${profile_dir}/airootfs/etc/lightdm/lightdm.conf"
            if [[ -f "$dm_conf" ]]; then
                pass "LightDM config exists"
                if grep -q "user-session=${edition}" "$dm_conf"; then
                    pass "LightDM session set to '${edition}'"
                else
                    warn "LightDM user-session may not match edition name"
                fi
            else
                fail "LightDM config missing at: ${dm_conf}"
            fi
            ;;
        sddm)
            dm_conf="${profile_dir}/airootfs/etc/sddm.conf.d/archcosta.conf"
            if [[ -f "$dm_conf" ]]; then
                pass "SDDM config exists"
                if grep -q "Session=${edition}" "$dm_conf"; then
                    pass "SDDM session set to '${edition}'"
                else
                    warn "SDDM session may not match edition name"
                fi
            else
                fail "SDDM config missing at: ${dm_conf}"
            fi
            ;;
        gdm)
            dm_conf="${profile_dir}/airootfs/etc/gdm/custom.conf"
            if [[ -f "$dm_conf" ]]; then
                pass "GDM config exists"
            else
                fail "GDM config missing at: ${dm_conf}"
            fi
            ;;
    esac

    echo ""
done

# 3. Cross-edition checks
echo "--- Cross-Edition Checks ---"

# Check no package appears in base AND an edition
base_pkgs="${PROFILES_DIR}/base/packages.x86_64"
for edition in "${ALL_EDITIONS[@]}"; do
    edition_pkgs="${PROFILES_DIR}/${edition}/packages.x86_64"
    [[ ! -f "$edition_pkgs" ]] && continue

    overlap=$(comm -12 \
        <(grep -v '^#\|^$' "$base_pkgs" | sort) \
        <(grep -v '^#\|^$' "$edition_pkgs" | sort) \
    || true)

    if [[ -n "$overlap" ]]; then
        overlap_count=$(echo "$overlap" | wc -l)
        warn "${edition}: ${overlap_count} package(s) duplicated from base (not harmful but redundant)"
    else
        pass "${edition}: No package overlap with base"
    fi
done

echo ""
echo "=========================="
printf "Results: ${GREEN}%d passed${NC}" $(($(grep -c "PASS" <<< "$(echo "")") + 0))
if [[ $ERRORS -gt 0 ]]; then
    printf ", ${RED}%d errors${NC}" "$ERRORS"
fi
if [[ $WARNINGS -gt 0 ]]; then
    printf ", ${YELLOW}%d warnings${NC}" "$WARNINGS"
fi
echo ""

if [[ $ERRORS -gt 0 ]]; then
    echo "Validation FAILED with ${ERRORS} error(s)."
    exit 1
else
    echo "Validation PASSED."
    exit 0
fi
