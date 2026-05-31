# Testing Guide - Quickshell Bar

## Quick Start

```bash
cd /home/gwen/Documents/elyth/quickshell
nix run .#
```

## Feature Testing

### 1. Notifications

Test notification popups with these commands:

```bash
# Basic notification
notify-send "Test Notification" "This is a test notification body text"

# With icon
notify-send "Test Notification" "This is a test notification body text" -i dialog-information

# Different urgency levels
notify-send "Low Priority" "This is a low priority message" -u low
notify-send "Normal Priority" "This is a normal message" -u normal
notify-send "Critical Alert" "This is an important message!" -u critical

# With timeout (milliseconds)
notify-send "Quick Message" "This will disappear in 2 seconds" -t 2000

# With actions (may not work in all implementations)
notify-send "Action Test" "Click the buttons below" -A "Accept" -A "Decline"

# Application-specific icons
notify-send "Update Available" "New version 1.2.3 is ready" -i system-software-update
notify-send "Download Complete" "File downloaded successfully" -i emblem-downloads
notify-send "Battery Low" "15% remaining" -i battery-caution
notify-send "Network" "Connected to WiFi" -i network-wireless

# Test multiple notifications
for i in {1..3}; do 
  notify-send "Notification $i" "This is test notification number $i" -t 3000
  sleep 0.5
done
```

**Expected behavior**:
- Notifications appear at top right corner
- Slide in from right with fade animation
- Show app icon (or bell icon as fallback)
- Display title and body text
- Auto-dismiss after timeout
- Close button (×) works
- Multiple notifications stack vertically

### 2. Workspace Pills

**Test**:
1. Click different workspace dots
2. Open windows in different workspaces
3. Observe size and color changes

**Expected behavior**:
- Active workspace: 40px wide, blue, fully opaque
- Occupied workspaces: 24px wide, light gray, 80% opaque
- Empty workspaces: 12px wide, dark gray, 50% opaque
- Smooth width animations (250ms)
- Hover increases opacity to 100%
- Click switches workspace

### 3. Current Workspace Widget

**Test**:
1. Open several applications
2. Switch between workspaces
3. Click on window icons
4. Hover to see tooltips

**Expected behavior**:
- Shows first letter of app class (F for Firefox, etc.)
- Active window has blue background
- Inactive windows have transparent background with border
- Click focuses the window
- Updates when switching workspaces
- Tooltip shows full window title

### 4. System Tray Toggle

**Test**:
1. Ensure you have 4+ tray icons running
2. Look for chevron button (󰅂)
3. Click to expand/collapse

**Apps that add tray icons**:
```bash
# Example apps with tray icons
discord &
telegram-desktop &
nextcloud &
```

**Expected behavior**:
- Toggle button visible only if >3 tray icons
- First 3 icons always visible
- Chevron points down (󰅂) when collapsed
- Chevron points up (󰅁) when expanded
- Smooth width animation
- All icons visible when expanded
- Chevron color changes to accent when expanded

### 5. System Tray Context Menus

**Test**:
1. Right-click any system tray icon
2. Check console for debug output

**Expected behavior**:
- Right-click opens app's context menu
- Console shows: "Right click - opening menu"
- Console shows: "Opening menu at: X Y"
- Menu appears near cursor
- Left-click activates/opens app
- Middle-click performs secondary action

**Debug info in console**:
```
Tray icon clicked: <app name>
Button: 2 (right-click)
Has menu: true
Opening menu at: 1234 567
```

### 6. Network Status Widget

**Test**:
1. Click the Bluetooth icon
2. Click the widget background

**Expected behavior**:
- Widget shows: WiFi icon • Bluetooth icon
- WiFi icon is green (connected) or gray (disconnected)
- Bluetooth icon is blue (enabled) or gray (disabled)
- Clicking Bluetooth icon toggles state
- Console shows: "Bluetooth toggled: true/false"
- Hover shows pointer cursor

### 7. Volume Widget

**Test**:
1. Click volume widget
2. Play audio
3. Observe icon changes

**Expected behavior**:
- Shows volume percentage
- Icon changes based on volume level:
  - >60%: 󰕾 (high)
  - 30-60%: 󰖀 (medium)
  - 0-30%: 󰕿 (low)
  - Muted: 󰖁 (muted)
- Color changes (green → yellow → orange → red)
- Click toggles mute/unmute
- Console shows: "Volume clicked"

### 8. Icon Alignment

**Test**:
1. Check all icons in bar
2. Verify vertical centering

**Expected behavior**:
- NixOS logo properly centered (adjusted -1px)
- All widget text/icons vertically centered
- No icons sitting too low or too high
- Consistent spacing

## Console Monitoring

Watch the console while testing:

```bash
# In the terminal where you ran quickshell, you'll see:
Workspace clicked: 2
Focusing window: Firefox
Tray toggle clicked, expanded: false → true
Tray icon clicked: Discord
Volume clicked
Network status clicked
Bluetooth toggled: true
```

## Common Issues & Solutions

### Issue: No tray toggle visible
**Solution**: Toggle only shows if you have more than 3 tray icons
**Fix**: Launch more apps with tray icons

### Issue: Right-click menu not appearing
**Check console**: Should show "Opening menu at: X Y"
**Possible causes**:
- App doesn't provide menu (console will say "No menu available")
- Menu API mismatch (check error logs)

### Issue: Notifications not showing
**Test with**:
```bash
# Check if notification daemon is running
ps aux | grep -i notif

# Try simple test
notify-send "Test" "Hello"
```

### Issue: Current workspace widget empty
**Check**: Open some applications
**Console**: Look for "Focusing window: <title>"

### Issue: Workspace pills not clickable
**Console**: Should show "Workspace clicked: <id>"
**Check**: Click directly on the pill, not between them

## Performance Testing

### Memory Usage
```bash
ps aux | grep quickshell
# Should be <100MB
```

### CPU Usage
```bash
top -p $(pgrep quickshell)
# Should be ~0% when idle, brief spikes on interactions
```

## Verification Checklist

- [ ] NixOS logo visible and centered
- [ ] Workspace pills show different sizes
- [ ] Workspace pills clickable
- [ ] Current workspace shows window letters
- [ ] Window letters clickable
- [ ] Tray toggle visible (if >3 icons)
- [ ] Tray expands/collapses smoothly
- [ ] Tray right-click opens menu
- [ ] Volume widget clickable
- [ ] Network status shows WiFi + Bluetooth
- [ ] Bluetooth toggles on click
- [ ] Clock shows time and date
- [ ] Settings and Power buttons visible
- [ ] Notifications popup at top right
- [ ] Notification close button works
- [ ] All icons properly aligned

## Screenshot Locations

When everything works, the bar should look like:
```
[󱄅] [●●●○○] | [F][C][T] ··· [MediaWidget] [Tray+Toggle] [Vol] [WiFi•BT] [Clock] [Settings] [Power]
```

Where:
- 󱄅 = NixOS logo
- ●●●○○ = Workspace pills (filled = active/occupied, empty = available)
- | = Separator
- [F][C][T] = Current workspace windows (Firefox, Chrome, Terminal)
- [Tray+Toggle] = Collapsible system tray
- [WiFi•BT] = Combined network status

---

**Happy Testing! 🧪**
