{pkgs, ...}: {
  sops.secrets."borgmatic" = {
    sopsFile = ../../secrets/raspberrypi/borgmatic.env;
    format = "dotenv";
  };

  systemd.services."borgmatic" = {
    overrideStrategy = "asDropin";
    serviceConfig.EnvironmentFile = "/run/secrets/borgmatic";
  };

  services.borgmatic = {
    enable = true;
    configurations = {
      nas = {
        keep_daily = 7;
        keep_monthly = 6;
        source_directories = [
          "/mnt/nas/Music"
          "/mnt/nas/Photos"
        ];
        repositories = [
          {
            path = "$\{HETZNER_NAS_REPO_PATH\}";
            label = "hetzner";
          }
        ];
        healthchecks = {
          ping_url = "$\{HEALTHCHECKS_NAS_PING_URL\}";
        };
      };
      raspberrypi = {
        keep_daily = 7;
        keep_monthly = 6;
        source_directories = [
          "/var/lib/private"
        ];
        repositories = [
          {
            path = "$\{HETZNER_RASPBERRYPI_REPO_PATH\}";
            label = "hetzner";
          }
        ];
        postgresql_databases = [
          {
            name = "all";
            username = "postgres";
            pg_dump_command = "${pkgs.postgresql_16}/bin/pg_dumpall";
          }
        ];
        healthchecks = {
          ping_url = "$\{HEALTHCHECKS_RASPBERRYPI_PING_URL\}";
        };
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
