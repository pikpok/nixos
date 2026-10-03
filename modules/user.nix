{
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  users.users.pikpok = {
    isNormalUser = true;
    home = "/home/pikpok";
    extraGroups = ["wheel" "networkmanager" "audio" "video"];
  };
}
