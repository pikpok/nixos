{
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isLinux {
  users.users.pikpok = {
    isNormalUser = true;
    home = "/home/pikpok";
    extraGroups = ["wheel" "networkmanager" "audio" "video"];
  };
}
