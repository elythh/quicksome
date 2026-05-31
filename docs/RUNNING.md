# Running the Quickshell Bar

## Quick Test with `nix run`

The easiest way to test the bar is with `nix run`:

```bash
cd /home/gwen/Documents/elyth/quickshell
nix run .#
```

This will:
1. Check that you're in the correct directory
2. Warn if quickshell is already running
3. Start quickshell with the bar configuration
4. Display a nice banner

**Note**: You must be running Hyprland for the bar to appear.

### Stopping the Bar

Press `Ctrl+C` in the terminal where you ran `nix run .#`

Or from another terminal:
```bash
pkill quickshell
```

## Alternative: Direct quickshell

If you prefer to run quickshell directly:

```bash
cd /home/gwen/Documents/elyth/quickshell
quickshell --path .
```

Or specify the full path:

```bash
quickshell --path /home/gwen/Documents/elyth/quickshell
```

This requires quickshell to be in your PATH. Install with:
```bash
nix-shell -p quickshell
```

## Development Workflow

### 1. Make Changes

Edit any `.qml` file to customize the bar.

### 2. Test Changes

Run `nix run .#` to see your changes (quickshell auto-reloads on file changes).

### 3. Iterate

Keep the bar running and edit files - changes appear instantly!

## Troubleshooting

### "Quickshell is already running"

If you see this warning, you have a few options:

1. **Kill the existing instance:**
   ```bash
   pkill quickshell
   ```
   Then run `nix run .#` again.

2. **Continue anyway:**
   Type `y` when prompted. This will start a second instance (not recommended).

3. **Use the existing instance:**
   If you just want to see your changes, the existing quickshell instance will auto-reload when you save QML files.

### "Error: Please run this from the quickshell configuration directory"

Make sure you're in the directory containing `shell.qml` and `Theme.qml`:

```bash
cd /home/gwen/Documents/elyth/quickshell
nix run .#
```

### Bar doesn't appear

1. **Check Hyprland is running:**
   ```bash
   echo $HYPRLAND_INSTANCE_SIGNATURE
   ```
   Should output a signature string. If empty, you're not in Hyprland.

2. **Check quickshell logs:**
   ```bash
   journalctl --user -u quickshell -f
   ```

3. **Run with verbose output:**
   ```bash
   quickshell -c shell.qml -v
   ```

### QML Errors

If you see QML errors when starting:

1. **Check syntax:**
   ```bash
   nix-shell -p qt6.qtdeclarative
   qmllint *.qml
   ```

2. **Review error message:**
   QML errors usually point to the exact file and line number.

3. **Revert changes:**
   Use git to revert to a working state if needed.

## Running in Production

Once you're happy with the configuration, install it permanently:

```bash
# Add to home configuration
# See QUICKSTART.md for details

# Then rebuild
home-manager switch
```

The bar will now start automatically with Hyprland!

## Tips

- **Auto-reload**: Quickshell automatically reloads when you save QML files
- **Console output**: Keep the terminal visible to see errors and debug info
- **Multiple monitors**: The bar appears on all monitors by default
- **Performance**: Check `top` or `htop` to monitor resource usage

## Common Commands

```bash
# Test the bar
nix run .#

# Stop the bar
pkill quickshell

# Check if running
pgrep quickshell

# View logs
journalctl --user -u quickshell -f

# Build the package
nix build

# Enter dev shell
nix develop

# Verify everything
./verify.sh
```
