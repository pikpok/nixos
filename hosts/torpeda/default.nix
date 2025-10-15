{inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ../../modules/base-linux.nix
    ../../modules/user.nix
    ./wg.nix
    ./proxy.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "torpeda";
  system.stateVersion = "24.05";

  users.users.root.openssh.authorizedKeys.keyFiles = [
    inputs.ssh-keys.outPath
  ];
}
