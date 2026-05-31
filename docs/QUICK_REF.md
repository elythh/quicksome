# Quick Reference Card

## Notification Test Commands

```bash
# Basic test
notify-send "Test" "Hello!"

# With urgency
notify-send "Critical" "Important!" -u critical
notify-send "Normal" "Regular message" -u normal
notify-send "Low" "Low priority" -u low

# With icons
notify-send "Update" "System updated" -i system-software-update
notify-send "Download" "File ready" -i emblem-downloads
notify-send "Battery" "Low battery" -i battery-caution
notify-send "Network" "Connected" -i network-wireless

# With timeout (milliseconds)
notify-send "Quick" "2 second message" -t 2000
notify-send "Long" "10 second message" -t 10000

# Multiple notifications
for i in {1..5}; do notify-send "Test $i" "Message $i"; sleep 0.3; done
```

## Tray Right-Click Menu

**How it works**:
1. Right-click any system tray icon
2. The bar calls `modelData.menu.open(x, y)`
3. Menu appears at cursor position
4. Select menu item to perform action

**Console output**:
```
Tray icon clicked: Discord
Button: 2
Has menu: true
Opening menu at: 1234 567
```

**If menu doesn't open**:
- Check console for "No menu available"
- Some apps don't provide menus
- Try left-click to activate app instead

## Widget Interactions

| Widget | Left Click | Right Click | Middle Click |
|--------|------------|-------------|--------------|
| **Workspace pill** | Switch workspace | - | - |
| **Current workspace icon** | Focus window | - | - |
| **Tray icon** | Activate app | Open menu | Secondary action |
| **Tray toggle** | Expand/collapse | - | - |
| **Volume** | Mute toggle | - | - |
| **Bluetooth icon** | Toggle on/off | - | - |
| **Network widget** | Settings (TODO) | - | - |
| **Clock** | Calendar (TODO) | - | - |
| **Notification close** | Dismiss | - | - |

## Keyboard Shortcuts (Hyprland)

These work with the bar:
```
Super + 1-9        Switch workspace (pills update)
Super + Shift + 1-9   Move window to workspace
Super + Q          Close window (removed from current workspace)
```

## Console Commands

Watch console while using bar:
```bash
cd /home/gwen/Documents/elyth/quickshell
nix run .# 2>&1 | grep -E "(clicked|toggled|Focusing)"
```

## Quick Troubleshooting

**No tray toggle?**
- Needs >3 tray icons to show

**Right-click menu not working?**
- Check console for errors
- Some apps don't have menus
- Fallback: left-click to open app

**Notifications not appearing?**
- Test: `notify-send "Test" "Test"`
- Check notification daemon running

**Current workspace empty?**
- Open some applications
- They'll appear as letter icons

**Volume not responding?**
- Check PipeWire running
- Warnings are cosmetic

## File Locations

```bash
# Configuration
~/.config/quickshell/

# Test from source
/home/gwen/Documents/elyth/quickshell/
```

## Common Tasks

**Change accent color**:
Edit `Theme.qml`, change `accent: "#7aa2f7"` to your color

**Disable notifications**:
Comment out `NotificationPopup {}` in `shell.qml`

**Always expand tray**:
In `SysTray.qml`, set `property bool expanded: true`

**Move bar to top**:
In `shell.qml`, change `bottom: true` to `top: true`

---

**Quick Help**: See TESTING_GUIDE.md for detailed instructions
