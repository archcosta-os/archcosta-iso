# ArchCosta ISO Build Makefile
#
# Usage:
#   make xfce        Build XFCE edition
#   make plasma      Build Plasma edition
#   make gnome       Build GNOME edition
#   make cinnamon    Build Cinnamon edition
#   make all         Build all editions
#   make clean       Remove build artifacts

SHELL := /bin/bash
WORK_DIR ?= /tmp/archcosta-build
OUT_DIR ?= $(CURDIR)/out

.PHONY: all xfce plasma gnome cinnamon clean help

help:
	@echo "ArchCosta ISO Builder"
	@echo ""
	@echo "Targets:"
	@echo "  make xfce        Build XFCE edition (LightDM)"
	@echo "  make plasma      Build Plasma edition (SDDM)"
	@echo "  make gnome       Build GNOME edition (GDM)"
	@echo "  make cinnamon    Build Cinnamon edition (LightDM)"
	@echo "  make all         Build all editions"
	@echo "  make clean       Remove build artifacts"
	@echo ""
	@echo "Options:"
	@echo "  WORK_DIR=/path   Set working directory (default: /tmp/archcosta-build)"
	@echo "  OUT_DIR=/path    Set output directory (default: ./out)"

all: xfce plasma gnome cinnamon

xfce:
	sudo ./build.sh xfce --work-dir $(WORK_DIR) --out-dir $(OUT_DIR)

plasma:
	sudo ./build.sh plasma --work-dir $(WORK_DIR) --out-dir $(OUT_DIR)

gnome:
	sudo ./build.sh gnome --work-dir $(WORK_DIR) --out-dir $(OUT_DIR)

cinnamon:
	sudo ./build.sh cinnamon --work-dir $(WORK_DIR) --out-dir $(OUT_DIR)

clean:
	rm -rf $(WORK_DIR) $(OUT_DIR)
	@echo "Build artifacts cleaned."
