{pkgs, ...}: {
  imports = [./base.nix];

  nix-rosetta-builder = {
    cores = 6;
    memory = "8GiB";
    diskSize = "40GiB";
  };

  environment.systemPackages = with pkgs; [
    nixos-rebuild
  ];

  system.primaryUser = "pikpok";

  users.users.pikpok.home = "/Users/pikpok";

  system.defaults.NSGlobalDomain.AppleFontSmoothing = 0;

  system.defaults.dock.show-recents = false;

  system.defaults.dock.persistent-apps = [
    "/Applications/Firefox.app/"
    "/Applications/Cursor.app/"
    "/Applications/Ghostty.app/"
    "/Applications/KeePassXC.app/"
    "/Applications/Beeper Desktop.app/"
    "/Applications/WhatsApp.app/"
  ];

  # Launch Firefox with MOZ_LEGACY_PROFILES to avoid overwriting profiles.ini by
  # Firefox with install details
  # https://github.com/nix-community/home-manager/issues/3323
  launchd.agents.FirefoxEnv = {
    serviceConfig.ProgramArguments = ["/bin/sh" "-c" "launchctl setenv MOZ_LEGACY_PROFILES 1"];
    serviceConfig.RunAtLoad = true;
  };
}
