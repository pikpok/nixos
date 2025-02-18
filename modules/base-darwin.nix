{pkgs, ...}: {
  imports = [./base.nix];

  nix = {
    linux-builder = {
      enable = true;
      ephemeral = true;
      systems = ["x86_64-linux" "aarch64-linux"];
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

  nixpkgs.config.permittedInsecurePackages = ["cinny-4.2.3" "cinny-unwrapped-4.2.3"];
  system.defaults.dock.persistent-apps = [
    "/Applications/Firefox.app/"
    "/Applications/Cursor.app/"
    "/Applications/Ghostty.app/"
    "/Applications/KeePassXC.app/"
    "/Applications/Beeper.app/"
    "${pkgs.cinny-desktop}/Applications/Cinny.app"
  ];

  # Launch Firefox with MOZ_LEGACY_PROFILES to avoid overwriting profiles.ini by
  # Firefox with install details
  # https://github.com/nix-community/home-manager/issues/3323
  launchd.agents.FirefoxEnv = {
    serviceConfig.ProgramArguments = ["/bin/sh" "-c" "launchctl setenv MOZ_LEGACY_PROFILES 1"];
    serviceConfig.RunAtLoad = true;
  };
}
