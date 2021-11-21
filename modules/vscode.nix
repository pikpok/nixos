{ pkgs, ... }:
let
  vscode = pkgs.writeShellScriptBin "code" ''
    exec ${pkgs.vscode}/bin/code --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';
in { environment.systemPackages = [ vscode ]; }
