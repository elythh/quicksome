# Example Home Manager Integration

Here are different ways to integrate this Quickshell bar into your NixOS/Home Manager configuration:

## Method 1: Direct Import (Recommended)

Add to your `home.nix`:

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./quickshell/module.nix
  ];

  programs.quickshell-bar.enable = true;
  
  wayland.windowManager.hyprland = {
    enable = true;
    # The bar will auto-start with Hyprland
  };
}
```

## Method 2: Using Flakes

In your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    quickshell-bar.url = "path:./quickshell";  # or git url
  };

  outputs = { nixpkgs, home-manager, quickshell-bar, ... }: {
    homeConfigurations.youruser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        quickshell-bar.homeManagerModules.default
        {
          programs.quickshell-bar.enable = true;
        }
      ];
    };
  };
}
```

## Method 3: Manual Configuration

If you prefer manual control:

```nix
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    quickshell
  ];

  xdg.configFile."quickshell" = {
    source = ./quickshell;
    recursive = true;
  };

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "quickshell"
    ];
  };
}
```

## Hyprland Configuration

Make sure your Hyprland config reserves space for the bar:

```nix
wayland.windowManager.hyprland.settings = {
  # Reserve space for the bar
  monitor = ",preferred,auto,1";
  
  # Make sure bar windows are treated correctly
  windowrulev2 = [
    "float, class:^(quickshell)$"
    "pin, class:^(quickshell)$"
  ];
  
  # Gaps and padding
  general = {
    gaps_in = 5;
    gaps_out = 10;
    border_size = 2;
  };
};
```

## Customization

### Using a Different Accent Color

Create a custom theme file:

```nix
xdg.configFile."quickshell/Theme.qml".text = ''
  pragma Singleton
  import QtQuick

  QtObject {
      readonly property color accent: "#your-color-here"
      // ... rest of theme
  }
'';
```

### Disabling Specific Widgets

Edit the module configuration:

```nix
programs.quickshell-bar = {
  enable = true;
  # Future: Add widget-specific options
};
```

## Dependencies

Ensure these are installed:

```nix
home.packages = with pkgs; [
  # Required
  quickshell
  
  # For various widgets
  pipewire
  wireplumber
  networkmanager
  bluez
  upower
  
  # Fonts for icons
  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  inter
];
```

## Troubleshooting

### Bar doesn't appear

Check if Quickshell is running:
```bash
ps aux | grep quickshell
```

Check logs:
```bash
journalctl --user -u quickshell -f
```

### Icons not showing

Make sure Nerd Fonts are installed:
```nix
fonts.fonts = with pkgs; [
  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
];
```

### Widgets not working

Ensure services are enabled:
```nix
services.pipewire.enable = true;
networking.networkmanager.enable = true;
hardware.bluetooth.enable = true;
services.upower.enable = true;
```
