# Workspace Widget - Crystal/Aura Style

## Design Overview

The workspace widget now matches the crystal/aura design with animated pill-shaped indicators.

## Visual States

### 1. Active Workspace (Current)
- **Color**: Blue (`#7aa2f7`)
- **Size**: 40px wide × 6px tall
- **Opacity**: 100%
- **Shape**: Pill (fully rounded)
- **Meaning**: Currently focused workspace

### 2. Occupied Workspace (Has Windows)
- **Color**: Light Gray (`#aaaaaa`)
- **Size**: 24px wide × 6px tall
- **Opacity**: 80%
- **Shape**: Pill (fully rounded)
- **Meaning**: Workspace with open windows

### 3. Empty Workspace (No Windows)
- **Color**: Dark Gray (`#555555`)
- **Size**: 12px wide × 6px tall
- **Opacity**: 50%
- **Shape**: Pill (fully rounded)
- **Meaning**: Workspace with no windows

## Animations

### Width Transitions
- **Duration**: 250ms
- **Easing**: Cubic out
- **Triggers**: 
  - Switching workspaces (active state changes)
  - Opening/closing windows (occupied state changes)

### Color Transitions
- **Duration**: 200ms
- **Easing**: Linear
- **Triggers**: State changes

### Opacity Transitions
- **Duration**: 200ms
- **Easing**: Linear
- **Triggers**: 
  - State changes
  - Mouse hover (all workspaces become fully opaque on hover)

## Interactions

### Click
- Switches to clicked workspace
- Console logs: `"Workspace clicked: <id>"`
- Hyprland dispatch: `workspace <id>`

### Hover
- Workspace indicator fades to 100% opacity
- Cursor changes to pointing hand
- On exit: Returns to original opacity based on state

### Visual Feedback
```
Empty → Hover:   50% → 100% opacity
Occupied → Hover: 80% → 100% opacity  
Active:          Always 100% opacity
```

## Layout

### Spacing
- **Between indicators**: 6px
- Allows pills to "breathe" and be individually clickable

### Alignment
- Left-aligned in the bar
- Sits next to launcher button
- Part of left section RowLayout

## Technical Implementation

### Pill Shape
```qml
radius: height / 2
```
This creates perfect rounded ends regardless of width.

### Dynamic Width
```qml
Layout.preferredWidth: {
    if (isActive) return 40
    else if (hasWindows) return 24
    else return 12
}
```

### State Detection
```qml
property bool isActive: modelData.id === Hyprland.focusedWorkspace?.id
property bool hasWindows: modelData.windows?.length > 0
```

## Example Scenarios

### Scenario 1: Fresh Start
```
[1] (Active, Blue, 40px)
[2] (Empty, Dark Gray, 12px)
[3] (Empty, Dark Gray, 12px)
```

### Scenario 2: Multiple Workspaces in Use
```
[1] (Occupied, Light Gray, 24px)
[2] (Active, Blue, 40px)
[3] (Occupied, Light Gray, 24px)
[4] (Empty, Dark Gray, 12px)
```

### Scenario 3: Switching Workspaces
```
Before:
[1] (Active, Blue, 40px) → Click workspace 3
[2] (Occupied, Light Gray, 24px)
[3] (Occupied, Light Gray, 24px)

After (animated):
[1] (Occupied, Light Gray, 24px) ← Shrinks from 40px
[2] (Occupied, Light Gray, 24px)
[3] (Active, Blue, 40px) ← Grows from 24px
```

## Comparison to Original

### Before (Round Dots)
- Active: 32px wide × 8px tall
- Occupied/Empty: 8px wide × 8px tall
- Circular (radius: 4px)
- Less visual distinction between states

### After (Pills - Crystal/Aura Style)
- Active: 40px wide × 6px tall
- Occupied: 24px wide × 6px tall
- Empty: 12px wide × 6px tall
- Full pill shape (radius: 3px)
- Clear visual hierarchy
- Better matches modern desktop aesthetics

## Color Philosophy

Following crystal/aura's design:
- **Blue**: Active/focused (draws attention)
- **Light Gray**: Present but not focused (medium priority)
- **Dark Gray**: Available but unused (low priority)
- **Opacity**: Adds depth and reduces visual noise for inactive states

## Accessibility

- ✅ Clear visual states (3 distinct sizes)
- ✅ Color contrast (blue stands out)
- ✅ Hover feedback (opacity increase)
- ✅ Smooth animations (not jarring)
- ✅ Clickable areas are appropriately sized

## Testing

To test all states:
1. Start with one workspace → See single blue pill
2. Open windows → Pill stays blue (active + occupied)
3. Switch to workspace 2 → First becomes gray, second becomes blue
4. Open windows on workspace 2 → Both are medium pills (occupied)
5. Switch to empty workspace 3 → Small pill appears, previous shrinks
6. Hover over any indicator → It brightens
7. Click any indicator → Smoothly switches with animation

---

**Result**: Beautiful, smooth pill-shaped workspace indicators matching crystal/aura! 🎨
