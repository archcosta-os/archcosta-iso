# ArchCosta ISO Build Makefile
#
# Usage:
#   make xfce        Build XFCE edition
#   make plasma      Build Plasma edition
#   make gnome       Build GNOME edition
#   make cinnamon    Build Cinnamon edition
#   make i3          Build i3 edition
#   make hyprland    Build Hyprland edition
#   make sway        Build Sway edition
#   make bspwm       Build bspwm edition
#   make all-de      Build all desktop editions
#   make all-wm      Build all window manager editions
#   make all         Build everything
#   make clean       Remove build artifacts

SHELL := /bin/bash
WORK_DIR ?= /tmp/archcosta-build
OUT_DIR ?= $(CURDIR)/out

DE_EDITIONS := xfce plasma gnome cinnamon
WM_EDITIONS := i3 hyprland sway bspwm
ALL_EDITIONS := $(DE_EDITIONS) $(WM_EDITIONS)

.PHONY: all all-de all-wm $(ALL_EDITIONS) clean help validate

help:
	@echo "ArchCosta ISO Builder"
	@echo ""
	@echo "Desktop Editions:"
	@echo "  make xfce        XFCE 4 with LightDM (GTK Greeter)"
	@echo "  make plasma      KDE Plasma 6 with SDDM"
	@echo "  make gnome       GNOME with GDM"
	@echo "  make cinnamon    Cinnamon with LightDM (Slick Greeter)"
	@echo ""
	@echo "Window Manager Editions:"
	@echo "  make i3           i3 tiling WM with LightDM"
	@echo "  make hyprland     Hyprland (Wayland) with SDDM"
	@echo "  make sway         Sway (Wayland) with SDDM"
	@echo "  make bspwm        bspwm tiling WM with LightDM"
	@echo ""
	@echo "Batch Targets:"
	@echo "  make all-de      Build all desktop editions"
	@echo "  make all-wm      Build all window manager editions"
	@echo "  make all         Build everything"
	@echo "  make validate    Validate all profiles (no build)"
	@echo "  make clean       Remove build artifacts"
	@echo ""
	@echo "Options:"
	@echo "  WORK_DIR=/path   Set working directory (default: /tmp/archcosta-build)"
	@echo "  OUT_DIR=/path    Set output directory (default: ./out)"

all: $(ALL_EDITIONS)

all-de: $(DE_EDITIONS)

all-wm: $(WM_EDITIONS)

$(ALL_EDITIONS):
	sudo ./build.sh $@ --work-dir $(WORK_DIR) --out-dir $(OUT_DIR)

validate:
	@./scripts/validate-profiles.sh

clean:
	rm -rf $(WORK_DIR) $(OUT_DIR)
	@echo "Build artifacts cleaned."
