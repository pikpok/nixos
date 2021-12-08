{ pkgs, lib, home-manager, inputs, ... }:
let
  pinebook-fix-sound = (pkgs.writeShellScriptBin "pinebook-fix-sound" ''
    export NIX_PATH="nixpkgs=${toString inputs.nixpkgs}"
    export PATH="${lib.makeBinPath [ pkgs.nix ]}:$PATH}"
    ${inputs.pinebook-pro}/sound/reset-sound.rb
  '');
in {
  imports = [
    ./hardware-configuration.nix
    "${inputs.pinebook-pro}/pinebook_pro.nix"
    ./modules/sway.nix
    ./modules/firefox.nix
    ./modules/vscode.nix
    ./modules/borg.nix
  ];

  boot = {
    # we use Tow-Boot now:
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;
    loader.generic-extlinux-compatible.configurationLimit = 3;

    tmpOnTmpfs = false;
    cleanTmpDir = true;

    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

    kernelParams = [
      "mitigations=off"
      "console=ttyS2,1500000n8"
      "console=tty0"
    ];

    initrd.availableKernelModules =
      [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ "nvme" ];
  };

  hardware.deviceTree.overlays = [{
    name = "disable-dp";
    dtsText = ''
       /dts-v1/;
       /plugin/;
       / {
           compatible = "pine64,pinebook-pro";
       };

      &cdn_dp {
        status = "disabled";
      };
    '';
  }];

  systemd.services.pinebook-fix-sound = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pinebook-fix-sound}/bin/pinebook-fix-sound";
    };
    wantedBy = [ "multi-user.target" ];
  };

  users.users.pikpok = {
    isNormalUser = true;
    home = "/home/pikpok";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
  };
  nix.trustedUsers = [ "pikpok" ];
  nix.allowedUsers = [ "pikpok" ];
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  console.earlySetup = true; # luks
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  networking.hostName = "pikpok-pbp";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";
  nixpkgs.config.allowUnfree = true;
  services.timesyncd.enable = true;

  networking.useDHCP = false;
  networking.interfaces.wlan0.useDHCP = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "pl_PL.UTF-8";
  console = { keyMap = "pl"; };

  # systemd.user.services.snapclient-local = {
  #   wantedBy = [ "pipewire.service" ];
  #   after = [ "pipewire.service" ];
  #   serviceConfig = { ExecStart = "${pkgs.snapcast}/bin/snapclient"; };
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  hardware.bluetooth.enable = true;
  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    bat
  ];

  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
