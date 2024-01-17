{
  lib,
  pkgs,
  ...
}: {
  imports = [./base.nix];

  # Select internationalisation properties.
  i18n.defaultLocale = "pl_PL.UTF-8";
  console = {keyMap = "pl";};

  services.timesyncd.enable = true;
  services.upower.enable = true;
  services.openssh.enable = true;

  networking.firewall.enable = false;
}
