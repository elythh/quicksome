# Quickshell Hyprland Bar - Complete File Structure

```
quickshell/
├── shell.qml                 # Main entry point - bar window definition
├── Theme.qml                 # Color scheme and styling constants (singleton)
├── qmldir                    # QML module directory file
│
├── Widget Components:
│   ├── WorkspacesWidget.qml  # Hyprland workspace indicator with dots
│   ├── TaskBar.qml           # Active window tasks/icons
│   ├── MediaWidget.qml       # MPRIS media player controls
│   ├── VolumeWidget.qml      # PipeWire volume control
│   ├── NetworkWidget.qml     # NetworkManager status
│   ├── BluetoothWidget.qml   # Bluetooth toggle
│   ├── BatteryWidget.qml     # UPower battery status
│   ├── ClockWidget.qml       # Time and date display
│   ├── SysTray.qml           # System tray icons
│   └── ToolTip.qml           # Custom tooltip component
│
├── Button Components:
│   ├── LauncherButton.qml    # Application launcher button
│   ├── SettingsButton.qml    # Control center button
│   └── PowerButton.qml       # Power menu button
│
├── Nix Configuration:
│   ├── flake.nix            # Flake definition with outputs
│   ├── default.nix          # Package definition
│   ├── module.nix           # Home Manager module
│   └── manifest.json        # Quickshell manifest
│
└── Documentation:
    ├── README.md            # Main documentation
    ├── INTEGRATION.md       # General integration guide
    ├── ELYTH_INTEGRATION.md # Elyth-specific integration
    └── test.sh              # Quick test script
```

## Component Hierarchy

```
shell.qml (ShellRoot)
└── PanelWindow (per screen)
    └── Rectangle (bar background)
        └── RowLayout (main layout)
            ├── RowLayout (left section)
            │   ├── LauncherButton
            │   └── WorkspacesWidget
            │       └── Repeater → Rectangle (workspace dots)
            │
            ├── Item (center section)
            │   └── TaskBar
            │       └── Repeater → Rectangle (window icons)
            │
            └── RowLayout (right section)
                ├── MediaWidget
                ├── SysTray
                │   └── Repeater → Rectangle (tray icons)
                ├── VolumeWidget
                ├── NetworkWidget
                ├── BluetoothWidget
                ├── BatteryWidget
                ├── ClockWidget
                ├── SettingsButton
                └── PowerButton
```

## Key Features by Component

### WorkspacesWidget.qml
- Animated workspace dots (8px inactive, 32px active)
- Shows occupied vs empty workspaces
- Click to switch workspaces
- Smooth transitions

### TaskBar.qml
- Shows all windows across workspaces
- Displays app icons or first letter of class
- Highlights active window
- Click to focus window
- Tooltips show window titles

### MediaWidget.qml
- Album art display (if available)
- Track title and artist
- Play/pause button
- Auto-hides when no media playing

### VolumeWidget.qml
- Volume percentage display
- Dynamic icon based on volume level
- Color changes (green/yellow/orange/red)
- Click to mute/unmute

### NetworkWidget.qml
- WiFi signal strength indicator
- Ethernet connection status
- Connected/disconnected state

### ClockWidget.qml
- Time in HH:MM format
- Date in "dd MMM" format
- Icon with accent color
- Updates every second

### Theme.qml (Singleton)
- Tokyo Night inspired color palette
- Consistent sizing and spacing
- Font family definitions
- Widget-specific color mappings

## Service Dependencies

| Widget | Service | Required |
|--------|---------|----------|
| WorkspacesWidget | Hyprland | Yes |
| TaskBar | Hyprland | Yes |
| VolumeWidget | PipeWire | Yes |
| MediaWidget | MPRIS | Optional |
| SysTray | SystemTray | Optional |
| NetworkWidget | NetworkManager | Yes |
| BluetoothWidget | Bluez | Optional |
| BatteryWidget | UPower | Optional (laptops) |

## Customization Points

1. **Colors**: Edit `Theme.qml` properties
2. **Widget visibility**: Comment out in `shell.qml`
3. **Bar position**: Change `anchors.bottom` to `anchors.top` in `shell.qml`
4. **Bar height**: Modify `Theme.barHeight` (default: 48px)
5. **Spacing**: Adjust `spacing` in RowLayouts
6. **Widget order**: Reorder components in right section
7. **Border radius**: Change `Theme.borderRadius` (default: 8px)

## Development Workflow

1. Edit QML files
2. Run `./test.sh` to preview changes
3. Quickshell auto-reloads on file changes
4. Check logs for errors: `journalctl --user -u quickshell -f`
5. Test with: `nix build` or `nix develop`

## Installation Methods

1. **Flake input** (recommended): Add to flake.nix inputs
2. **Direct import**: Import module.nix in home config
3. **Manual**: Copy to ~/.config/quickshell and start manually

## Design Principles

- **Minimalist**: Clean, uncluttered interface
- **Functional**: All widgets are interactive
- **Consistent**: Unified color scheme and spacing
- **Responsive**: Smooth animations and transitions
- **Adaptive**: Shows/hides widgets based on availability
- **Performant**: Efficient updates, minimal resource usage
