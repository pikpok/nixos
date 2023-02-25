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

  networking.firewall.allowedTCPPorts = [
    1716 # Valent/KDE Connect
    5900 # Wireguard
  ];

  # Valent/KDE Connect
  networking.firewall.allowedUDPPorts = [1716];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1739;
      to = 1764;
    }
  ];
}
