#!/usr/bin/env bash
# Verification script for Quickshell Hyprland Bar

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_DIR"

echo "=== Quickshell Bar Verification ==="
echo

# Check 1: Flake validity
echo "✓ Checking flake validity..."
if nix flake check 2>&1 | grep -q "all checks passed"; then
    echo "  ✓ Flake is valid"
else
    echo "  ✗ Flake check failed"
    exit 1
fi
echo

# Check 2: Package build
echo "✓ Testing package build..."
rm -f result
if nix build --no-link 2>&1 > /dev/null; then
    echo "  ✓ Package builds successfully"
else
    echo "  ✗ Package build failed"
    exit 1
fi
echo

# Check 3: Required files
echo "✓ Checking required files..."
REQUIRED_FILES=(
    "qml/shell.qml"
    "qml/Theme.qml"
    "qml/qmldir"
    "qml/manifest.json"
    "nix/module.nix"
    "nix/default.nix"
    "flake.nix"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ Missing: $file"
        exit 1
    fi
done
echo

# Check 4: QML files
echo "✓ Checking QML components..."
QML_COUNT=$(find qml -name "*.qml" -type f | wc -l)
echo "  ✓ Found $QML_COUNT QML components"
echo

# Check 5: Module structure
echo "✓ Checking module structure..."
if nix eval --json .#homeManagerModules.default --apply 'x: true' 2>&1 > /dev/null; then
    echo "  ✓ Home Manager module is valid"
else
    echo "  ✗ Module evaluation failed"
    exit 1
fi
echo

# Check 6: Package contents
echo "✓ Checking package contents..."
if nix build --no-link 2>&1 > /dev/null; then
    nix build
    if [ -d "result/share/quickshell" ]; then
        FILE_COUNT=$(find result/share/quickshell -type f | wc -l)
        echo "  ✓ Package contains $FILE_COUNT files"
        
        # Check for essential files in package
        if [ -f "result/share/quickshell/shell.qml" ]; then
            echo "  ✓ shell.qml included"
        fi
        if [ -f "result/share/quickshell/Theme.qml" ]; then
            echo "  ✓ Theme.qml included"
        fi
        if [ -f "result/share/quickshell/qmldir" ]; then
            echo "  ✓ qmldir included"
        fi
    else
        echo "  ✗ Package directory structure incorrect"
        exit 1
    fi
    rm -f result
fi
echo

# Check 7: Flake outputs
echo "✓ Checking flake outputs..."
if nix flake show 2>&1 | grep -q "packages.x86_64-linux.default"; then
    echo "  ✓ Package output exists"
fi
if nix flake show 2>&1 | grep -q "apps.x86_64-linux.default"; then
    echo "  ✓ App output exists (nix run .#)"
fi
if nix flake show 2>&1 | grep -q "homeManagerModules"; then
    echo "  ✓ Home Manager module output exists"
fi
if nix flake show 2>&1 | grep -q "devShells.x86_64-linux.default"; then
    echo "  ✓ Dev shell output exists"
fi
echo

echo "=== All Checks Passed! ==="
echo
echo "Your Quickshell bar is ready to use!"
echo
echo "Next steps:"
echo "  1. Add to your home configuration"
echo "  2. Run: home-manager switch"
echo "  3. Start Hyprland to see the bar"
echo
echo "See docs/QUICKSTART.md for detailed instructions."
