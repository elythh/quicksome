# Testing the Quickshell Bar

## Quick Tests

### 1. Build the Package

```bash
cd /home/gwen/Documents/elyth/quickshell
nix build
```

Should complete without errors and create a `result` symlink.

### 2. Check Package Contents

```bash
ls -la result/share/quickshell/
```

Should contain all QML files, qmldir, and manifest.json.

### 3. Verify Flake

```bash
nix flake check
```

Should pass all checks (warnings about homeManagerModules are expected and safe).

### 4. Show Flake Outputs

```bash
nix flake show
```

Should display:
- `packages.x86_64-linux.default`: The package
- `devShells.x86_64-linux.default`: Development shell
- `homeManagerModules.default`: Home Manager module
- `homeManagerModule`: Alternative module name

### 5. Enter Dev Shell

```bash
nix develop
```

Provides quickshell for testing.

### 6. Test with Quickshell (Manual)

```bash
# From the quickshell directory
nix run nixpkgs#quickshell -- -c shell.qml
```

This will start the bar (requires Hyprland to be running).

## Testing the Home Manager Module

### Create a Test Configuration

Create `test-home.nix`:

```nix
{ pkgs, ... }:

{
  imports = [
    /home/gwen/Documents/elyth/quickshell/module.nix
  ];

  programs.quickshell-bar = {
    enable = true;
    autoStart = false;  # Don't auto-start for testing
  };

  home.stateVersion = "24.05";
}
```

### Build Test Config

```bash
home-manager build --flake .#test
```

## Verification Checklist

- [x] Package builds successfully
- [x] No broken symlinks in output
- [x] All QML files are included
- [x] Flake outputs are correct
- [x] Module imports without errors
- [x] No runtime QML syntax errors

## Common Issues

### Build fails with "dangling symlinks"

**Solution**: Remove the `result` symlink before building:
```bash
rm result
nix build
```

### Module import fails

**Solution**: Use the correct import path:
```nix
imports = [ /absolute/path/to/quickshell/module.nix ];
```

Or with flakes:
```nix
inputs.quickshell-bar.homeManagerModules.default
```

### QML files not found

**Solution**: Check the installation location:
```bash
cat ~/.config/quickshell/shell.qml
```

Should contain the main shell configuration.

## Integration Testing

### Test with Your Elyth Flake

1. Add to flake inputs:
```nix
quickshell-bar.url = "path:../quickshell";
```

2. Import in home config:
```nix
imports = [ inputs.quickshell-bar.homeManagerModules.default ];
programs.quickshell-bar.enable = true;
```

3. Build:
```bash
cd /home/gwen/Documents/elyth/flake
nix build .#homeConfigurations.gwen.activationPackage
```

## Debugging

### Check Quickshell Logs

```bash
journalctl --user -u quickshell -f
```

### Run Quickshell with Verbose Output

```bash
quickshell -v
```

### Check QML Syntax

```bash
nix-shell -p qt6.qtdeclarative
qmllint *.qml
```

### Validate Configuration

```bash
nix eval .#homeManagerModules.default
```

Should return the module attribute set.

## Success Criteria

✅ Package builds without errors
✅ Flake check passes
✅ Module imports successfully
✅ Config files installed to ~/.config/quickshell/
✅ Quickshell starts without QML errors
✅ Bar appears on screen (with Hyprland running)

## Performance Testing

### Check Resource Usage

```bash
ps aux | grep quickshell
```

Should show reasonable memory usage (<100MB typically).

### Monitor Updates

Watch CPU usage while:
- Switching workspaces
- Playing media
- Adjusting volume
- Connecting/disconnecting devices

CPU should spike briefly then return to near zero.
