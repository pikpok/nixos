{
  lib,
  pkgs,
  ...
}: {
  imports = [./base.nix];

  nix.useDaemon = true;
  fonts.fontDir.enable = true;
}
