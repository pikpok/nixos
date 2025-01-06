{
  config,
  lib,
  ...
}: {
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  boot.swraid.enable = true;
  fileSystems."/mnt/nas" = {
    device = "/dev/disk/by-label/storage";
    fsType = "ext4";
  };

  swapDevices = [];

  networking = {
    hostName = "domino";
    useDHCP = lib.mkDefault true;

    interfaces.enp2s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.100.7";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = {
      address = "192.168.100.1";
      interface = "enp2s0";
    };
    nameservers = ["192.168.100.7" "1.1.1.1"];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General.Experimental = true;

  powerManagement.powertop.enable = true;
}
