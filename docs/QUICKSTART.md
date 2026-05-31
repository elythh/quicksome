# Quick Start Guide

Get your Quickshell bar up and running in minutes!

## Prerequisites

- NixOS or Nix package manager
- Hyprland window manager
- Home Manager (recommended)

## 3-Step Setup

### 1. Test Run (Optional but Recommended)

Try it out before installing (requires Hyprland to be running):

```bash
cd /home/gwen/Documents/elyth/quickshell
nix run .#
```

This will:
- Kill any existing quickshell instances
- Start quickshell with the bar configuration
- Display the bar at the bottom of your screen

Press `Ctrl+C` to stop it.

### 2. Install via Home Manager

Add to your `home.nix`:

```nix
{
  imports = [ /home/gwen/Documents/elyth/quickshell/module.nix ];
  
  programs.quickshell-bar.enable = true;
}
```

### 3. Rebuild

```bash
home-manager switch
```

That's it! The bar should appear at the bottom of your screen.

## What You Get

✨ **Left Side:**
- 󰣇 Application launcher button
- Workspace indicators (dots)

✨ **Center:**
- Active window icons/tasks

✨ **Right Side:**
- 󰝚 Media controls (when playing)
- 🔊 Volume control
- 📶 Network status
- 󰂯 Bluetooth toggle
- 🔋 Battery level (laptops)
- 🕐 Clock & date
- 󰒓 Settings button
- 󰐥 Power button

## Keyboard Shortcuts

The bar integrates with Hyprland's default keybindings:

- `Super + 1-9`: Switch workspace (workspace dots update)
- `Super + Shift + 1-9`: Move window to workspace
- `Super + Mouse_Left`: Click workspace dot to switch

## Customization Quick Tips

### Change Accent Color

Edit `Theme.qml`:
```qml
readonly property color accent: "#YOUR_COLOR_HERE"
```

### Hide a Widget

Edit `shell.qml`, comment out the widget:
```qml
// BatteryWidget {}  // Hidden
```

### Change Bar Position

Edit `shell.qml`:
```qml
anchors {
    left: true
    right: true
    top: true    // Changed from bottom
}
```

### Adjust Bar Height

Edit `Theme.qml`:
```qml
readonly property int barHeight: 40  // Default: 48
```

## Troubleshooting

### Bar doesn't appear
```bash
# Check if quickshell is running
ps aux | grep quickshell

# Restart it manually
pkill quickshell && quickshell
```

### Icons are missing
Install Nerd Fonts:
```nix
home.packages = with pkgs; [
  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
];
```

### Widgets not working
Enable required services:
```nix
services.pipewire.enable = true;
networking.networkmanager.enable = true;
hardware.bluetooth.enable = true;
```

### Volume control not responding
```bash
# Check PipeWire
systemctl --user status pipewire

# Restart if needed
systemctl --user restart pipewire
```

## Advanced: Flake Integration

For Elyth's flake structure:

1. Add input to `flake/flake.nix`:
```nix
inputs.quickshell-bar.url = "path:../quickshell";
```

2. Add to home config:
```nix
imports = [ inputs.quickshell-bar.homeManagerModules.default ];
programs.quickshell-bar.enable = true;
```

3. Rebuild:
```bash
cd flake && sudo nixos-rebuild switch --flake .
```

## Next Steps

- Read [README.md](README.md) for detailed features
- Check [INTEGRATION.md](INTEGRATION.md) for advanced setup
- See [STRUCTURE.md](STRUCTURE.md) for architecture details
- Explore QML files to customize widgets

## Support

- Check Quickshell docs: https://quickshell.outfoxxed.me/
- Review component code in QML files
- Test changes with `./test.sh`

---

**Enjoy your new bar! 🎉**

Inspired by [crystal/aura](https://github.com/namishh/crystal/tree/aura)
