{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/base-darwin.nix
    ../../modules/user.nix
    ../../modules/homebrew.nix
    ../../modules/shell.nix
    ./home.nix
  ];

  networking.hostName = "pikpok-mbp";

  environment.systemPackages = with pkgs; [
    asdf-vm
  ];

  # Domino's Hermes gets a full shell here (desktop via Cua Driver, Orca CLI);
  # see hosts/domino/hermes/README.md.
  users.users.pikpok.openssh.authorizedKeys.keys = [
    ''from="192.168.100.7" ${lib.fileContents ../domino/hermes/mac-key.pub}''
  ];
  environment.systemPath = ["/Applications/Orca.app/Contents/Resources/bin"];

  ids.gids.nixbld = 350;
  system.stateVersion = 4; # Did you read the comment?
}
