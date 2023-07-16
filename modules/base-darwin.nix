{
  lib,
  pkgs,
  ...
}: {
  imports = [./base.nix];

  nix.useDaemon = true;
  fonts.fontDir.enable = true;

  users.users.pikpok.home = "/Users/pikpok";

  system.defaults.NSGlobalDomain.AppleFontSmoothing = 0;
}
