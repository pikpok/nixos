{
  lib,
  pkgs,
  ...
}: {
  imports = [./base.nix];

  nix.useDaemon = true;
  fonts.enableFontDir = true;
}
