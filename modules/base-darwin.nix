{
  lib,
  pkgs,
  ...
}: {
  imports = [./base.nix];

  nix.useDaemon = true;
  fonts.fontDir.enable = true;

  system.defaults.NSGlobalDomain.AppleFontSmoothing = 0;
}
