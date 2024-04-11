{
  pkgs,
  lib,
  home-manager,
  inputs,
  modulesPath,
  ...
}: {
  imports = [
    ../../modules/base-linux.nix

    ../../modules/audio.nix
    ../../modules/avahi.nix
    ../../modules/user.nix
    ../../modules/shell.nix

    ./mpd.nix
    ./mosquitto.nix
    ./photoprism.nix
    ./backup.nix
    ./containers.nix
  ];

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = ["nofail" "noauto"];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    "/mnt/nas-ntfs" = {
      device = "/dev/disk/by-label/NASNTFS";
      options = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=1000,gid=100"];
    };
    "/mnt/nas" = {
      device = "/dev/disk/by-label/NAS";
      options = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s"];
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "usb_storage"
    "uas"
    "xhci-pci-renesas"
    "pcie-brcmstb"
    "reset-raspberrypi"
  ];

  networking.hostName = "raspberrypi";

  boot.kernelParams = ["console=ttyS0,115200n8" "console=tty0" "usb_storage.quirks=0bc2:3343:u,152d:0578:u"];
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.interfaces.end0.ipv4.addresses = [
    {
      address = "192.168.100.8";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "192.168.100.1";
  networking.nameservers = ["192.168.100.8" "1.1.1.1"];
  networking.useDHCP = false;

  boot.supportedFilesystems = ["ntfs"];
  hardware.enableRedistributableFirmware = true;

  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["10.77.0.7/24"];
      privateKeyFile = "/root/wireguard-key";
      peers = [
        {
          publicKey = "zJc1neQD2vufvtJPkReaNXlElPQuuBjizW6wwu1pmnA=";
          allowedIPs = ["10.77.0.0/24"];
          endpoint = "c.pikpok.xyz:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
    };
  };

  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = raspberrypi
      netbios name = raspberrypi
      security = user
      hosts allow = 192.168.100. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user

      # Time machine config
      min protocol = SMB2
      server min protocol = SMB2
    '';
    shares = {
      NASNTFS = {
        path = "/mnt/nas-ntfs";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      NAS = {
        path = "/mnt/nas";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      "Time Machine" = {
        path = "/mnt/nas/Time-Machine";
        public = "no";
        writeable = "yes";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "fruit:model" = "TimeCapsule8,119";
        "fruit:metadata" = "stream";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:encoding" = "private";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };

  users.users.time-machine = {
    isSystemUser = true;
    group = "time-machine";
  };
  users.groups.time-machine = {};

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
