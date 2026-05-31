.PHONY: help test install clean format check

help:
	@echo "Quickshell Hyprland Bar - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  test      - Run quickshell with this configuration"
	@echo "  install   - Install via home-manager"
	@echo "  clean     - Kill running quickshell instances"
	@echo "  format    - Format QML files (requires qmlformat)"
	@echo "  check     - Check QML syntax (requires qmllint)"
	@echo "  build     - Build Nix package"
	@echo ""

test:
	@./scripts/test.sh

install:
	@echo "Installing via home-manager..."
	@home-manager switch

clean:
	@echo "Stopping quickshell..."
	@pkill quickshell || echo "No quickshell process found"

format:
	@echo "Formatting QML files..."
	@find qml -name "*.qml" -exec qmlformat -i {} \;

check:
	@echo "Checking QML files..."
	@find qml -name "*.qml" -exec qmllint {} \;

build:
	@echo "Building Nix package..."
	@nix build
