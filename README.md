# Quickshell Hyprland Bar

A modern, aesthetically pleasing bar for Hyprland using Quickshell, inspired by the crystal/aura AwesomeWM configuration.

## Features

- **Workspace Indicator**: Animated workspace dots showing active and occupied workspaces
- **Task Bar**: Window icons with active window highlighting
- **Media Controls**: Now playing widget with album art, track info, and play/pause
- **System Tray**: All your system tray icons in one place
- **Volume Control**: Visual volume indicator with mute toggle
- **Network Status**: WiFi/Ethernet connection status
- **Bluetooth Toggle**: Quick bluetooth on/off control
- **Battery Monitor**: Battery percentage and charging status (on laptops)
- **Clock & Date**: Current time and date display
- **Quick Actions**: Launcher, settings, and power menu buttons

## Installation

### Quick Test (Recommended First Step)

Test the bar before installing (requires Hyprland):

```bash
cd /path/to/quickshell
nix run .#
```

### Using Nix Home Manager

1. Add to your `home.nix` or `flake.nix`:

```nix
{
  imports = [ ./quickshell/nix/module.nix ];
  
  programs.quickshell-bar.enable = true;
}
```

2. Rebuild your configuration:

```bash
home-manager switch
```

### Manual Installation

1. Ensure you have Quickshell installed:

```bash
nix-shell -p quickshell
```

2. Copy the configuration files to `~/.config/quickshell/`

3. Start Quickshell:

```bash
quickshell --path ~/.config/quickshell
```

## Configuration

### Theme Customization

Edit `qml/Theme.qml` to customize colors and sizing:

```qml
readonly property color accent: "#7aa2f7"  // Change accent color
readonly property int barHeight: 48        // Adjust bar height
readonly property int borderRadius: 8      // Modify widget roundness
```

### Widget Visibility

In `qml/shell.qml`, you can show/hide widgets by commenting out lines in the right section:

```qml
// Hide battery widget
// BatteryWidget {}

// Hide bluetooth widget
// BluetoothWidget {}
```

## Dependencies

- Quickshell (with Qt6 and Wayland support)
- Hyprland
- PipeWire (for audio control)
- NetworkManager (for network widget)
- Bluez (for bluetooth widget)
- UPower (for battery widget)
- MPRIS-compatible media player (for media controls)

## Color Scheme

The default theme is inspired by Tokyo Night with the following palette:

- Background: `#0e0e0e`
- Foreground: `#e0e0e0`
- Accent: `#7aa2f7` (blue)
- Red: `#f7768e`
- Green: `#9ece6a`
- Yellow: `#e0af68`
- Purple: `#bb9af7`
- Cyan: `#7dcfff`

## Screenshots

The bar features a sleek bottom panel with:
- Left: App launcher + workspace indicators
- Center: Active window tasks
- Right: System widgets + clock + quick actions

## Credits

Design inspired by [crystal/aura](https://github.com/namishh/crystal/tree/aura) by namishh.

## License

MIT
