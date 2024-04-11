{pkgs, ...}: {
  services.borgmatic = {
    enable = true;
    configurations = {
      nas = {
        keep_daily = 7;
        keep_monthly = 6;
        encryption_passcommand = "${pkgs.coreutils}/bin/cat /root/borg-enc-key";
        source_directories = [
          "/mnt/nas/Music"
          "/mnt/nas/Photos"
        ];
        repositories = [
          {
            path = "ssh://u395343@u395343.your-storagebox.de:23/./nas";
            label = "hetzner";
          }
        ];
      };
      raspberrypi = {
        keep_daily = 7;
        keep_monthly = 6;
        encryption_passcommand = "${pkgs.coreutils}/bin/cat /root/borg-enc-key";
        source_directories = [
          "/var/lib/private"
        ];
        repositories = [
          {
            path = "ssh://u395343@u395343.your-storagebox.de:23/./raspberrypi";
            label = "hetzner";
          }
        ];
        postgresql_databases = [
          {
            name = "all";
            username = "postgres";
          }
        ];
      };
    };
  };

  systemd.timers."vps-backup" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 13:21:00";
      Unit = "vps-backup.service";
    };
  };

  systemd.services."vps-backup" = {
    path = [pkgs.openssh pkgs.rsync];
    script = ''
      set -eu
      cd /mnt/nas-ntfs/Backups/vps/ && ./backup.sh
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "pikpok";
    };
  };
}
