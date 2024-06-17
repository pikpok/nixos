{pkgs, ...}: {
  imports = [./base.nix];

  nix = {
    useDaemon = true;
    linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 4;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 40 * 1024;
            memorySize = 8 * 1024;
          };
          cores = 6;
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    nixos-rebuild
  ];

  fonts.fontDir.enable = true;

  users.users.pikpok.home = "/Users/pikpok";

  system.defaults.NSGlobalDomain.AppleFontSmoothing = 0;
}
