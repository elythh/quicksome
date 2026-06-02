{
  description = "Quickshell Hyprland Bar - Crystal/Aura inspired";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        quickshellDesktopEntry = pkgs.makeDesktopItem {
          name = "org.quickshell";
          desktopName = "Quickshell";
          comment = "Quickshell session helper";
          exec = "${pkgs.quickshell}/bin/quickshell";
          icon = "utilities-terminal";
          terminal = false;
          startupNotify = false;
          categories = [ "Utility" ];
        };
        
        # Script to run quickshell with this configuration
        runScript = pkgs.writeShellScriptBin "quickshell-bar-run" ''
          set -e

          # Help xdg-desktop-portal resolve org.quickshell app id
          # Keep user's XDG_DATA_HOME intact; just prepend our desktop entry dir.
          export XDG_DATA_DIRS="${quickshellDesktopEntry}/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
          
          # Determine config directory
          # If we're in the source repo, use it directly
          if [ -f "qml/shell.qml" ] && [ -f "qml/Theme.qml" ]; then
            CONFIG_DIR="$(pwd)"
            echo "Running from source directory: $CONFIG_DIR"
          else
            echo "Error: Please run this from the quickshell configuration directory"
            echo "Expected files: qml/shell.qml, qml/Theme.qml"
            exit 1
          fi
          
          echo ""
          echo "╔════════════════════════════════════════════════════════════════╗"
          echo "║           Quickshell Hyprland Bar - Crystal/Aura              ║"
          echo "╚════════════════════════════════════════════════════════════════╝"
          echo ""
          echo "Configuration: $CONFIG_DIR"
          echo ""
          
          # Check for existing instances and warn
          if ${pkgs.procps}/bin/pgrep -x quickshell >/dev/null 2>&1; then
            echo "⚠ Warning: Quickshell is already running!"
            echo "  You may want to kill it first: pkill quickshell"
            echo ""
            read -p "Continue anyway? [y/N] " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
              echo "Cancelled."
              exit 0
            fi
          fi
          
          # Start quickshell with our config using --path
          echo "Starting Quickshell..."
          echo "Press Ctrl+C to stop"
          echo ""
          exec ${pkgs.quickshell}/bin/quickshell --path "$CONFIG_DIR/qml"
        '';
      in
      {
        packages.default = pkgs.callPackage ./nix/default.nix { };

        apps.default = {
          type = "app";
          program = "${runScript}/bin/quickshell-bar-run";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            quickshell
          ];
          
          shellHook = ''
            echo "Quickshell development environment"
            echo ""
            echo "Available commands:"
            echo "  quickshell --path qml    - Run the bar"
            echo "  nix run .#               - Run via flake app"
            echo "  nix build                - Build the package"
            echo ""
          '';
        };
      }
    )) // {
      # Home Manager module output (not system-specific)
      homeManagerModules.default = import ./nix/module.nix;
      homeManagerModule = import ./nix/module.nix;  # Alternative name
    };
}
