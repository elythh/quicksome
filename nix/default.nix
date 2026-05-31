{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib }:

let
  repoRoot = ../.;
in

pkgs.stdenv.mkDerivation {
  pname = "quickshell-hyprland-bar";
  version = "0.1.0";

  src = lib.cleanSourceWith {
    src = repoRoot;
    filter = path: type:
      let
        baseName = baseNameOf path;
      in
        # Exclude unwanted files and directories
        baseName != "result" &&
        baseName != ".git" &&
        baseName != ".gitignore" &&
        baseName != ".direnv" &&
        baseName != "flake.lock" &&
        baseName != "Makefile" &&
        baseName != "scripts" &&
        ! lib.hasSuffix ".md" baseName;
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/share/quickshell
    
    # Copy only QML files and essential configs
    cp -r qml/* $out/share/quickshell/
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "A modern Quickshell bar configuration for Hyprland inspired by crystal/aura";
    homepage = "https://github.com/namishh/crystal/tree/aura";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
