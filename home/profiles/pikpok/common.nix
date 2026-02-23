{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  home.packages = lib.mkIf config.submoduleSupport.enable [
    inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
