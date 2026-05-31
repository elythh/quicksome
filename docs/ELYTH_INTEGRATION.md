# Integration with Elyth Flake

To integrate the Quickshell bar into your existing Elyth flake:

## Step 1: Add Quickshell Bar as Input

Edit `/home/gwen/Documents/elyth/flake/flake.nix` and add to inputs:

```nix
{
  description = "Elyth's personal dotfile";

  inputs = {
    # ... existing inputs ...
    quickshell-bar.url = "path:../quickshell";
    # Or use git: quickshell-bar.url = "git+file:///home/gwen/Documents/elyth/quickshell";
  };

  outputs = { self, nixpkgs, hm, quickshell-bar, ... }@inputs:
    # ... rest of config
}
```

## Step 2: Add to Home Manager Modules

In your home configuration (likely in `flake/home/`), add:

```nix
{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.quickshell-bar.homeManagerModules.default
    # ... other imports
  ];

  programs.quickshell-bar.enable = true;
}
```

## Step 3: Ensure Dependencies

Make sure your system has the required packages. Add to your home or system configuration:

```nix
home.packages = with pkgs; [
  quickshell
  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  inter
];

# Enable required services
services.pipewire.enable = true;
```

## Step 4: Hyprland Configuration

If you're using Hyprland, ensure it's properly configured. In your Hyprland module:

```nix
wayland.windowManager.hyprland = {
  enable = true;
  settings = {
    # The bar will auto-start via the module
    
    # Optional: Window rules for the bar
    windowrulev2 = [
      "float, class:^(quickshell)$"
      "pin, class:^(quickshell)$"
    ];
  };
};
```

## Step 5: Rebuild

```bash
cd /home/gwen/Documents/elyth/flake
sudo nixos-rebuild switch --flake .
```

Or for home-manager only:
```bash
home-manager switch --flake .
```

## Alternative: Standalone Usage

If you don't want to add it as a flake input, you can directly import the module:

```nix
{
  imports = [
    ../../quickshell/module.nix
  ];
  
  programs.quickshell-bar.enable = true;
}
```

## Customization

### Change Colors

Create an overlay in your home config:

```nix
xdg.configFile."quickshell/Theme.qml".text = ''
  pragma Singleton
  import QtQuick

  QtObject {
      readonly property color bg: "#0e0e0e"
      readonly property color accent: "#c678dd"  // Custom purple accent
      // ... copy other properties from Theme.qml
  }
'';
```

### Disable Specific Widgets

Edit `~/.config/quickshell/shell.qml` or create an override:

```nix
xdg.configFile."quickshell/shell.qml".text = builtins.readFile (
  pkgs.runCommand "custom-shell.qml" {} ''
    cp ${./quickshell/shell.qml} $out
    # Use sed to comment out unwanted widgets
    sed -i 's/BatteryWidget {}/\/\/ BatteryWidget {}/' $out
  ''
);
```
