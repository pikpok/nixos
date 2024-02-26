{pkgs, ...}: {
  systemd.timers."xoler-backup" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 21:21:00";
      Unit = "xoler-backup.service";
    };
  };

  systemd.services."xoler-backup" = {
    path = [ pkgs.openssh ];
    script = ''
      set -eu
      cd /mnt/nas/Backups/xoler/ && ./backup.sh
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "pikpok";
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
    path = [ pkgs.openssh pkgs.rsync ];
    script = ''
      set -eu
      cd /mnt/nas/Backups/vps/ && ./backup.sh
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "pikpok";
    };
  };
}
