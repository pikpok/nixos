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

  users.users.pikpok.home = "/Users/pikpok";

  system.defaults.NSGlobalDomain.AppleFontSmoothing = 0;

  system.defaults.dock.show-recents = false;
  system.defaults.dock.persistent-apps = [
    "/Applications/Firefox.app/"
    "${pkgs.vscode}/Applications/Visual Studio Code.app/"
    "/Applications/iTerm.app/"
    "/Applications/KeePassXC.app/"
    "/Applications/Beeper.app/"
  ];
}
