{ pkgs, lib, config, ... }:

let
  cfg = config.programs.quickshell-bar;
  
  # Filter function to only include QML and config files
  cleanSource = lib.cleanSourceWith {
    src = ../qml;
    filter = path: type:
      let
        baseName = baseNameOf path;
      in
        # Include only QML files and essential configs
        (type == "directory") ||
        (lib.hasSuffix ".qml" baseName) ||
        (lib.hasSuffix ".svg" baseName) ||
        (lib.hasSuffix ".png" baseName) ||
        baseName == "qmldir" ||
        baseName == "manifest.json";
  };
in
{
  options.programs.quickshell-bar = {
    enable = lib.mkEnableOption "Quickshell bar for Hyprland";
    
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.quickshell;
      defaultText = lib.literalExpression "pkgs.quickshell";
      description = "The quickshell package to use";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to auto-start quickshell with Hyprland";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."quickshell" = {
      source = cleanSource;
      recursive = true;
    };

    # Auto-start with Hyprland if enabled
    wayland.windowManager.hyprland.settings = lib.mkIf cfg.autoStart {
      exec-once = [
        "${cfg.package}/bin/quickshell"
      ];
    };
  };
}
